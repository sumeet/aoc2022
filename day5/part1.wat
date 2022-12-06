;; MEMORY MAP
;; 0 PTR_FOR_RET_VAL ugh
;; 4 OUTPUT_STR PTR 
;; 8 OUTPUT_STR LEN 
;; 12 OUTPUT_STRING
;; 28 STACKS
;; 3000 MOVES_INPUT
;; ......\0

(module
  ;; (fd, *iovs, iovs_len, nwritten) 
  ;; -> Returns number of bytes written
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (memory 1)
  (export "memory" (memory 0))

  ;; puzzle input (sample)
  (data
    (i32.const 28)
    ;; first line is empty because 1 offset
    ;; each stack has a bunch of preallocated spaces
    ;; afterwards so we don't have to dynamically
    ;; allocate memory
    ;; each stack has length 30
                   "                              "
                   "ZN                            "
                   "MCD                           "                   
                   "P                             "                   
  )
  (data (i32.const 3000) "move 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2\u{0000}")

  (func $main (export "_start")
    (call $solve)

    (call $pop_stack (i32.const 1))
    (call $putc)
    (call $pop_stack (i32.const 2))
    (call $putc)
    (call $pop_stack (i32.const 3))
    (call $putc)
  )

  (func $solve
    (local $str_i i32)
    (local $num_moves i32)
    (local $src_stack i32)
    (local $dest_stack i32)

    (loop $line_loop
      ;; go past "move " -- 5 chars
      (local.get $str_i)
      (i32.add (i32.const 5))
      (local.set $str_i)

      ;; load into $num_moves
      (call $consumeint (local.get $str_i))
      (local.set $str_i)
      (local.set $num_moves)

      ;; go past " from " -- 6 chars
      ;; incr $str_i
      (local.set $str_i
         (i32.add (i32.const 6) (local.get $str_i)))

      ;; load into $src_stack
      (call $consumeint (local.get $str_i))
      (local.set $str_i)
      (local.set $src_stack)

      ;; go past " to " -- 4 chars
      ;; incr $str_i
      (local.set $str_i
         (i32.add (i32.const 4) (local.get $str_i)))

      ;; load into $dest_stack
      (call $consumeint (local.get $str_i))
      (local.set $str_i)
      (local.set $dest_stack)

      (call $do_move
        (local.get $num_moves)
        (local.get $src_stack)
        (local.get $dest_stack)
      )

      ;; if this character is a newline, add 1 and
      ;; continue the loop
      (if (i32.eq
            (call $getc_moves (local.get $str_i))
            (i32.const 10))
        (then
          ;; incr $str_i
          (local.set $str_i
             (i32.add (i32.const 1) (local.get $str_i)))
          (br $line_loop)
        )
      )
    )
  )

  (func $do_move (param $num_moves i32)
                 (param $src_stack i32)
                 (param $dest_stack i32)
    (local $i i32)

    (loop $loop
      (call $pop_stack (local.get $src_stack))
      (call $push_stack (local.get $dest_stack))


      (local.set $i 
        (i32.add (i32.const 1) (local.get $i)))
      (i32.lt_s (local.get $i) (local.get $num_moves))
      (br_if $loop)
    )
  )

  (func $pop_stack (param $stack_index i32) (result i32)
    (local $str_i i32)
    ;; 30 is the size of each stack
    (i32.mul (local.get $stack_index) (i32.const 30))
    (local.set $str_i)

    ;; find the first space character (end of stack)
    (loop $find_loop
      (call $getc_stack (local.get $str_i))
      ;; ' ' is 32
      (i32.ne (i32.const 32))
      (if
        (then
          (local.set $str_i
            (i32.add (local.get $str_i) (i32.const 1)))
          (br $find_loop)
        )
        ;; at the end of the loop, str_i will be 1 
        ;; past the end of the stack, so bring it back in
        (else
          (local.set $str_i
            (i32.sub (local.get $str_i) (i32.const 1)))
        )
      )
    )

    ;; now $str_i points to top of the stack
    (call $getc_stack (local.get $str_i)) ;; return value
    (call $storec (local.get $str_i) (i32.const 32))
  )

  (func $push_stack
        (param $val i32)
        (param $stack_index i32) 
    (local $str_i i32)
    ;; 30 is the size of each stack
    (i32.mul (local.get $stack_index) (i32.const 30))
    (local.set $str_i)

    ;; find the first space character (end of stack)
    (loop $find_loop
      (call $getc_stack (local.get $str_i))
      ;; ' ' is 32
      (i32.ne (i32.const 32))
      (if
        (then
          (local.set $str_i
            (i32.add (local.get $str_i) (i32.const 1)))
          (br $find_loop)
        )
      )
    )

    ;; now $str_i points to 1 past the top of the stack
    (call $storec (local.get $str_i) (local.get $val))
  )

  ;; reads a number from input,
  ;; and returns the new starting_position,
  ;; essentially "consuming" the input
  (func $consumeint (param $start_pos i32) (result i32 i32)
    ;; calculate length
    (local $len i32)
    (local $this_char i32)
    (local.set $len (i32.const 0))
    (loop $len_loop
      (i32.add (local.get $start_pos) (local.get $len))
      (local.set $this_char (call $getc_moves))

      (i32.and
        ;; '0' is 48
        (i32.ge_s (local.get $this_char) (i32.const 48))
        ;; '9' is 57
        (i32.le_s (local.get $this_char) (i32.const 57))
      )

      (if 
        (then
          (local.set $len
            (i32.add (i32.const 1) (local.get $len)))
          (br $len_loop)
        )
      )
    )

    (call $atoi
      (i32.add (i32.const 3000) (local.get $start_pos))
      (local.get $len)
    )
    (i32.add (local.get $start_pos) (local.get $len))
  )

  (func $getc_stack (param $i i32) (result i32)
    (i32.load8_u (i32.add (i32.const 28) (local.get $i)))
  )

  (func $getc_moves (param $i i32) (result i32)
    (i32.load8_u (i32.add (i32.const 3000) (local.get $i)))
  )

  (func $storec (param $i i32) (param $val i32) 
    (i32.store8
      (i32.add (i32.const 28) (local.get $i))
      (local.get $val)
    )
  )

  (func $putc (param $c i32)
    ;; 12 is where the output goes

    ;; technically we only need to do this once, not every time
    ;; we print a char, but whatever we're debugging
    ;; Creating a new io vector within linear memory
    ;; memory offset of string
    (i32.store (i32.const 4) (i32.const 12))
    ;; length of string
    (i32.store (i32.const 8) (i32.const 1))

    (i32.store (i32.const 12) (local.get $c))

    (call $fd_write
      (i32.const 1) ;; fd 1 -- stdout
      (i32.const 4) ;; *iovs - The pointer to the iov array
      (i32.const 1) ;; iovs_len 
      (i32.const 0) ;; nwritten 
    )
    drop ;; nwritten
  )

  (func $print_int_backwards (param $num i32)
    (loop $loop
      (i32.rem_s (local.get $num) (i32.const 10))

      (i32.add (i32.const 48))
      (call $putc)

      ;; divide input by 10
      (local.set $num (i32.div_s (local.get $num) (i32.const 10)))

      (i32.gt_s (local.get $num) (i32.const 0))
      br_if $loop
    )

    ;; print a newline
    (call $putc (i32.const 10))
  )

  ;; length is 4
  ;; offset is 3
  ;;
  ;; 1234
  (func $atoi (param $addr i32) (param $size i32) (result i32)
    ;; loop counter -- starts at 0
    (local $i i32)
    (local $acc i32)

    (loop $loop
      ;; multiply result by 10
      (i32.mul (local.get $acc) (i32.const 10))
      (local.set $acc)

      ;; push next char onto the stack
      (i32.add (local.get $addr) (local.get $i))
      (i32.load8_u)
      (i32.sub (i32.const 48))
      (i32.add (local.get $acc))
      (local.set $acc)

      ;; incr loop counter
      (local.set $i (i32.add (i32.const 1) (local.get $i)))
      (i32.lt_s (local.get $i) (local.get $size))
      br_if $loop
    )
    (local.get $acc)
  )
)

(module
 (import
  "wasi_unstable"
  "fd_write"
  (func $fd_write (param i32 i32 i32 i32) (result i32)))
 (memory 1)
 (export "memory" (memory 0))
 (data (i32.const 0) "")
 (data (i32.const 50) "")
 (data (i32.const 54) "")
 (func
  $main
  (export "_start")
  (call $solve)
  (call $print_int_backwards))
 (func
  $2_to_the_alpha
  (param $alpha i32)
  (result i32)
  (i32.shl (i32.const 1) (i32.sub (local.get $alpha) (i32.const 97))))
 (func
  $solve
  (result i32)
  (local $str_i i32)
  (local $bitfield i32)
  (loop
   $parse_loop
   (local.set $bitfield (i32.const 0))
   (call $getc (i32.add (local.get $str_i) (i32.const 0)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 1)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 2)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 3)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 4)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 5)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 6)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 7)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 8)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 9)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 10)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 11)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 12)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (call $getc (i32.add (local.get $str_i) (i32.const 13)))
   (call $2_to_the_alpha)
   (local.set $bitfield (i32.or (local.get $bitfield)))
   (i32.popcnt (local.get $bitfield))
   (if
    (i32.eq (i32.const 14))
    (then (i32.add (local.get $str_i) (i32.const 14)) (return))
    (else
     (local.set $str_i (i32.add (i32.const 1) (local.get $str_i)))
     (br $parse_loop))))
  (i32.const 1337))
 (func
  $consumeint
  (param $start_pos i32)
  (result i32 i32)
  (local $len i32)
  (local $this_char i32)
  (local.set $len (i32.const 0))
  (loop
   $len_loop
   (i32.add (local.get $start_pos) (local.get $len))
   (local.set $this_char (call $getc))
   (i32.and
    (i32.ge_s (local.get $this_char) (i32.const 48))
    (i32.le_s (local.get $this_char) (i32.const 57)))
   (if
    (then
     (local.set $len (i32.add (i32.const 1) (local.get $len)))
     (br $len_loop))))
  (call
   $atoi
   (i32.add (i32.const 3000) (local.get $start_pos))
   (local.get $len))
  (i32.add (local.get $start_pos) (local.get $len)))
 (func
  $getc
  (param $i i32)
  (result i32)
  (i32.load8_u (i32.add (i32.const 28) (local.get $i))))
 (func
  $storec
  (param $i i32)
  (param $val i32)
  (i32.store8
   (i32.add (i32.const 28) (local.get $i))
   (local.get $val)))
 (func
  $putc
  (param $c i32)
  (i32.store (i32.const 4) (i32.const 12))
  (i32.store (i32.const 8) (i32.const 1))
  (i32.store (i32.const 12) (local.get $c))
  (call
   $fd_write
   (i32.const 1)
   (i32.const 54)
   (i32.const 1)
   (i32.const 50))
  drop)
 (func
  $print_int_backwards
  (param $num i32)
  (loop
   $loop
   (i32.rem_s (local.get $num) (i32.const 10))
   (i32.add (i32.const 48))
   (call $putc)
   (local.set $num (i32.div_s (local.get $num) (i32.const 10)))
   (i32.gt_s (local.get $num) (i32.const 0))
   br_if
   $loop)
  (call $putc (i32.const 10)))
 (func
  $atoi
  (param $addr i32)
  (param $size i32)
  (result i32)
  (local $i i32)
  (local $acc i32)
  (loop
   $loop
   (i32.mul (local.get $acc) (i32.const 10))
   (local.set $acc)
   (i32.add (local.get $addr) (local.get $i))
   (i32.load8_u)
   (i32.sub (i32.const 48))
   (i32.add (local.get $acc))
   (local.set $acc)
   (local.set $i (i32.add (i32.const 1) (local.get $i)))
   (i32.lt_s (local.get $i) (local.get $size))
   br_if
   $loop)
  (local.get $acc)))

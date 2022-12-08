;; MEMORY MAP
;; 0 PTR_FOR_RET_VAL ugh
;; 4 OUTPUT_STR PTR 
;; 8 OUTPUT_STR LEN 
;; 12 OUTPUT_STRING
;; 28 PUZZLE_INPUT
;; ......\0

(module
  ;; (fd, *iovs, iovs_len, nwritten) 
  ;; -> Returns number of bytes written
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory 1)
  (export "memory" (memory 0))

  ;; puzzle input
  ;;(data (i32.const 28) "A Y\nB X\nC Z\n\u{0000}")
  (data (i32.const 28) "B Z\nA Z\nB Z\nC Z\nC Z\nB X\nA X\nC X\nA Z\nC Y\nC X\nC Y\nC Y\nA X\nA Z\nA Z\nA X\nB Z\nB X\nA Z\nA X\nC Y\nA X\nB Z\nB Z\nA X\nC Z\nA Z\nA X\nB Z\nA Z\nA Y\nC Y\nA Z\nC Z\nA Z\nC Y\nC Z\nC Z\nA Z\nA X\nA X\nB X\nA Z\nB Z\nA X\nA Z\nA Z\nA X\nA X\nC Y\nA Z\nB X\nC Y\nA X\nB Y\nA Z\nA X\nA Z\nA X\nC Z\nA Z\nA Y\nA X\nC Y\nA X\nB X\nA X\nA Z\nC Y\nA Z\nA X\nC X\nC Z\nC Z\nA Z\nA X\nA Z\nC X\nC Z\nB Z\nA Z\nC Y\nC Z\nB X\nA X\nA Z\nA X\nA X\nC Y\nA Z\nC Z\nB X\nA X\nA X\nA Z\nA Y\nA X\nC X\nA Z\nB X\nC Y\nA X\nA X\nA X\nC X\nB Z\nB Z\nA Z\nA X\nA Z\nC Z\nC X\nC Y\nB X\nC Z\nA Z\nC X\nA Z\nA X\nA X\nA X\nA X\nA Z\nB X\nA X\nB X\nC Z\nA Z\nA Z\nA X\nA X\nA X\nB X\nA Z\nA X\nA Z\nA X\nB Z\nA Z\nA X\nB Z\nA Z\nA Z\nC Y\nB Z\nA Z\nB Z\nA Z\nA X\nC X\nA X\nC Y\nC X\nA X\nA X\nC Y\nA Z\nA X\nB Z\nA Z\nA Z\nB X\nB Z\nA X\nA Z\nA X\nA X\nA Z\nA X\nA Z\nA Z\nC X\nA Z\nA X\nC Y\nA Z\nA Z\nA X\nA X\nA X\nA X\nB Z\nB X\nA Z\nA X\nA Z\nC Y\nB Y\nC Y\nB X\nA Z\nA Z\nA Z\nC Y\nA Z\nA X\nB Z\nC X\nA X\nC Z\nC X\nC Y\nA Z\nA X\nA Z\nC Z\nA Z\nA Z\nA Y\nC Z\nA X\nA X\nB Z\nA Z\nC Z\nA Z\nA X\nA Z\nA Z\nA Z\nA Z\nA Z\nA Z\nA Z\nA Z\nC X\nA X\nA X\nA X\nB Y\nB X\nA X\nA Z\nA Z\nA X\nA Z\nA X\nA X\nA Z\nB X\nA Z\nC Z\nA Z\nC Z\nA Z\nA Z\nC Z\nA X\nC Z\nA X\nC X\nA Z\nA Z\nB Z\nA Y\nB Z\nA X\nB Z\nA Z\nA X\nA Z\nA Z\nA X\nA Z\nB Z\nC X\nA Z\nA X\nB Z\nC Y\nB Z\nC X\nA Z\nA Z\nC X\nB X\nC Z\nA Z\nA X\nA Z\nC X\nA Z\nC Z\nC Z\nB Z\nB Z\nA Z\nC X\nA X\nB Y\nA Y\nA Z\nC X\nB X\nA Z\nA Z\nB Y\nA Z\nA Z\nC Z\nA Z\nA X\nA Z\nB X\nC Z\nB X\nA Z\nB Z\nC Y\nA X\nA X\nA Z\nA Z\nA Z\nC Y\nA X\nA Z\nA Z\nA X\nB Z\nA Z\nC X\nC Z\nA Z\nA X\nB Z\nA X\nC Y\nA X\nA Z\nA Y\nC Z\nA Y\nA Z\nC X\nC Y\nA Z\nC Y\nA Z\nA X\nC Y\nA Z\nA X\nA X\nB Z\nA X\nC X\nA X\nC X\nA X\nA Z\nA X\nA Z\nA Z\nA X\nC X\nC Z\nA Z\nC Z\nC X\nA Z\nC Y\nA X\nA Z\nA Z\nC Y\nA X\nB X\nC Y\nB Z\nC Y\nA X\nA X\nC Z\nA X\nA Z\nA X\nA X\nC X\nA X\nA Z\nB X\nC Z\nA Y\nB Y\nA Z\nA Z\nA Z\nA Z\nB Y\nA Y\nA Z\nB Z\nA Z\nA X\nC Z\nB Y\nC Y\nA X\nA Z\nC Z\nB Z\nA Z\nA Z\nA Y\nC Z\nA Z\nA Z\nC Z\nC Z\nC Z\nA X\nB Y\nC X\nA X\nA Z\nA Z\nB Z\nA Y\nA X\nA Z\nB X\nA X\nA X\nA Z\nA Y\nA Z\nA X\nB X\nA Z\nC X\nA Z\nA X\nC X\nB X\nB Y\nB X\nA Z\nA Z\nA Z\nA X\nB X\nA X\nB Z\nA Y\nB Z\nC Z\nA X\nC Z\nC X\nA Z\nC Y\nC Y\nA Z\nA X\nA X\nA X\nB X\nA Z\nA Y\nC Y\nB X\nA X\nA X\nA X\nC Y\nA Z\nA Y\nA X\nC Z\nA Z\nA Z\nA Z\nC Z\nA X\nA Z\nC Z\nB X\nC Y\nA Z\nB Z\nB Z\nC Z\nC Z\nA X\nA Z\nA Z\nB X\nB X\nA Z\nA Z\nA Y\nC Z\nA Z\nA X\nC Z\nA Z\nC Z\nC Z\nA Z\nA Z\nB Z\nA X\nB Y\nA Z\nA X\nC Z\nA X\nB X\nA Z\nC Y\nA Z\nC X\nC Y\nA X\nC X\nC X\nA Z\nC Z\nC Y\nA Z\nA Z\nA X\nA X\nC Z\nA Y\nA Z\nA X\nB Z\nA X\nA Z\nA Z\nA X\nB Z\nA X\nA Z\nC X\nA Z\nA Z\nC X\nA Z\nA X\nA Z\nA X\nB Z\nA Z\nA Z\nC Y\nC Y\nC Z\nC Z\nC Y\nA X\nA X\nA X\nA Z\nA Z\nC Y\nA Z\nC Z\nA Z\nC Z\nB Z\nB X\nA Y\nC Y\nA X\nA Z\nA X\nA X\nA Z\nC Z\nC Y\nC Y\nA Y\nA X\nA Z\nA X\nC Z\nA X\nA Z\nA Z\nC Y\nA X\nA Z\nA Z\nA X\nB Y\nA Z\nA Z\nA Z\nA Z\nC Y\nA Z\nA X\nA X\nA Z\nA Z\nC Y\nA Z\nA Z\nB Z\nA Z\nA X\nA X\nA Y\nC Z\nC Z\nA Z\nB Z\nA Z\nA Z\nA X\nA X\nC Z\nA Z\nA X\nA X\nA Z\nA Z\nB Y\nA Y\nC Y\nA X\nA Z\nC Z\nC Y\nA Z\nC Y\nA X\nA X\nA X\nA Z\nC Y\nC Y\nA Z\nB X\nC Y\nA Z\nA X\nA Z\nA Y\nC Y\nC Z\nB Z\nA Z\nC Y\nA X\nC Z\nA X\nC Y\nC Z\nA Z\nC Y\nC Y\nA Y\nB X\nA Z\nC Z\nB Z\nB Y\nA Z\nC Y\nA X\nA Z\nA Z\nC Y\nA Z\nC Z\nA Z\nA Z\nA X\nA Z\nA Z\nC Z\nA X\nA Z\nC Z\nC Y\nA X\nA X\nC Z\nC Y\nA Z\nC Y\nA Z\nA X\nA X\nA Z\nA Z\nA X\nA Z\nC Y\nC Z\nA Z\nB X\nC Z\nA Z\nA Z\nA X\nB X\nA Z\nA Y\nA X\nC Z\nB X\nA Z\nC Y\nC Z\nC Z\nC Z\nA Z\nA Z\nA X\nA Z\nC Z\nC Y\nA X\nA Z\nA Z\nA Y\nA X\nA Z\nA Z\nC X\nB Z\nA X\nA Z\nA X\nC Z\nA X\nC X\nA X\nC Y\nC Y\nA X\nA X\nA Z\nB Z\nA Z\nA Y\nB Z\nA X\nC X\nA X\nC X\nA X\nC X\nA Z\nA X\nA X\nA X\nC Y\nA X\nA X\nC X\nC Z\nA X\nB Y\nA X\nB Z\nA Z\nA X\nC Z\nA Z\nA X\nA Z\nA X\nC X\nC Z\nA X\nC Z\nC Y\nC Y\nA X\nA X\nA X\nC Z\nC Z\nA Z\nC Z\nA Z\nB Z\nA Y\nB Z\nA X\nA Z\nA Z\nA Z\nC Z\nA Z\nA X\nA X\nB Z\nA Z\nC Y\nC Z\nB Z\nC Y\nC Z\nA X\nA X\nC X\nB X\nC Z\nA Z\nA Z\nC Z\nA X\nA Z\nA Z\nB X\nB Z\nA Z\nA Z\nB Z\nA Z\nA Z\nB Z\nB Z\nC Z\nA Z\nC Z\nA Z\nA Z\nC Z\nA Z\nA Z\nB Z\nA Z\nA X\nA X\nA X\nA Z\nC Z\nA X\nA Z\nA X\nA Z\nB Z\nB Z\nC Z\nA Z\nA Y\nC X\nA X\nA Z\nA X\nA X\nC X\nC Z\nB Y\nA X\nA X\nC Y\nC Y\nA X\nA Z\nA Z\nB Z\nB Z\nA Z\nC Z\nA Z\nC Z\nC X\nA Z\nA X\nA Y\nA X\nA Z\nC Z\nA X\nA Z\nA Z\nA Z\nA X\nC X\nB Z\nA Z\nA Y\nC X\nA Z\nA Z\nA Z\nA X\nA Y\nA X\nC Y\nA Z\nC Y\nA Z\nA Z\nC X\nA Z\nA Y\nC Z\nA X\nA X\nA Z\nA Y\nA Z\nA X\nC Z\nA Z\nA Z\nB Z\nA Z\nA Z\nC X\nB Z\nC Y\nA X\nA Y\nB X\nA Z\nC Z\nC X\nC Z\nA X\nA X\nA Z\nA Z\nA X\nA Z\nB Z\nB Z\nA Z\nB Y\nB Z\nA X\nA X\nC Z\nA Z\nC Y\nB Z\nC Z\nC Z\nA Z\nA X\nB Z\nA X\nA X\nA Z\nA Z\nA X\nB Z\nA Z\nC Z\nA Z\nA Z\nB X\nC Z\nB Z\nC Y\nA Z\nA X\nA X\nB X\nA X\nB Z\nC Y\nC Y\nB Z\nC Y\nC Y\nA X\nA Z\nA Z\nC Y\nB Z\nA X\nA Z\nA X\nB X\nA X\nC Y\nA X\nA X\nB Z\nA X\nB X\nA Z\nC Y\nB Z\nA X\nA Z\nA X\nA X\nB X\nA X\nA X\nA X\nA Z\nA Z\nC Y\nA Z\nB Z\nC Z\nC Y\nC Z\nA X\nA Z\nA X\nC Z\nC Z\nC Z\nC Y\nA X\nB X\nB X\nC X\nC Z\nC X\nC Z\nB Z\nA Y\nA X\nC X\nB X\nA X\nA X\nA Z\nA X\nA Z\nA X\nA X\nA Z\nA Z\nC Z\nA X\nC Y\nC Y\nC Z\nA Z\nA X\nA Z\nA X\nA Z\nA Y\nA Z\nA X\nA X\nA Z\nA X\nA Y\nA Y\nC X\nA Y\nC Y\nC X\nA Z\nC Z\nC Y\nC Z\nA Z\nC X\nA X\nC Z\nA Z\nC Y\nB Z\nA Z\nA Z\nA Z\nC Y\nA X\nA X\nA Z\nA Z\nA Z\nB Z\nC Z\nA X\nC Y\nA X\nA Z\nA X\nC X\nC Z\nA Z\nC Y\nA Y\nA Y\nA Z\nA X\nA Z\nA Y\nA X\nC Z\nA Z\nA Z\nA X\nA X\nB Z\nB Y\nB Y\nC X\nA Z\nA Z\nC Z\nA X\nA Z\nC Y\nB X\nC Y\nA Z\nA Z\nA X\nA Z\nA X\nA X\nC Z\nA Z\nA Z\nA X\nA X\nC Y\nA X\nA X\nC Y\nA Y\nC X\nA X\nC Y\nA Y\nA Z\nB Y\nA X\nC Z\nB X\nA X\nC Z\nA Z\nB Z\nA Z\nA Z\nC X\nA Z\nB Z\nC X\nA Z\nC Y\nA Z\nC Z\nA Z\nC X\nA X\nA Z\nA Y\nB X\nA X\nB X\nA Z\nA Z\nC Y\nA Z\nC Z\nA Z\nA Z\nA Z\nC X\nA Z\nB X\nA X\nA Z\nC Z\nA Z\nA X\nC Y\nA Z\nC Y\nA Z\nA Z\nC Z\nA X\nA Z\nA Z\nB X\nA Z\nA X\nC Z\nB Y\nA Z\nA X\nC Z\nA X\nA Z\nA Z\nA Z\nC Z\nA Z\nA Z\nC X\nA X\nA X\nC X\nA X\nA X\nB Z\nA Z\nA X\nB X\nA X\nA Z\nC Y\nA Z\nB X\nC Y\nA X\nC Z\nA Z\nB Z\nA X\nA Z\nA Z\nC Z\nA X\nC Z\nA X\nC X\nA Y\nA X\nA Z\nC X\nA X\nA X\nA X\nA X\nA Z\nA X\nB Z\nC Z\nC Y\nB Z\nB Z\nB X\nA Z\nA X\nB Z\nA Z\nA X\nC Z\nA Z\nC Y\nB Z\nC Y\nA X\nC X\nA X\nA Z\nC Y\nA Z\nA X\nA Y\nC Y\nC Y\nA Z\nA Z\nC Y\nA Z\nA Z\nA X\nC Y\nB Y\nA X\nA X\nA X\nC Y\nB X\nA Z\nA Y\nA Z\nA Z\nA X\nC Z\nA Z\nA Z\nC X\nA Z\nB Z\nB X\nA X\nC Z\nA X\nC Y\nA Z\nC Z\nC Y\nC X\nC Y\nA Z\nA X\nA Z\nA Z\nA Z\nB Z\nA Z\nC Z\nA Z\nC Z\nB Z\nC Z\nC Z\nA Z\nA Z\nB X\nA Z\nA X\nA Z\nA X\nA Y\nA Z\nB Z\nC X\nA Z\nA Z\nB X\nA X\nC X\nC Z\nA X\nA Z\nA X\nC Y\nC Z\nA Z\nC Y\nA X\nA Z\nA Z\nB Z\nC Y\nA Z\nA Z\nC Z\nA X\nC X\nA Z\nA Z\nA Y\nC Z\nC Z\nA Z\nA X\nB Z\nA X\nA X\nA X\nA X\nA Z\nA Z\nA X\nA X\nC Z\nC Y\nC Y\nC Y\nA Z\nC X\nB Z\nC Y\nC Z\nA X\nA X\nA Z\nC Z\nC Z\nA Y\nC Y\nB X\nC Y\nA X\nA X\nA Y\nA X\nA Z\nA Z\nA X\nA Z\nA Z\nA Z\nA X\nA Z\nB Z\nA X\nA X\nA X\nC Z\nC X\nA Z\nC Y\nC Z\nA X\nA Z\nA Z\nA X\nA Z\nA X\nB Z\nA Z\nA Z\nA Z\nC Y\nC Z\nB Z\nA Z\nB Z\nA X\nA X\nA X\nC Y\nA Z\nA Z\nA Z\nC X\nA X\nA X\nA Z\nA Z\nA Z\nA Z\nB Z\nA X\nA Z\nA X\nC Z\nA Z\nA Z\nA Z\nB Z\nA Y\nA Z\nC Z\nB Z\nC Y\nA Z\nA X\nC Y\nA X\nA X\nA Z\nA Z\nA X\nB Z\nB X\nC Z\nC Z\nA Y\nA Z\nA X\nA Z\nA Z\nA Z\nA Z\nA Z\nB Z\nA Z\nB X\nA Z\nA Z\nC Z\nB Z\nA Z\nC X\nB Z\nC X\nB Z\nA Z\nA Z\nA Z\nA Z\nA X\nB Z\nA X\nB Z\nC Y\nA Z\nA Z\nC X\nA X\nA Z\nA Y\nA Z\nC Y\nC X\nC Z\nA X\nA Z\nC Z\nA Z\nA X\nA Z\nB Z\nA X\nA Z\nB Z\nC Y\nA Z\nC Y\nA Z\nC Y\nB X\nC Y\nA Z\nB Z\nA X\nB Z\nB Z\nC X\nA Z\nC Z\nA Z\nC Z\nA Z\nC Z\nB Z\nC Y\nC Z\nA Z\nC Y\nA Z\nC X\nB Y\nB Y\nC X\nC Y\nA Z\nC Z\nA Z\nC X\nA Z\nA Z\nC Y\nA Z\nA Z\nC X\nA Y\nA X\nA X\nB Z\nA Z\nC Z\nA Z\nB Z\nC Y\nC Z\nA Z\nC Y\nB X\nC Z\nA X\nC X\nC Y\nC Y\nC Y\nA Z\nA Z\nB Y\nC Y\nA Z\nA X\nA Z\nA X\nA Z\nC X\nC Z\nA X\nC Z\nB X\nA X\nC Z\nA Z\nC X\nA Y\nA Z\nA X\nA Z\nC Z\nB Z\nB Z\nA Z\nC Y\nA Z\nC Z\nC Y\nC Z\nA Z\nA Z\nB X\nC X\nC Z\nA X\nA Z\nA Y\nC Y\nA X\nA Z\nC Y\nA Z\nB X\nA Z\nA Z\nA Z\nA Z\nC X\nA X\nA Z\nA Y\nA X\nB Y\nA X\nA X\nA X\nA X\nB Z\nA X\nC Y\nC X\nA X\nA Z\nA X\nA Z\nA Z\nA Z\nA Z\nA X\nA Z\nC X\nC Z\nC Z\nA X\nB Y\nA X\nC Y\nA X\nC Z\nA X\nA Z\nA Z\nA Z\nA Z\nC X\nA X\nC Y\nA Z\nA Z\nC Y\nA Z\nA X\nA Z\nA X\nA Z\nB Y\nC Y\nB Y\nC Y\nA Y\nA Z\nC X\nB X\nA X\nA Y\nC Z\nA X\nB Z\nA X\nA X\nA Y\nA X\nA Z\nA Z\nC Z\nC X\nA Z\nC Y\nA Z\nA Z\nC X\nA Y\nA Z\nA X\nA Z\nA Z\nC X\nA Z\nA Z\nA Z\nC Y\nA X\nA X\nA X\nC Z\nA Z\nC Y\nA X\nA X\nC Y\nC X\nC Y\nA Y\nC X\nA Z\nA Z\nA Y\nC X\nA Z\nA Z\nA Z\nC Y\nC X\nA Z\nB Z\nA Z\nA X\nC Y\nA X\nC Y\nC Y\nA X\nC Y\nA X\nC Y\nB Z\nA Z\nA X\nA Z\nA X\nA X\nA Z\nA X\nA X\nC Z\nA Z\nB Y\nC X\nB X\nB X\nA Z\nA Y\nB Y\nA Z\nA X\nA X\nC Y\nC X\nB Z\nA Z\nC Y\nC X\nC Y\nA Y\nA Z\nC X\nA X\nA X\nA Z\nA Z\nB Z\nC X\nA Z\nB Z\nA X\nB Y\nC X\nA X\nA Y\nC X\nA X\nC Y\nA Z\nA Z\nA X\nA X\nC Z\nC Z\nB Z\nA X\nB Z\nB Y\nA Z\nA Z\nC Y\nA Z\nB Y\nA Z\nA X\nC Z\nC Z\nA X\nA X\nA X\nA Z\nA Z\nC Y\nA X\nA X\nA Z\nA X\nC X\nA Z\nA X\nB Z\nB X\nA X\nA X\nA Z\nB Z\nA X\nA Z\nC Y\nC Y\nB Z\nC Z\nA X\nB X\nB X\nA Z\nA X\nA Z\nC Y\nA X\nA X\nB Y\nC Y\nA X\nA X\nC Y\nA Z\nA Z\nC Z\nA Z\nB Z\nA Y\nA Z\nC Y\nB Y\nA X\nC X\nA X\nC Z\nA Z\nA X\nA Z\nA Z\nA X\nB Z\nC Z\nA Z\nA X\nC X\nA X\nC Y\nB Z\nB X\nC Z\nC X\nA X\nA X\nA Z\nA X\nC Y\nB Z\nA Z\nC Z\nA Z\nA Z\nA X\nB X\nA X\nA Z\nA X\nA X\nA Z\nA Z\nA Y\nA Z\nC Z\nB Z\nA X\nA X\nA X\nA Z\nB Z\nA Z\nA Z\nC Z\nC Y\nC Y\nA Z\nA X\nA Z\nC Z\nA X\nA X\nA Z\nA Z\nC X\nB Y\nA X\nB Z\nB Z\nA Z\nA Z\nC Z\nC Z\nA X\nA X\nA Z\nC Z\nA Z\nC Z\nB X\nA X\nA Z\nA Z\nC Z\nA X\nA Z\nB Y\nB X\nA X\nC Y\nC X\nC Y\nB X\nA X\nC Y\nA Z\nB Y\nA Y\nA X\nC Y\nA Z\nA Z\nA Z\nA Z\nA Z\nC Z\nA Z\nA Z\nA Z\nC X\nB X\nC Z\nA X\nB X\nA X\nC Y\nA X\nC X\nA X\nA Z\nA Z\nB X\nA X\nA Z\nA X\nC Z\nA Z\nA Z\nA X\nC Z\nA Z\nC X\nA Z\nA Z\nA Z\nA Z\nB Z\nA X\nA X\nC Y\nA Z\nA Z\nB Z\nA X\nA Z\nA Y\nA Z\nC X\nB Z\nA Z\nA X\nB Y\nA Z\nA X\nC X\nC X\nA X\nA Z\nA X\nA Z\nB Z\nB Y\nA Y\nA Z\nC Y\nB Z\nA Z\nC X\nC Y\nC Z\nC X\nA X\nA Z\nA X\nA X\nA Z\nA X\nA X\nA X\nA Z\nC Z\nC Y\nA Z\nA X\nC X\nB Z\nC Z\nC Y\nC Y\nA Z\nA X\nA Z\nA Z\nA Z\nA X\nA Z\nA Z\nA X\nC Z\nA X\nA X\nA Z\nC X\nB Y\nA X\nC Z\nA X\nC X\nA Z\nA X\nA Y\nC Z\nA X\nA Z\nC X\nB X\nA Z\nA Z\nA X\nA X\nA Z\nC Y\nC Z\nA X\nA Z\nC Z\nC X\nA X\nA Z\nA X\nA X\nB X\nC Z\nB Z\nA Z\nA X\nA X\nB Y\nA Z\nA X\nA X\nA Z\nA Z\nA Z\nA X\nC Y\nA Z\nC Y\nA Z\nA Z\nA X\nC Z\nA Z\nB X\nA X\nC Z\nA X\nA Y\nB X\nC X\nA X\nA X\nA Z\nA X\nA X\nA X\nC Y\nA Y\nA Z\nB Z\nB Z\nB Z\nA Z\nA Z\nA Z\nA X\nB X\nC Y\nA X\nA Z\nC Z\nB Y\nA X\nA Z\nA Z\nA X\nA X\nB Z\nA X\nC Y\nA Z\nA X\nA X\nA Z\nA Z\nA Z\nA Z\nA Z\nA X\nA Z\nA X\nA X\nC Z\nA X\nC Z\nA Z\nC Y\nA X\nA Z\nC Z\nA Z\nA Z\nA X\nA X\nA Z\nA X\nA Z\nB Z\nA X\nA X\nC X\nA Z\nA X\nA Z\nC Y\nC Y\nC Y\nC Y\nC Z\nA Z\nB X\nC Z\nA X\nA Z\nC Y\nA X\nA Z\nB X\nA Z\nC X\nC Z\nC X\nC X\nA Z\nA Z\nB X\nA Z\nA Z\nA Z\nB Z\nA Z\nC Z\nA X\nA X\nA Z\nA X\nA Z\nC Z\nC Z\nA Z\nC Z\nC X\nA Z\nA X\nB Z\nA X\nB Y\nC X\nA X\nA Y\nA Z\nA Z\nA X\nA X\nA Z\nA X\nA Z\nA X\nA Z\nA X\nA Y\nA X\nC Z\nA Z\nA Z\nA X\nA X\nA Z\nA X\nC Y\nC Z\nA Z\nA Y\nA Z\nA X\nA Z\nC X\nB X\nA Z\nC Z\nB Y\nA Z\nA Z\nC Y\nA X\nA Z\nA Z\nC Z\nC Y\nA Z\nB Y\nA X\nC Y\nA X\nA X\nA Z\nC Z\nA Z\nA Z\nA X\nC Z\nA X\nC Y\nC Y\nA X\nB X\nC X\nA Y\nA X\nA Z\nB X\nA X\nB Z\nA Z\nA X\nC X\nA X\nB X\nA X\nA Z\nA X\nC Y\nA Z\nC Z\nC Y\nA X\nB X\nC Y\nC X\nA X\nA Z\nA X\nA Z\nA X\nA X\nA Z\nA Z\nA X\nA Z\nA Y\nA X\nA X\nA Y\nA Z\nA Z\nC Z\nA X\nA Z\nA X\nA X\nB X\nA X\nB Y\nC Y\nA Z\nB Z\nA Z\nB Y\nA Z\nC Y\nA Z\nA X\nA X\nA Z\nC X\nC Z\nB X\nA X\nA Z\nA X\nA Z\nA Z\nB X\nA Z\nA X\nC Z\nB Y\nC Y\nC X\nA X\nA Z\nA X\nC Y\nA Z\nC Z\nA X\nA X\nA X\nA Z\nA Z\nA Z\nB X\nC X\nA Y\nB Z\nA X\nA Z\nA Z\nC X\nC Y\nA X\nA Z\nC Y\nA X\nA Z\nA X\nA Z\nA X\nA X\nB Z\nA X\nC X\nA X\nA X\nA X\nA Z\nA Z\nA X\nA Z\nC Y\nC Z\nB Z\nB X\nA Z\nA X\nC X\nC Y\nA X\nB Z\nB Z\nA Z\nB Z\nC Y\nA X\nA X\nA X\nC Y\nA Z\nA X\nA Z\nA Z\nA Z\nA X\nA Z\nA X\nA Z\nC Y\nA X\nC X\nC Y\nC Y\nC X\nA X\nC Y\nA Z\nC Y\nB Z\nB Z\nC Z\nA X\nB X\nC X\nA Z\nA Y\nA Z\nB Z\nA Z\nB Z\nA X\nA X\nA Z\nA Z\nA Y\nA Z\nA X\nA Y\nA Z\nA Z\nA Z\nA Z\nB X\nA Z\nA Z\nA Z\nA Z\nC Y\nB Y\nC X\nA Z\nB Z\nB X\nA X\nC Z\nA Z\nC Z\nA Z\nA X\nA X\nA X\nA X\nA X\nA Z\nC Y\nA X\nC X\nA Y\nC X\nC X\nA X\nA Z\nA X\nC Z\nA X\nC Y\nB Z\nC Y\nC Z\nB X\nA Z\nC Y\nA Z\nC Y\nA X\nA X\nA X\nA Z\nA Z\nA Z\nA Z\nC Z\nC Y\nA X\nC Y\nB Y\nA X\nA X\nA Z\nC Y\nC Z\nA X\nA X\nA Z\nA Z\nA X\nA X\nA Z\n\u{0000}")

  (func $main (export "_start")
    ;; 28 is memory address to read from, where puzzle input is
    ;; 4 bytes, the first number is
    ;; (call $atoi (i32.const 28) (i32.const 4))
    ;; (call $print_int_backwards)

    (call $print_int_backwards (call $solve))
  )

  (func $solve (result i64)
    (local $str_i i32) ;; init to 0
    (local $sum i64) ;; init to 0

    (loop $parse_loop
      (call $score_deduce_our_shape 
        (call $get_abc (local.get $str_i))
        (call $get_xyz (local.get $str_i)))
      (local.set $sum (i64.add (local.get $sum)))

      (call $score_win_lose_draw (call $get_xyz (local.get $str_i)))
      (local.set $sum (i64.add (local.get $sum)))

      ;; keep going until we hit a null byte
      (local.set $str_i
                 (i32.add (local.get $str_i) (i32.const 4)))
      (br_if $parse_loop
        (i32.ne (call $getc (local.get $str_i)) (i32.const 0)))
    )

    (local.get $sum)
  )

  (func $get_abc (param $str_i i32) (result i32)
      (call $getc (local.get $str_i))
  )

  (func $get_xyz (param $str_i i32) (result i32)
      (call $getc (i32.add (local.get $str_i) (i32.const 2)))
  )

  (func $score_deduce_our_shape (param $abc i32) (param $xyz i32)
        (result i64)
    (local $abc_rps i32)
    (local $xyz_rps i32)
    ;; $abc - 65
    ;; $xyz - 88
    (local.set $abc_rps
               (i32.sub (local.get $abc) (i32.const 65)))
    (local.set $xyz_rps
               (i32.sub (local.get $xyz) (i32.const 88)))

    ;; abc table
    ;; 0 is rock
    ;; 1 is paper
    ;; 2 is scissors

    ;; xyz table
    ;; 0 is loss
    ;; 1 is draw
    ;; 2 is win

    ;; ret table
    ;; 1 is rock
    ;; 2 is paper
    ;; 3 is scissors

    ;; if it's a draw, then we return abc (what they played)
    (if (i32.eq (local.get $xyz_rps (i32.const 1)))
      (then
        ;; add 1 because otherwise RPS is 0 indexed
        (i32.add (local.get $abc_rps) (i32.const 1))
        (i64.extend_i32_s)
        return))

    ;; THEY HAVE ROCK
    ;; abc: 0, xyz: 0; they have rock, and we lose
    ;; so we have scissors: 3
    (if (i32.and
          (i32.eq (local.get $abc_rps) (i32.const 0))
          (i32.eq (local.get $xyz_rps) (i32.const 0)))
      (then
        (i64.const 3)
        return))

    ;; abc: 0, xyz: 2; they have rock, and we win
    ;; so we have paper: 2
    (if (i32.and
          (i32.eq (local.get $abc_rps) (i32.const 0))
          (i32.eq (local.get $xyz_rps) (i32.const 2)))
      (then
        (i64.const 2)
        return))

    ;; THEY HAVE PAPER
    ;; abc: 1, xyz: 0; they have paper, and we lose
    ;; so we have rock: 1
    (if (i32.and
          (i32.eq (local.get $abc_rps) (i32.const 1))
          (i32.eq (local.get $xyz_rps) (i32.const 0)))
      (then
        (i64.const 1)
        return))

    ;; abc: 1, xyz: 0; they have paper, and we win
    ;; so we have scissors: 3
    (if (i32.and
          (i32.eq (local.get $abc_rps) (i32.const 1))
          (i32.eq (local.get $xyz_rps) (i32.const 2)))
      (then
        (i64.const 3)
        return))

    ;; THEY HAVE SCISSORS
    ;; abc: 2, xyz: 0; they have scissors, and we lose
    ;; so we have paper: 2
    (if (i32.and
          (i32.eq (local.get $abc_rps) (i32.const 2))
          (i32.eq (local.get $xyz_rps) (i32.const 0)))
      (then
        (i64.const 2)
        return))

    ;; abc: 2, xyz: 2; they have scissors, and we win
    ;; so we have rock: 1
    (if (i32.and
          (i32.eq (local.get $abc_rps) (i32.const 2))
          (i32.eq (local.get $xyz_rps) (i32.const 2)))
      (then
        (i64.const 1)
        return))

    ;; otherwise return huge sentinel value indicating error
    (i64.const 23789347)
  )

  (func $score_win_lose_draw (param $char i32) (result i64)
    ;; if X, 88 then loss, or 0 points
    (if (i32.eq (local.get $char) (i32.const 88))
      (then
        (i64.const 0)
        return
        ))
    ;; if Y, 89 then draw, or 3 points
    (if (i32.eq (local.get $char) (i32.const 89))
      (then
        (i64.const 3)
        return
        ))
    ;; if Z, 90 then win, or 6 points
    (i64.const 6)
  )

  ;; reads an int from the input
  (func $readint (param $start_pos i32) (param $len i32) (result i64)
    (call $atoi
      (i32.add (i32.const 28) (local.get $start_pos))
      (local.get $len)
    )
  )

  (func $getc (param $i i32) (result i32)
    ;; beginning of string is 28
    (i32.load8_u (i32.add (i32.const 28) (local.get $i)))
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

  (func $print_int_backwards (param $num i64)
    (loop $loop
      (i64.rem_s (local.get $num) (i64.const 10))

      (i64.add (i64.const 48))
      (i32.wrap_i64)
      (call $putc)

      ;; divide input by 10
      (local.set $num (i64.div_s (local.get $num) (i64.const 10)))

      (i64.gt_s (local.get $num) (i64.const 0))
      br_if $loop
    )

    ;; print a newline
    (call $putc (i32.const 10))
  )

  ;; length is 4
  ;; offset is 3
  ;;
  ;; 1234
  (func $atoi (param $addr i32) (param $size i32) (result i64)
    ;; loop counter -- starts at 0
    (local $i i32)
    (local $acc i64)

    (loop $loop
      ;; multiply result by 10
      (i64.mul (local.get $acc) (i64.const 10))
      (local.set $acc)

      ;; push next char onto the stack
      (i32.add (local.get $addr) (local.get $i))
      (i64.load8_u)
      (i64.sub (i64.const 48))
      (i64.add (local.get $acc))
      (local.set $acc)

      ;; incr loop counter
      (local.set $i (i32.add (i32.const 1) (local.get $i)))
      (i32.lt_s (local.get $i) (local.get $size))
      br_if $loop
    )
    (local.get $acc)
  )
)

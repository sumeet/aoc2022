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

  ;;(data (i32.const 28) "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")
  (data (i32.const 28) "pqffvllhrhthvhshhpnhpnpqpvpvrpvpwvwjjdssmcsmccjvjmjjwnjwjwhjwwwzswwhvhwwlvvlbvbtbzbfbzbtbqbgbpbggwzggvjjdpdffbmffntncchtccbcffcjfjnjfnntssvtstzssmnnhrhlhbbwfwjfwjfwwbhhfhmmpsssbnssssfzzfpffdrdpdqqvnncjjgrjjmhhpqqcjqcjjzdzzpvvprrlglrrcmcqqtltdltddswsrrzzwgzzgssczcmzzmgmwgmggwwzttpccmcsmmvfvnvppzlzvzllgclggpfggfnfrfvrvwwvhwwvgwwrbbgfglflblzblzbznzhzffplffnrrcqqsgsvshvhlldhhvnhhmdddnssdvdwdwccggmddsmswwtctdtqqjsshhjzzdpdmpdmppjtjwjswjsjjjsdjjtrtbrbjjwwvnvppqphqhwhcwhwbbpgbbnhbnhhswwdswwlcczdztzbbbnwwtmmpvvgjjqgqdqzzdjdpjjnnffhccscvvchhbmbcbffpdpggvdvttpvpqqhggdtdhtdhhmghmgggzwgwrgwggwlggvpggcfcttzmtmgmvgmmpqmqlmqllsqqjbjwjsszczlzrzgrzzhshlhjjwttwnntbtjtjpplccqrqhrhssbmbttrddfvfwwjcwcvwcwwvpvggqwgwjgwgccvqqcmqqtqnqpnqnffdqfqhhqnhnmhmvhmhwwfrwrggnmmmcnmmgsszmzlmzmddcwwthtssgjsgjjgpgnppdqqcgqggzjgjngnrnggvffgddvtvctcftcftfnnnnhssbgsgwwthtqtltftqtnqttsrtrggwcgwcwmwgmgvmmzrmzrzjzmmcclmmtjmjhmmlhlwlppnpccbbrlrqrcrjrdrlrnngmnmvmcmzczztbblglccvzvppzspsddrzzlsllfzfsspnpdnpnvvvgmmpccmpcpgcpcwcddtmddgwgngqqcpqqlhqqczqqbvqqgdqgqmgmlmmvrrgfgzffbccldcdmmcmcgcngnghngngdngdndcncbbpqbbphbphpccpcwwjswwfttbqbsszccrbbdndsdrdqrqjrjjbmbtbdbbgbvgvcggwdwcccttqccnffjpjqqzpzlzvlljhhschhzlhhfhcfhchvcvtvtgvgzvzrvrdrgrwrjwjljhljlssszsqzsswhhmlhlrhlhzzgghjhzjjcllwrwtrrbdbrbnrnprnrffjvvphhvbbqbbscstsmslmlvmvrmmvvngnlnzzwqzzjqqsqbqrrtmrtmmfgmgrgjjtmjmrrddmrrqmrrjmjqmqnqmmcmlmfmffcgcclplffzvzwvzzjtztftqftqffjjpwjjbpjjggzdgzgwzzfrfvvhfvvwcvvbccfcvffpcpgpbbqhbbhmmzfmfvvnjvnjjhzhqqmffndndmmzhmmqnnlglvvjhjddvggqwgwdgwdggqbqgqrqlrrtptsswlssqwssbdsdrsddjsszjszjjpnjnvnjvnnmznmnddccpwwhshzzcfcqcwcddsjjmnjmjljwwgmglllqlhhctcvvqrvrrhfrrbcrrfbrfbrfrqffbwbqwbbjggsjjjnqqrqsqhhwnhnshnhhdjjqfqpqmmqgqgqggzmmnncrrpgglgqlqclqlsqqwnnfntnzttrnnmtmvvfppbrprzpzzdzvvtctnncpclpccsbbswwcscjssvhvhhqggzmgmqgmgwwgcwgccrllzhzzlzlbljbllmqqpjqqhrhqhjhbbjmjmhmddmwmcmvvmbbmvbmmznnwvwlwtllhwlwgwpgplgpgmgngjgglbglgmllvvlttgrrrlsrllghlggjdjwwfjwfjfvhjmgqnwhwpbdtzrphsqbmmvscslhbdzffsfshgsdjbqbwlgmrtschcnfhdlnndsvpwmwttfglpghhznmgfcjsdlwhnmfqvmpvhgpnnwtjfztbmtprqhsqtjwzhwcqjtjbtqwlcldnvggrwddmpllwnrqwdljwzfzqwcdwgqwvnthnrpcsfwrmqvbzjvzqnmdnfgtbzgtnrvblfwmhdsddgbffnjzvjzfpwglctpqhnqdvtblcchrlmndzhlsczgnsmnbwgnjngnjtlrdpfhqjrwcrqvcpspbtwcvgvvmpnwqjjpdpnslmcrcjnjmhqmrmfbcmrcmpbcbhpcvwqwflljfpgdvqhgdwgcphjqfnqzjjpsqnbtfzhftjtfcbhhcmmlwcfznsflfpphprrgvqwfgjcwfgjfsghzcbqrldwrjlzlbjhpgrbmgdpgzmfsqsphqbbslwwpzspccrhcfrgcjlfwhlcmzdcltbbpcrzglqgqntpwtmgstqlmcsqqbsqgmsmfznwcrfdgvsmnfqmwtsvqvlhwwjlrlhnsvcnrtwwmrjcgfncvlrcqrllndlvmrjpfjpgrrjcwhsqvlbtnlqgwjjqzwcvtvlnfnmqqshbcnqtcbvnwtwbfdgqmvnpmjhlsfdntfwwntvsrrsmspzqmglfnprjtdbmbgnplzzclsjpnzwdhcbhpfnqrgmgqtpfhgnfbqhrpmznbrshjhntzctslwhtgtjvpqhntmchhtncfjmbzcgnpcbpmldrtnpvrzqfftbjjcjlpwwgvmnstjghftcczjzfsftgzpfhbspqmrbfhcdfmqbrgrbsmjvgpbrnvbblwwvqzzpmqrspzvzppjfbgfftdvsdvmrjzhfslptzmgndnqqgmrrfnbbpvbmvpngwjhzvfbwfnzlrgwffvjsfdldfgchfjmnzfnzhwrwttrzlrhmnwvjjdqfmbpfllhrgmddjgnwjnbqwjnslcrdjrmnldcpsgzjpdhrpdfwhbvwhwnhcsmwcwstvqrcrqsnvjrzljfgbljfszchbsqnldgntvcscwqqmpnlwtlfmswtmvrlpzgbrjhtgjgpnhggnprpvwfqpjffqhtfvpnrptgrtwzzlvplgnfjmqphgmnssccrdndqgpljtwtntshrpgsjcdrpmccjnjdgmpmzbfhqjzphcswtwvvqcrwsjhtdqgrhqjmjjcrblpswcblnpzvfztqtbpgjcgngqmwrjtlmhvlsbmrdzwlgqlfqcqnsnjcnddssqbftjvnlgcwwfcgdpdmqrdsjmcnzrfrpnvjmbsltpzwjhjzqqvbgrltczbgvcpwdzqsvhddsbjgjgcmnldrfhnhddlvjcvsnghprjwlghhtghldcqsdcdgnmbcjglvjjvvlbhzczlmjsdqtdpzdtvfztgsdfjsdtfchvzcgvhjnnncmsrfvvmcsjjdftmlpczgvtwngssqmzlmsrrsrbhhhrnwqhmpcdvqmdsvvtsgsqfdcpgsdgzvmbzpbpgtcbshnvdzlmpnwmqrvnmrjprmvppjwfbjhlhzsfhqqzmpbclqvsvfrcqwprrcvqcbbwvnqfwnrgjhlwmgzpfspqrvqrhmqnwvzjrhvvgdgswlvzjjhjtdctlthlpzqhjvwwbpsclpgflcnsdshrqbhmczcwljqlndfnfrcdgmptpsltrcjccnpdchgnswdcpsslcslcjznzpgfhznhbgqhdqvddmqzdnmpshhdcjrsmfjllhfvjvmzzhzrvlbpzqngwmlwcmqnppqzncvjshfrpjlptvnqfrfcrfnbhwhpdqqvjhsqvsmprtgfrddwzjzlwhhqvjpfrwgwvwpszzsfzwjtwngdjfllhjrmqjtmvwsvggnswpqpjbtcrnhhhlzbrvhjdstnpctjlgsffrrbfdvjzhwsgthgfsqnvqdcjffsttlrjnhtqqdpfqpjtdgfwcdwzmwfvqgglsrmmqwbszclpzwldwcswpwfwldrfmmdndcptjbmnvgcpntqcdrcffvgnlpjmcqjpfmbmwjfpqzbzhqtqbzsghbnfvhphfzzhfznttpfrqwpmzjchpzzrdclhdltlqbjmjdfdjqlqbwptsghcnvtdscwgpqnlhhvsvglplhlrwpnzmdbsbrlhmpczzfz")


  (func $main (export "_start")
    (call $solve)
    (call $print_int_backwards)
  )

  (func $solve (result i32)
    (local $str_i i32)
    (local $chr1 i32)
    (local $chr2 i32)
    (local $chr3 i32)
    (local $chr4 i32)
    (loop $parse_loop
      (local.set $chr1
        (call $getc (i32.add (local.get $str_i) (i32.const 0))))
      (local.set $chr2
        (call $getc (i32.add (local.get $str_i) (i32.const 1))))
      (local.set $chr3
        (call $getc (i32.add (local.get $str_i) (i32.const 2))))
      (local.set $chr4
        (call $getc (i32.add (local.get $str_i) (i32.const 3))))

      ;; pushed 6 booleans on the stack
      (i32.ne (local.get $chr1) (local.get $chr2)) ;; 1
      (i32.ne (local.get $chr1) (local.get $chr3)) ;; 2
      (i32.ne (local.get $chr1) (local.get $chr4)) ;; 3
      (i32.ne (local.get $chr2) (local.get $chr3)) ;; 4
      (i32.ne (local.get $chr2) (local.get $chr4)) ;; 5
      (i32.ne (local.get $chr3) (local.get $chr4)) ;; 6

      (i32.and) ;; 1
      (i32.and) ;; 2
      (i32.and) ;; 3
      (i32.and) ;; 4
      (i32.and) ;; 5

      (if ;; they're not all equal
        (then
          (i32.add (local.get $str_i) (i32.const 4))
          (return)
        )
        (else
          (local.set $str_i (i32.add (i32.const 1) (local.get $str_i)))
          (br $parse_loop)
        )
      )

    )

    (i32.const 1337) ;; this should actually never happen
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
      (local.set $this_char (call $getc))

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

  (func $getc (param $i i32) (result i32)
    (i32.load8_u (i32.add (i32.const 28) (local.get $i)))
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

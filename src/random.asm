; Source: http://forums.nesdev.com/viewtopic.php?p=3747&sid=49b125812f72ba319ed11ece500847b5#p3747

; Requires two bytes in memory that don't get modified by anything else.
; They don't need to be next to each other. Set them to reseed the generator.

; Generate pseudo-random 8-bit value and return in A.
; Preserved: X, Y
random[\x\y]:
      ; See "linear-congruential random number generator" for more.
      ; rand = (rand * 5 + 0x3611) & 0xffff;
      ; return (rand >> 8) & 0xff;
      lda   RAND_H      ; multiply by 5
      sta   TEMP0
      lda   RAND_L
      asl   a           ; rand = rand * 4 + rand
      rol   TEMP0
      asl   a
      rol   TEMP0
      clc
      adc   RAND_L
      pha
      lda   TEMP0
      adc   RAND_H
      sta   RAND_H
      pla               ; rand = rand + 0x3611
      clc
      adc   #$11
      sta   RAND_L
      lda   RAND_H
      adc   #$36
      sta   RAND_H
      rts               ; return high 8 bits

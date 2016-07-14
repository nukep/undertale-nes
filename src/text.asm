macro write_text_simple src, length, x, y
  graphics.xy_to_addr.x = x
  graphics.xy_to_addr.y = y
  lda #<src
  sta write_text.src_lo
  lda #>src
  sta write_text.src_hi
  lda #<(graphics.xy_to_addr)
  sta write_text.dest_lo
  lda #>(graphics.xy_to_addr)
  sta write_text.dest_hi
  lda #length
  sta write_text.src_length
  jsr write_text
endm

macro write_text.from lookup
  lda write_text.src_length
  sta TEMP5
  ldy #0
-
  lda (write_text.src_lo), y
  sty TEMP6
  tay
  lda lookup,y
  sta DRAW_BUFFER,x
  inx
  ldy TEMP6
  iny
  dec TEMP5
  bne -
endm

write_text.src_lo=TEMP0
write_text.src_hi=TEMP1
write_text.dest_lo=TEMP2
write_text.dest_hi=TEMP3
write_text.src_length=TEMP4
write_text:
  ldx DRAW_BUFFER_SIZE
  lda write_text.src_length
  clc
  adc #3
  asl
  adc DRAW_BUFFER_SIZE
  sta DRAW_BUFFER_SIZE

  lda write_text.dest_hi
  sta DRAW_BUFFER,x
  lda write_text.dest_lo
  sta DRAW_BUFFER+1,x
  lda write_text.src_length
  sta DRAW_BUFFER+2,x
  inx
  inx
  inx
  write_text.from TEXT_LOOKUP_TOP

  lda write_text.dest_lo
  clc
  adc #32
  sta DRAW_BUFFER+1,x
  lda write_text.dest_hi
  adc #0
  sta DRAW_BUFFER,x
  lda write_text.src_length
  sta DRAW_BUFFER+2,x
  inx
  inx
  inx
  write_text.from TEXT_LOOKUP_BOTTOM
  rts

; Used for printing hexadecimal numbers
TEXT_LOOKUP_0=59
TEXT_LOOKUP_A=0

TEXT_LOOKUP_TOP:
  ; uppercase
  .db undertale_a.chr_40
  .db undertale_a.chr_41
  .db undertale_a.chr_42
  .db undertale_a.chr_43
  .db undertale_a.chr_44
  .db undertale_a.chr_45
  .db undertale_a.chr_46
  .db undertale_a.chr_47
  .db undertale_a.chr_48
  .db undertale_a.chr_49
  .db undertale_a.chr_4a
  .db undertale_a.chr_4b
  .db undertale_a.chr_4c
  .db undertale_a.chr_60
  .db undertale_a.chr_61
  .db undertale_a.chr_62
  .db undertale_a.chr_63
  .db undertale_a.chr_64
  .db undertale_a.chr_65
  .db undertale_a.chr_66
  .db undertale_a.chr_67
  .db undertale_a.chr_68
  .db undertale_a.chr_69
  .db undertale_a.chr_6a
  .db undertale_a.chr_6b
  .db undertale_a.chr_6c
  ; lowercase
  .db undertale_a.chr_80
  .db undertale_a.chr_81
  .db undertale_a.chr_82
  .db undertale_a.chr_83
  .db undertale_a.chr_84
  .db undertale_a.chr_85
  .db undertale_a.chr_86
  .db undertale_a.chr_87
  .db undertale_a.chr_88
  .db undertale_a.chr_89
  .db undertale_a.chr_8a
  .db undertale_a.chr_8b
  .db undertale_a.chr_8c
  .db undertale_a.chr_a0
  .db undertale_a.chr_a1
  .db undertale_a.chr_a2
  .db undertale_a.chr_a3
  .db undertale_a.chr_a4
  .db undertale_a.chr_a5
  .db undertale_a.chr_a6
  .db undertale_a.chr_a7
  .db undertale_a.chr_a8
  .db undertale_a.chr_a9
  .db undertale_a.chr_aa
  .db undertale_a.chr_ab
  .db undertale_a.chr_ac
  ; punct
  .db undertale_a.chr_2a
  .db undertale_a.chr_2b
  .db undertale_a.chr_2c
  .db undertale_a.chr_2d
  .db undertale_a.chr_00
  .db undertale_a.chr_2e
  .db undertale_a.chr_2f
  ; numbers
  .db undertale_a.chr_20
  .db undertale_a.chr_21
  .db undertale_a.chr_22
  .db undertale_a.chr_23
  .db undertale_a.chr_24
  .db undertale_a.chr_25
  .db undertale_a.chr_26
  .db undertale_a.chr_27
  .db undertale_a.chr_28
  .db undertale_a.chr_29

TEXT_LOOKUP_BOTTOM:
  ; uppercase
  .db undertale_a.chr_50
  .db undertale_a.chr_51
  .db undertale_a.chr_52
  .db undertale_a.chr_53
  .db undertale_a.chr_54
  .db undertale_a.chr_55
  .db undertale_a.chr_56
  .db undertale_a.chr_57
  .db undertale_a.chr_58
  .db undertale_a.chr_59
  .db undertale_a.chr_5a
  .db undertale_a.chr_5b
  .db undertale_a.chr_5c
  .db undertale_a.chr_70
  .db undertale_a.chr_71
  .db undertale_a.chr_72
  .db undertale_a.chr_73
  .db undertale_a.chr_74
  .db undertale_a.chr_75
  .db undertale_a.chr_76
  .db undertale_a.chr_77
  .db undertale_a.chr_78
  .db undertale_a.chr_79
  .db undertale_a.chr_7a
  .db undertale_a.chr_7b
  .db undertale_a.chr_7c
  ; lowercase
  .db undertale_a.chr_90
  .db undertale_a.chr_91
  .db undertale_a.chr_92
  .db undertale_a.chr_93
  .db undertale_a.chr_94
  .db undertale_a.chr_95
  .db undertale_a.chr_96
  .db undertale_a.chr_97
  .db undertale_a.chr_98
  .db undertale_a.chr_99
  .db undertale_a.chr_9a
  .db undertale_a.chr_9b
  .db undertale_a.chr_9c
  .db undertale_a.chr_b0
  .db undertale_a.chr_b1
  .db undertale_a.chr_b2
  .db undertale_a.chr_b3
  .db undertale_a.chr_b4
  .db undertale_a.chr_b5
  .db undertale_a.chr_b6
  .db undertale_a.chr_b7
  .db undertale_a.chr_b8
  .db undertale_a.chr_b9
  .db undertale_a.chr_ba
  .db undertale_a.chr_bb
  .db undertale_a.chr_bc
  ; punct
  .db undertale_a.chr_3a
  .db undertale_a.chr_3b
  .db undertale_a.chr_3c
  .db undertale_a.chr_3d
  .db undertale_a.chr_00
  .db undertale_a.chr_3e
  .db undertale_a.chr_3f
  ; numbers
  .db undertale_a.chr_30
  .db undertale_a.chr_31
  .db undertale_a.chr_32
  .db undertale_a.chr_33
  .db undertale_a.chr_34
  .db undertale_a.chr_35
  .db undertale_a.chr_36
  .db undertale_a.chr_37
  .db undertale_a.chr_38
  .db undertale_a.chr_39

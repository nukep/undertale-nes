; The screen is 32x30 tiles.

; PPU_ADDR = 0x2000 + y*32 + x

print_text.x=GENVAR0
print_text.y=GENVAR1
print_text.src_lo=GENVAR2
print_text.src_hi=GENVAR3
print_text.length=GENVAR4
print_text.x_beginning=GENVAR5
print_text:
  lda print_text.x
  sta print_text.x_beginning
  ldy #0
--
  ; We're about to draw 2 tiles. Ready? Here we go!
  ldx DRAW_BUFFER_SIZE

  ; PPU_ADDR_HI = 0x20 + y>>3
  ; PPU_ADDR_LO = x + y<<5
  lda print_text.y
  lsr_n 3
  ora #$20
  sta TEMP0
  lda print_text.y
  asl_n 5
  clc
  adc print_text.x
  sta DRAW_BUFFER+1,x
  ; The bottom half is on y + 1
  clc
  adc #$20
  sta DRAW_BUFFER+5,x
  lda TEMP0
  sta DRAW_BUFFER+0,x
  adc #0
  sta DRAW_BUFFER+4,x

  ; Drawbuffer item sizes
  lda #1
  sta DRAW_BUFFER+2,x
  sta DRAW_BUFFER+6,x

  ; Print two characters. We're using a double-height font.
  lda (print_text.src_lo), y
  cmp #$FF
  beq print_text.new_line
  sty TEMP0
  tay
  lda TEXT_LOOKUP_TOP, y
  sta DRAW_BUFFER+3,x
  lda TEXT_LOOKUP_BOTTOM, y
  sta DRAW_BUFFER+7,x
  ldy TEMP0
  inc print_text.x

  txa
  clc
  adc #8
  sta DRAW_BUFFER_SIZE

  ; Slow down the text printing to 5 characters per second
  ldx #(60/30)
-
  yield_xy
  dex
  bne -

  iny
  cpy print_text.length
  bne --
  rts

print_text.new_line:
  iny
  lda print_text.x_beginning
  sta print_text.x
  inc print_text.y
  inc print_text.y
  jmp --

macro initialize_text_generator src,length
  lda #<(src)
  sta_generator_field TEXT_GENERATOR, print_text.src_lo
  lda #>(src)
  sta_generator_field TEXT_GENERATOR, print_text.src_hi
  lda #(length)
  sta_generator_field TEXT_GENERATOR, print_text.length
  lda #2
  sta_generator_field TEXT_GENERATOR, print_text.x
  lda #17
  sta_generator_field TEXT_GENERATOR, print_text.y
  initialize_generator TEXT_GENERATOR, print_text
endm

print_debug_byte:
  sta TEMP0
  ; Write going down.
  lda #%00000100
  sta $2000
  lda TEMP0
  lsr
  lsr
  lsr
  lsr
  graphics.set_addr_to_xy 0,28
  jsr print_nibble
  lda TEMP0
  and #$0F
  graphics.set_addr_to_xy 1,28
print_nibble:
  cmp #10
  bcs +
  ; < 10
  ; C = 0
  adc #(TEXT_LOOKUP_0)
  tax
  lda TEXT_LOOKUP_TOP, x
  sta $2007
  lda TEXT_LOOKUP_BOTTOM, x
  sta $2007
  rts
+
  ; >= 10
  ; C = 1
  sbc #10
  tax
  lda TEXT_LOOKUP_TOP, x
  sta $2007
  lda TEXT_LOOKUP_BOTTOM, x
  sta $2007
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

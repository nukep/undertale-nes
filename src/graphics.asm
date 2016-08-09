; VRAM address: 0yyyNNYY YYYXXXXX
; yyy: fine Y scroll;
; NN: name table index;
; YYYYY: coarse Y scroll;
; XXXXX: coarse X scroll;
; xxx: fine X scroll (not part of the address);
; Source: http://forums.nesdev.com/viewtopic.php?p=105762#p105762

; PPU variables:
; * VRAM (16-bit)
; * AddressLatch (1-bit)
; * xxx (Fine X scroll) (3-bit)

; Reads:
; $2002 -> AddressLatch = 0

; Write:
; $2006 -> if AddressLatch is 0 -> toggle AddressLatch -> [--AAAAAA] A
; $2006 -> if AddressLatch is 1 -> toggle AddressLatch -> [BBBBBBBB] B
; $2005 -> if AddressLatch is 0 -> toggle AddressLatch -> [XXXXXxxx] C
; $2005 -> if AddressLatch is 1 -> toggle AddressLatch -> [YYYYYyyy] D

; 0yyyNNYY | YYYXXXXX
;   AAAAAA | BBBBBBBB
;          |    CCCCC
;  DDD  DD | DDD

macro graphics.set_vram_and_fine_x value fine_x
  ; Reset address latch
  ;lda $2002

  lda #>value
  sta $2006

  lda #(((value >> 12) & $03) | ((value >> 2) & $F8))
  sta $2005

  lda #(((value & $1F) << 3) | (fine_x & $03))
  sta $2005

  ; If you want AddressLatch to be 0
  ; Uncomment the following to leave AddressLatch at 1
  lda #<value
  sta $2006
endm


macro graphics.set_addr_to_xy x,y
  sta TEMP0_MACRO
  lda #>($2000 + y*32 + x)
  sta $2006
  lda #<($2000 + y*32 + x)
  sta $2006
  lda TEMP0_MACRO
endm

macro graphics.write_ppu_value tile
  lda #tile
  sta $2007
endm

graphics.xy_to_addr EQU ($2000 + (graphics.xy_to_addr.y)*32 + (graphics.xy_to_addr.x))

graphics.attribute_addr EQU ($23C0+(graphics.attribute_addr.y)/4*8+(graphics.attribute_addr.x)/4)

graphics.attribute_value_all EQU ((graphics.attribute_value_all.v<<0)|(graphics.attribute_value_all.v<<2)|(graphics.attribute_value_all.v<<4)|(graphics.attribute_value_all.v<<6))

graphics.attribute_value EQU ((graphics.attribute_value.topleft<<0) | (graphics.attribute_value.topright << 2) | (graphics.attribute_value.bottomleft << 4) | (graphics.attribute_value.bottomright << 6))

; Sprite OAM
; Y-1 (the value is what Y appears to be, then decremented by one)
; TILE
; ATTR
; X

graphics.initialize_nametable_0:
  graphics.set_vram_and_fine_x $2000,0

  lda #0
  ldx #0
  ldy #4
-
  sta $2007
  dex
  bne -
  dey
  bne -
  rts

graphics.draw_sprite0_hit:
  ldx OAM_SIZE
  txa
  clc
  adc #4
  sta OAM_SIZE

  lda #(15*8-1)
  sta OAM+0,x
  lda #undertale_b.chr_27
  sta OAM+1,x
  lda #0
  sta OAM+2,x
  sta OAM+3,x
  rts

graphics.draw_heart_sprite.x=TEMP0
graphics.draw_heart_sprite.y=TEMP1
graphics.draw_heart_sprite:
  ldx OAM_SIZE
  txa
  clc
  adc #(3*4)
  sta OAM_SIZE
  ; Y
  lda graphics.draw_heart_sprite.y
  sec
  sbc #1
  sta OAM+$0,x
  sta OAM+$4,x
  clc
  adc #8
  sta OAM+$8,x
  ; Tile
  lda #undertale_b.chr_07
  sta OAM+$1,x
  lda #undertale_b.chr_08
  sta OAM+$5,x
  lda #undertale_b.chr_17
  sta OAM+$9,x
  ; Attribute
  lda #0
  sta OAM+$2,x
  sta OAM+$6,x
  sta OAM+$A,x
  ; X
  lda graphics.draw_heart_sprite.x
  sta OAM+$3,x
  sta OAM+$B,x
  clc
  adc #8
  sta OAM+$7,x
  rts

graphics.draw_player_stats:
  graphics.set_addr_to_xy 2,24
  graphics.write_ppu_value undertale_a.chr_07
  graphics.write_ppu_value undertale_a.chr_08
  graphics.write_ppu_value undertale_a.chr_09
  graphics.write_ppu_value undertale_a.chr_00
  graphics.write_ppu_value undertale_a.chr_0a
  graphics.write_ppu_value undertale_a.chr_0b
  rts

graphics.draw_text_box:
  ;; TL TT TT TT .. TR
  ;; LL          .. RR
  ;; .. .. .. .. .. ..
  ;; BL BB BB BB .. BR
  TL=undertale_a.chr_9d
  TT=undertale_a.chr_9e
  TR=undertale_a.chr_9f
  LL=undertale_a.chr_ad
  RR=undertale_a.chr_af
  BL=undertale_a.chr_bd
  BB=undertale_a.chr_be
  BR=undertale_a.chr_bf

  width=30
  i=15
  graphics.set_addr_to_xy 1,i
  lda #TL
  sta $2007
  lda #TT
  ldx #(width-2)
-
  sta $2007
  dex
  bne -
  lda #TR
  sta $2007
  i=i+1

  rept 7
    graphics.set_addr_to_xy 1,i
    lda #LL
    sta $2007
    graphics.set_addr_to_xy width,i
    lda #RR
    sta $2007
    i=i+1
  endr

  graphics.set_addr_to_xy 1,i
  lda #BL
  sta $2007
  lda #BB
  ldx #(width-2)
-
  sta $2007
  dex
  bne -
  lda #BR
  sta $2007
  rts

graphics.clear_menu_text.y=TEMP0
graphics.clear_menu_text:
  ;3,17
  ldx DRAW_BUFFER_SIZE
  txa
  clc
  adc #(28+3)
  sta DRAW_BUFFER_SIZE

  graphics.xy_to_addr.x=2
  graphics.xy_to_addr.y=17
  lda graphics.clear_menu_text.y
  asl_n 5
  clc
  adc #<graphics.xy_to_addr
  sta DRAW_BUFFER+1,x
  lda #>graphics.xy_to_addr
  adc #0
  sta DRAW_BUFFER,x
  lda #28
  sta DRAW_BUFFER+2,x

  tay
  lda #0
-
  sta DRAW_BUFFER+3,x
  inx
  dey
  bne -
  rts

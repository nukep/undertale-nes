macro animate_lesser_dog.write_palette color1,color2
  ldx DRAW_BUFFER_SIZE
  txa
  clc
  adc #5
  sta DRAW_BUFFER_SIZE
  lda #$3F
  sta DRAW_BUFFER,x
  lda #$02
  sta DRAW_BUFFER+1,x
  ;lda #$02
  sta DRAW_BUFFER+2,x
  lda #color1
  sta DRAW_BUFFER+3,x
  lda #color2
  sta DRAW_BUFFER+4,x
endm

animate_lesser_dog:
  animate_lesser_dog.write_palette $30,$0F
  lda #24
  sta GENVAR0
-
  jsr yield
  dec GENVAR0
  bne -

  animate_lesser_dog.write_palette $0F,$30

  lda #24
  sta GENVAR0
-
  jsr yield
  dec GENVAR0
  bne -

  beq animate_lesser_dog

lesser_dog.head.yield_until_grow:
-
  jsr lesser_dog.head.draw_head

  jsr yield
  lda lesser_dog.head.grow
  beq -
  lda #0
  sta lesser_dog.head.grow
  rts

lesser_dog.head.neck.y:
  .db 5,5,5,4,3,2,2,1,1,1,0

lesser_dog.head.x=GENVAR0
lesser_dog.head.y=GENVAR1
; Set lesser_dog.head.grow to 1 before iterating to proceed the generator.
lesser_dog.head.grow=GENVAR2
lesser_dog.head:
  ; draw first white tiles: (15, 5)
  lda #(8*15+3)
  sta lesser_dog.head.x
  lda #(8*5-3)
  sta lesser_dog.head.y
  lda #0
  sta lesser_dog.head.grow
  i=0
  rept 11
    jsr lesser_dog.head.yield_until_grow
    lda lesser_dog.head.y
    sec
    sbc #5
    sta lesser_dog.head.y

    lda #15
    sta lesser_dog.head.draw_neck_tiles.x
    ldy #i
    i=i+1
    lda lesser_dog.head.neck.y,y
    sta lesser_dog.head.draw_neck_tiles.y
    jsr lesser_dog.head.draw_neck_tiles
  endr
  generator.end

macro lesser_dog.head.draw_head.tile index,offx,offy,tile
  B=OAM+(index*4)
  COLOR=1
  lda lesser_dog.head.y
  clc
  adc #(offy-1)
  sta B,x
  lda #tile
  sta B+1,x
  lda #COLOR
  sta B+2,x
  lda lesser_dog.head.x
  if offx != 0
    clc
    adc #(offx)
  endif
  sta B+3,x
endm

lesser_dog.head.draw_head:
  ldx OAM_SIZE
  txa
  clc
  adc #(4*8)
  sta OAM_SIZE

  lesser_dog.head.draw_head.tile 0,0,0,undertale_b.chr_47
  lesser_dog.head.draw_head.tile 1,8,0,undertale_b.chr_48
  lesser_dog.head.draw_head.tile 2,16,0,undertale_b.chr_49
  lesser_dog.head.draw_head.tile 3,0,8,undertale_b.chr_57
  lesser_dog.head.draw_head.tile 4,8,8,undertale_b.chr_58
  lesser_dog.head.draw_head.tile 5,16,8,undertale_b.chr_59
  lesser_dog.head.draw_head.tile 6,8,16,undertale_b.chr_68
  lesser_dog.head.draw_head.tile 7,16,16,undertale_b.chr_69

  rts

lesser_dog.head.draw_neck_tiles.x=TEMP0
lesser_dog.head.draw_neck_tiles.y=TEMP1
lesser_dog.head.draw_neck_tiles:
  ldx DRAW_BUFFER_SIZE
  txa
  clc
  adc #(3+3)
  sta DRAW_BUFFER_SIZE

  ; PPU_ADDR_HI = 0x20 + y>>3
  ; PPU_ADDR_LO = x + y<<5
  lda lesser_dog.head.draw_neck_tiles.y
  lsr_n 3
  ora #$20
  sta DRAW_BUFFER+0,x
  lda lesser_dog.head.draw_neck_tiles.y
  asl_n 5
  clc
  adc lesser_dog.head.draw_neck_tiles.x
  sta DRAW_BUFFER+1,x

  lda #3
  sta DRAW_BUFFER+2,x

  lda #undertale_b.chr_87
  sta DRAW_BUFFER+3,x
  lda #undertale_b.chr_88
  sta DRAW_BUFFER+4,x
  sta DRAW_BUFFER+5,x

  rts

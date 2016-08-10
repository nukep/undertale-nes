{bytes("lesser_dog.initial_palette", [
  0x00, 0x30, 0x00, 0x00,
  0x00, 0x27, 0x30, 0x27,
  0x00, 0x37, 0x30, 0x0D,
  0x00, 0x00, 0x00, 0x00,

  0x0D, 0x15, 0x02, 0x03,
  0x00, 0x30, 0x0D, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
])}

lesser_dog.nmi.menu_generator=GENERATOR0
lesser_dog.nmi.palette_swap_generator=GENERATOR1
lesser_dog.nmi.head_generator=GENERATOR2

lesser_dog.nmi:
  ; Draw sprite 0 for the next frame
  jsr graphics.draw_sprite0_hit

  generator.initialize lesser_dog.nmi.menu_generator, menu
  generator.initialize lesser_dog.nmi.palette_swap_generator, lesser_dog.palette_swap.generator
  generator.initialize lesser_dog.nmi.head_generator, lesser_dog.head.generator

  graphic_Options 0,25
  graphic_LesserDog 13,3

  jsr graphics.draw_text_box
  jsr graphics.draw_player_stats

  ; Draw Tile for sprite 0 to hit
  graphics.set_addr_to_xy 0,15
  lda #undertale_b.chr_27
  sta $2007

  memcpy_ppu $3F00, lesser_dog.initial_palette, lesser_dog.initial_palette.size
  generator.iterate lesser_dog.nmi.menu_generator
  generator.iterate lesser_dog.nmi.head_generator

  nmi.set_loop lesser_dog._nmi_loop
  rts

lesser_dog._nmi_loop:
  ; Scroll to the top-left
  graphics.set_vram_and_fine_x $2000, 0

  ; Turn off NMI and set $1000 Pattern Table for BG and SPR
  lda #%00011000
  sta $2000

  ; enable rendering
  lda #%00011110
  sta $2001

  ; This must be the first sprite!
  jsr graphics.draw_sprite0_hit

  generator.iterate lesser_dog.nmi.menu_generator
  generator.iterate TEXT_GENERATOR
  generator.iterate lesser_dog.nmi.palette_swap_generator
  joy.is_button_tapped BUTTON.START
  bne +
  lda #1
  generator.sta_field lesser_dog.nmi.head_generator, lesser_dog.head.grow
+
  generator.iterate lesser_dog.nmi.head_generator

  ; Wait until Sprite 0 Flag is cleared and also out of vblank
-
  bit $2002
  bvs -
  ; out of vblank
  ; sprite 0 flag is cleared.

  ; Wait until Sprite 0 Flag is set
-
  bit $2002
  bvc -
  ; sprite 0 hit

  ; Turn on NMI and set $0000 Pattern Table for BG
  lda #%10001000
  sta $2000

  rts

macro lesser_dog.palette_swap.write_palette color1,color2
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

lesser_dog.palette_swap.generator:
  lesser_dog.palette_swap.write_palette $30,$0F
  lda #24
  sta GENVAR0
-
  jsr yield
  dec GENVAR0
  bne -

  lesser_dog.palette_swap.write_palette $0F,$30

  lda #24
  sta GENVAR0
-
  jsr yield
  dec GENVAR0
  bne -

  beq lesser_dog.palette_swap.generator

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
lesser_dog.head.generator:
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

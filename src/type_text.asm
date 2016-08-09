type_text.x=GENVAR0
type_text.y=GENVAR1
type_text.src_lo=GENVAR2
type_text.src_hi=GENVAR3
type_text.length=GENVAR4
type_text.x_beginning=GENVAR5
type_text.generator:
  jsr sfx.text
  lda type_text.x
  sta type_text.x_beginning
  ldy #0
--
  ; We're about to draw 2 tiles. Ready? Here we go!
  ldx DRAW_BUFFER_SIZE

  ; PPU_ADDR_HI = 0x20 + y>>3
  ; PPU_ADDR_LO = x + y<<5
  lda type_text.y
  lsr_n 3
  ora #$20
  sta TEMP0
  lda type_text.y
  asl_n 5
  clc
  adc type_text.x
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
  lda (type_text.src_lo), y
  cmp #$FF
  beq type_text._new_line
  sty TEMP0
  tay
  lda TEXT_LOOKUP_TOP, y
  sta DRAW_BUFFER+3,x
  lda TEXT_LOOKUP_BOTTOM, y
  sta DRAW_BUFFER+7,x
  ldy TEMP0
  inc type_text.x

  txa
  clc
  adc #8
  sta DRAW_BUFFER_SIZE

  ; Print speed
  ldx #(60/30)

  joy.is_button_down BUTTON.A
  bne +
  ; If the A button is held down, speed up the printing
  ldx #1
+

-
  yield_xy
  dex
  bne -

  iny
  cpy type_text.length
  bne --

  jsr sfx.stop_text
  generator.end

type_text._new_line:
  iny
  lda type_text.x_beginning
  sta type_text.x
  inc type_text.y
  inc type_text.y
  jmp --

macro type_text.initialize_generator GENERATOR,src,length
  lda #<(src)
  generator.sta_field GENERATOR, type_text.src_lo
  lda #>(src)
  generator.sta_field GENERATOR, type_text.src_hi
  lda #(length)
  generator.sta_field GENERATOR, type_text.length
  lda #2
  generator.sta_field GENERATOR, type_text.x
  lda #17
  generator.sta_field GENERATOR, type_text.y
  generator.initialize GENERATOR, type_text.generator
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

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

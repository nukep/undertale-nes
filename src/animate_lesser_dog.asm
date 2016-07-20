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
  jsr draw_lesser_dog_sprites
  jsr yield
  dec GENVAR0
  bne -

  animate_lesser_dog.write_palette $0F,$30

  lda #24
  sta GENVAR0
-
  jsr draw_lesser_dog_sprites
  jsr yield
  dec GENVAR0
  bne -

  beq animate_lesser_dog

macro draw_lesser_dog_sprites.tile index,offx,offy,tile
  B=OAM+(index*4)
  COLOR=1
  lda draw_lesser_dog_sprites.y
  clc
  adc #(offy-1)
  sta B,x
  lda #tile
  sta B+1,x
  lda #COLOR
  sta B+2,x
  lda draw_lesser_dog_sprites.x
  if offx != 0
    clc
    adc #(offx)
  endif
  sta B+3,x
endm

draw_lesser_dog_sprites.x=TEMP0
draw_lesser_dog_sprites.y=TEMP1
draw_lesser_dog_sprites:
  ; hard code the x and y coordinates for now
  lda #(8*15+3)
  sta draw_lesser_dog_sprites.x
  lda #(8*5-3)
  sta draw_lesser_dog_sprites.y

  ldx OAM_SIZE
  txa
  clc
  adc #(4*8)
  sta OAM_SIZE

  draw_lesser_dog_sprites.tile 0,0,0,undertale_b.chr_47
  draw_lesser_dog_sprites.tile 1,8,0,undertale_b.chr_48
  draw_lesser_dog_sprites.tile 2,16,0,undertale_b.chr_49
  draw_lesser_dog_sprites.tile 3,0,8,undertale_b.chr_57
  draw_lesser_dog_sprites.tile 4,8,8,undertale_b.chr_58
  draw_lesser_dog_sprites.tile 5,16,8,undertale_b.chr_59
  draw_lesser_dog_sprites.tile 6,8,16,undertale_b.chr_68
  draw_lesser_dog_sprites.tile 7,16,16,undertale_b.chr_69

  rts

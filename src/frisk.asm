FRISK_X=15*8
FRISK_Y=12*8

macro frisk.draw_frisk
  lda #FRISK_X
  sta frisk.draw.x
  lda #FRISK_Y
  sta frisk.draw.y
  jsr frisk.draw
endm


{
  bytes("frisk.battle.HEART_X", [int(lerp(16*8-1, 8, i/40)) for i in range(40)])
}

{
  bytes("frisk.battle.HEART_Y", [int(lerp(14*8, 26*8+1, i/40)) for i in range(40)])
}

frisk.battle.counter=GENVAR0
frisk.battle.can_start_battle=GENVAR1
frisk.battle:
  lda #0
  sta frisk.battle.can_start_battle
  ; Frisk just stands there for a moment, looking cool
  lda #40
  sta frisk.battle.counter
-
  frisk.draw_frisk
  jsr yield
  dec frisk.battle.counter
  bne -

  ; Encounter!
  jsr sfx.alert

  lda #26
  sta frisk.battle.counter
-
  frisk.draw_frisk
  jsr frisk.draw.alert
  jsr yield
  dec frisk.battle.counter
  bne -

  ; Chk chk chk...
  rept 3
  jsr sfx.step
  lda #4
  sta frisk.battle.counter
-
  ldx #0
  lda frisk.battle.HEART_X,x
  sta graphics.draw_heart_sprite.x
  lda frisk.battle.HEART_Y,x
  sta graphics.draw_heart_sprite.y
  jsr graphics.draw_heart_sprite
  frisk.draw_frisk
  jsr yield
  dec frisk.battle.counter
  bne -
  lda #4
  sta frisk.battle.counter
-
  frisk.draw_frisk
  jsr yield
  dec frisk.battle.counter
  bne -
  endr

  ; Heart move
  jsr sfx.start_battle

  lda #0
  sta frisk.battle.counter

-
  ldx frisk.battle.counter
  lda frisk.battle.HEART_X,x
  sta graphics.draw_heart_sprite.x
  lda frisk.battle.HEART_Y,x
  sta graphics.draw_heart_sprite.y
  jsr graphics.draw_heart_sprite

  jsr yield
  inc frisk.battle.counter
  lda #frisk.battle.HEART_X.size
  cmp frisk.battle.counter
  bne -
  lda #1
  sta frisk.battle.can_start_battle
  generator.end

macro frisk.draw.tile o, offx, offy, tile, color
  B=OAM+(o*4)
  lda frisk.draw.y
  clc
  adc #(offy-1)
  sta B,x
  lda #tile
  sta B+1,x
  lda #(color)
  sta B+2,x
  lda frisk.draw.x
  if offx != 0
    clc
    adc #(offx)
  endif
  sta B+3,x
endm

frisk.draw.x=TEMP0
frisk.draw.y=TEMP1
frisk.draw:
  ldx OAM_SIZE
  txa
  clc
  adc #(14*4)
  sta OAM_SIZE

  ; Shirt stripes
  frisk.draw.tile 0, 7, 16, undertale_b.chr_0c, 2
  frisk.draw.tile 1, 9, 16, undertale_b.chr_0c, 2

  ; Frisk
  frisk.draw.tile 2, 0, 0, undertale_b.chr_09, 1
  frisk.draw.tile 3, 8, 0, undertale_b.chr_0a, 1
  frisk.draw.tile 4, 16, 0, undertale_b.chr_0b, 1

  frisk.draw.tile 5, 0, 8, undertale_b.chr_19, 1
  frisk.draw.tile 6, 8, 8, undertale_b.chr_1a, 1
  frisk.draw.tile 7, 16, 8, undertale_b.chr_1b, 1

  frisk.draw.tile 8, 0, 16, undertale_b.chr_29, 1
  frisk.draw.tile 9, 8, 16, undertale_b.chr_2a, 1
  frisk.draw.tile 10, 16, 16, undertale_b.chr_2b, 1

  frisk.draw.tile 11, 0, 24, undertale_b.chr_39, 1
  frisk.draw.tile 12, 8, 24, undertale_b.chr_3a, 1
  frisk.draw.tile 13, 16, 24, undertale_b.chr_3b, 1
  rts

frisk.draw.alert:
  ldx OAM_SIZE
  txa
  clc
  adc #(3*4)
  sta OAM_SIZE

  frisk.draw.tile 0, 6, -14, undertale_b.chr_1c, 3
  frisk.draw.tile 1, 14, -14, undertale_b.chr_1d, 3
  frisk.draw.tile 2, 6, -6, undertale_b.chr_2c, 3
  rts

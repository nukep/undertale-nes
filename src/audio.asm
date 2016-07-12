audio_init:
  ; enable all channels
  lda #$0F
  sta $4015
  lda #0
  sta $4003
  rts

play_select_sfx:
  lda #%10111111
  sta $4000
  lda #0
  sta $4001
  lda #$40
  sta $4002
  lda #0
  sta $4003

  ldx #4
-
  yield_axy
  dex
  bne -
  lda #0
  sta $4000
  sta $4001
  sta $4002
  sta $4003
  rts

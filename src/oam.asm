oam.write:
  ; Write to the OAM
  lda #OAM/$100
  sta $4014
  lda #0
  sta OAM_SIZE
  rts

oam.init:
  lda #0
  sta OAM_SIZE
  ;jmp oam.hide_unwritten_oam
oam.hide_unwritten_oam:
  ; Hide all sprites that weren't written to in the previous frame
  ; TODO - only hide changes, not the entire remainer of the OAM page.
  lda #>OAM
  sta TEMP1
  ldy #0
  lda OAM_SIZE
-
  sta TEMP0
  lda #$FF
  sta (TEMP0),y
  lda TEMP0
  clc
  adc #4
  bne -
  rts

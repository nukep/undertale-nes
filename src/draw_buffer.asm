draw_buffer.init:
  lda #0
  sta DRAW_BUFFER_SIZE
  rts

; Draw buffer structure:
;struct draw_buffer_item {
;  byte addr_hi;
;  byte addr_lo;
;  byte size;   // must be > 0
;  byte data[size];
;}
draw_buffer.write:
  lda DRAW_BUFFER_SIZE
  beq @finish
  ldx #0
@draw_item:
  lda DRAW_BUFFER,x
  sta $2006
  inx
  lda DRAW_BUFFER,x
  sta $2006
  inx
  lda DRAW_BUFFER,x
  tay
  inx
  ; TODO maybe
  ; batch in multiples of a larger amount to avoid overhead of looping.
@write_data:
  lda DRAW_BUFFER,x
  sta $2007
  inx
  dey
  bne @write_data
  cpx DRAW_BUFFER_SIZE
  bne @draw_item
@finish:
  lda #0
  sta DRAW_BUFFER_SIZE
  rts

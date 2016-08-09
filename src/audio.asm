; Our audio system doesn't support hardware sweeps. They're hard and annoying.
; Instead, channels are controlled at 1/60 second precision, frame-by-frame.

; Ranging from A0 to B7
{lookup_table_lo_hi("NOTE_PERIODS", [
  midi_note_to_period(n) for n in range(midi_note("c0"), midi_note("b7")+1)
])}

audio.init:
  ; enable all channels
  lda #$0F
  sta $4015
  rts

macro audio.set_if_different n
  cmp LAST_400x+(n-$4000)
  beq +
  sta LAST_400x+(n-$4000)
  sta n
+
endm

audio.play_sq1:
  lda SQ1_DUTY
  lsr
  ror
  ror
  ora SQ1_VOLUME
  ora #%00110000
  audio.set_if_different $4000

  lda #0
  audio.set_if_different $4001

  ldx SQ1_NOTE
  lda NOTE_PERIODS.lo,x
  audio.set_if_different $4002
  lda NOTE_PERIODS.hi,x
  audio.set_if_different $4003
  rts

audio.play_noise:
  lda NOISE_VOLUME
  ora #%00110000
  sta $400C

  lda NOISE_SHORT
  beq +
  lda #%10000000
+
  ora NOISE_PERIOD
  sta $400E

  lda #0
  sta $400F

  rts

audio.mute_all_channels:
  lda #0
  sta SQ1_VOLUME
  sta SQ2_VOLUME
  sta TRI_VOLUME
  sta NOISE_VOLUME
  rts

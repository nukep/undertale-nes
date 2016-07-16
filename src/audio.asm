; Ranging from A0 to B7
{lookup_table_lo_hi("NOTE_PERIODS", [
  midi_note_to_period(n) for n in range(midi_note("c0"), midi_note("b7")+1)
])}

audio_init:
  ; enable all channels
  lda #$0F
  sta $4015
  lda #0
  sta $4003
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

audio.mute_all_channels:
  lda #0
  sta SQ1_VOLUME
  sta SQ2_VOLUME
  sta TRI_VOLUME
  sta NOISE_VOLUME
  rts

audio.play_choose_sfx:
  initialize_generator SFX_GENERATOR, audio.play_choose_sfx.generator
  rts

audio.play_choose_sfx.generator:
  {simple_set_sq1("b5")}
  jsr yield
  {simple_set_sq1("b5", 2, 8)}

  generator.end

audio.play_select_sfx:
  initialize_generator SFX_GENERATOR, audio.play_select_sfx.generator
  rts

audio.play_select_sfx.generator:
  {simple_set_sq1("g#5")}
  jsr yield
  {simple_set_sq1("g#5")}
  jsr yield

  {simple_set_sq1("c#6")}
  jsr yield
  {simple_set_sq1("c#6")}
  jsr yield

  {simple_set_sq1("f#6")}
  jsr yield
  {simple_set_sq1("f#6")}

  generator.end

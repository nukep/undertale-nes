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

audio.play_choose_sfx:
  initialize_generator SFX_GENERATOR, audio.play_choose_sfx.generator
  rts

audio.play_choose_sfx.generator:
  {simple_set_sq1("b5")}
  jsr yield
  {simple_set_sq1("b5", 2, 8)}

  generator.end

audio.play_alert_sfx:
  initialize_generator SFX_GENERATOR, audio.play_alert_sfx.generator
  rts

audio.play_alert_sfx.generator:
  {cat([
    cat([
      cat([simple_set_sq1(note, duty=duty), "jsr yield"])
      for duty in [3, 2]
    ])
    for note in ["a#4", "e5", "c5", "f#5", "e5", "g#5"]
  ])}

  generator.end

audio.play_start_battle_sfx:
  initialize_generator SFX_GENERATOR, audio.play_start_battle_sfx.generator
  rts

audio.play_start_battle_sfx.generator:
  {cat([
    cat([
      cat([simple_set_sq1(note, volume=volume, duty=3), "jsr yield"])
      for volume in [10, 15]
    ])
    for note in ["g5", "d5", "a4", "e4", "b3", "f#3", "c#3", "g#2"]
  ])}

  generator.end

audio.play_step_sfx:
  initialize_generator SFX_GENERATOR, audio.play_step_sfx.generator
  rts

audio.play_step_sfx.generator:
  {simple_set_noise(9, short=True)}
  jsr yield
  {simple_set_noise(9)}
  jsr yield
  {simple_set_noise(9)}
  generator.end

audio.play_select_sfx:
  initialize_generator SFX_GENERATOR, audio.play_select_sfx.generator
  rts

audio.play_select_sfx.generator:
  {cat([
    cat([
      cat([simple_set_sq1(note, volume=volume, duty=2), "jsr yield"]*2)
    ])
    for note,volume in [
      ("g#5", 15), ("c#6", 15), ("f#6", 15),
      ("c#6", 4), ("f#6", 4),
      ("c#6", 2), ("f#6", 2)
    ]
  ])}

  generator.end

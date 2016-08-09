
audio.play_choose_sfx:
  generator.initialize SFX_GENERATOR, audio.play_choose_sfx.generator
  rts

audio.play_choose_sfx.generator:
  {simple_set_sq1("b5")}
  jsr yield
  {simple_set_sq1("b5", 2, 8)}

  generator.end

audio.play_alert_sfx:
  generator.initialize SFX_GENERATOR, audio.play_alert_sfx.generator
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
  generator.initialize SFX_GENERATOR, audio.play_start_battle_sfx.generator
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
  generator.initialize SFX_GENERATOR, audio.play_step_sfx.generator
  rts

audio.play_step_sfx.generator:
  {simple_set_noise(9, short=True)}
  jsr yield
  {simple_set_noise(9)}
  jsr yield
  {simple_set_noise(9)}
  generator.end

audio.play_select_sfx:
  generator.initialize SFX_GENERATOR, audio.play_select_sfx.generator
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

audio.play_text_sfx:
  generator.initialize TEXT_SFX_GENERATOR, audio.play_text_sfx.generator
  rts

audio.stop_text_sfx:
  generator.stop TEXT_SFX_GENERATOR
  rts

audio.play_text_sfx.generator:
--
  generator.initialize SFX_GENERATOR, audio.play_text_sfx_sfx.generator

  ; Get a random number between 2 and 6
  jsr random[\x\y]
  and #$03
  clc
  adc #2

  tay
-
  phy
  jsr yield
  ply
  dey
  bne -
  jmp --

audio.play_text_sfx_sfx.generator:
  {cat([
    cat([simple_set_noise(period, volume, short), "jsr yield"])
    for period,volume,short in zip(
      [9,3,3,3],
      [7,4,2,0],
      [True,False,False,False]
    )
  ])}
  generator.end

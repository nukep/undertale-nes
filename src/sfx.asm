sfx.choose:
  generator.initialize SFX_GENERATOR, sfx.choose.generator
  rts

sfx.choose.generator:
  {simple_set_sq1("b5")}
  jsr yield
  {simple_set_sq1("b5", 2, 8)}

  generator.end

sfx.alert:
  generator.initialize SFX_GENERATOR, sfx.alert.generator
  rts

sfx.alert.generator:
  {cat([
    cat([
      cat([simple_set_sq1(note, duty=duty), "jsr yield"])
      for duty in [3, 2]
    ])
    for note in ["a#4", "e5", "c5", "f#5", "e5", "g#5"]
  ])}

  generator.end

sfx.start_battle:
  generator.initialize SFX_GENERATOR, sfx.start_battle.generator
  rts

sfx.start_battle.generator:
  {cat([
    cat([
      cat([simple_set_sq1(note, volume=volume, duty=3), "jsr yield"])
      for volume in [10, 15]
    ])
    for note in ["g5", "d5", "a4", "e4", "b3", "f#3", "c#3", "g#2"]
  ])}

  generator.end

sfx.step:
  generator.initialize SFX_GENERATOR, sfx.step.generator
  rts

sfx.step.generator:
  {simple_set_noise(9, short=True)}
  jsr yield
  {simple_set_noise(9)}
  jsr yield
  {simple_set_noise(9)}
  generator.end

sfx.select:
  generator.initialize SFX_GENERATOR, sfx.select.generator
  rts

sfx.select.generator:
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

sfx.text:
  generator.initialize TEXT_SFX_GENERATOR, sfx.text.generator
  rts

sfx.stop_text:
  generator.stop TEXT_SFX_GENERATOR
  rts

sfx.text.generator:
--
  generator.initialize SFX_GENERATOR, sfx.text_sfx.generator

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

sfx.text_sfx.generator:
  {cat([
    cat([simple_set_noise(period, volume, short), "jsr yield"])
    for period,volume,short in zip(
      [9,3,3,3],
      [7,4,2,0],
      [True,False,False,False]
    )
  ])}
  generator.end

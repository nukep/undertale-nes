macro nmi.set_loop address
  lda #<(address)
  sta NMI_LOOP_LO
  lda #>(address)
  sta NMI_LOOP_HI
endm

macro nmi.set_loop_here
  lda #<(@here)
  sta NMI_LOOP_LO
  lda #>(@here)
  sta NMI_LOOP_HI
@here:
endm

nmi:
  ; VBlank...

  ; disable rendering (leave NMI on)
  lda #%10000000
  sta $2000
  lda #0
  sta $2001

  jsr joy.read

  jsr graphics.write_draw_buffer
  jsr graphics.write_oam
  ; There should still be some VBlank cycles left...
  jsr audio.play_sq1
  jsr audio.play_noise
  jsr audio.mute_all_channels

  jsr @call_nmi_loop

  ; Perform any processing before vblank so that we don't do it there
  iterate_generator SFX_GENERATOR
  inc $FF
  jsr graphics.hide_unwritten_oam
  rti

@call_nmi_loop:
  jmp (NMI_LOOP_LO)

nmi.main:
  nmi.set_loop nmi.frisk
  rts

{bytes("nmi.frisk.initial_palette", [
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,

  0x0D, 0x15, 0x00, 0x00,
  0x00, 0x07, 0x28, 0x22,
  0x00, 0x24, 0x00, 0x00,
  0x00, 0x0F, 0x30, 0x00
])}

nmi.frisk.transition_generator=GENERATOR0

nmi.frisk:
  ; Initiailization
  memcpy_ppu $3F00, nmi.frisk.initial_palette, nmi.frisk.initial_palette.size

  initialize_generator nmi.frisk.transition_generator, frisk.battle
  iterate_generator nmi.frisk.transition_generator

  nmi.set_loop nmi.frisk.loop
  rts

nmi.frisk.loop:
  ; Scroll to the top-left
  graphics.set_vram_and_fine_x $2000, 0

  ; Set $1000 Pattern Table for BG and SPR
  lda #%10011000
  sta $2000

  ; enable rendering
  lda #%00011110
  sta $2001

  iterate_generator nmi.frisk.transition_generator
  lda frisk.battle.can_start_battle
  beq +
  nmi.set_loop nmi.battle
+

  rts

{bytes("nmi.battle.initial_palette", [
  0x00, 0x30, 0x00, 0x00,
  0x00, 0x27, 0x30, 0x27,
  0x00, 0x37, 0x30, 0x0D,
  0x00, 0x00, 0x00, 0x00,

  0x0D, 0x15, 0x02, 0x03,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
])}

nmi.battle.menu_generator=GENERATOR0
nmi.battle.lesser_dog_generator=GENERATOR1

nmi.battle:
  ; Draw sprite 0 for the next frame
  jsr graphics.draw_sprite0_hit

  initialize_generator nmi.battle.menu_generator, menu
  initialize_generator nmi.battle.lesser_dog_generator, animate_lesser_dog

  graphic_Options 0,25
  graphic_LesserDog 13,3

  jsr graphics.draw_text_box
  jsr graphics.draw_player_stats

  ; Draw Tile for sprite 0 to hit
  graphics.set_addr_to_xy 0,15
  lda #undertale_b.chr_27
  sta $2007

  memcpy_ppu $3F00, nmi.battle.initial_palette, nmi.battle.initial_palette.size
  iterate_generator nmi.battle.menu_generator

  nmi.set_loop nmi.battle.loop
  rts

nmi.battle.loop:
  ; Scroll to the top-left
  graphics.set_vram_and_fine_x $2000, 0

  ; Turn off NMI and set $1000 Pattern Table for BG and SPR
  lda #%00011000
  sta $2000

  ; enable rendering
  lda #%00011110
  sta $2001

  ; This must be the first sprite!
  jsr graphics.draw_sprite0_hit

  iterate_generator nmi.battle.menu_generator
  iterate_generator TEXT_GENERATOR
  iterate_generator nmi.battle.lesser_dog_generator

  ; Wait until Sprite 0 Flag is cleared and also out of vblank
-
  bit $2002
  bvs -
  ; out of vblank
  ; sprite 0 flag is cleared.

  ; Wait until Sprite 0 Flag is set
-
  bit $2002
  bvc -
  ; sprite 0 hit

  ; Turn on NMI and set $0000 Pattern Table for BG
  lda #%10001000
  sta $2000

  rts

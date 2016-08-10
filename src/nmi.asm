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

  jsr draw_buffer.write
  jsr oam.write
  ; There should still be some VBlank cycles left...
  jsr audio.play_sq1
  jsr audio.play_noise
  jsr audio.mute_all_channels

  jsr @call_nmi_loop

  ; Perform any processing before vblank so that we don't do it there
  generator.iterate TEXT_SFX_GENERATOR
  generator.iterate SFX_GENERATOR
  inc $FF
  jsr oam.hide_unwritten_oam
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
  0x00, 0x14, 0x00, 0x00,
  0x00, 0x0F, 0x30, 0x00
])}

nmi.frisk.transition_generator=GENERATOR0

nmi.frisk:
  ; Initiailization
  memcpy_ppu $3F00, nmi.frisk.initial_palette, nmi.frisk.initial_palette.size

  generator.initialize nmi.frisk.transition_generator, frisk.battle
  generator.iterate nmi.frisk.transition_generator

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

  generator.iterate nmi.frisk.transition_generator
  lda frisk.battle.can_start_battle
  beq +
  nmi.set_loop lesser_dog.nmi
+

  rts

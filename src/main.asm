{include("ines-header.asm")}

org $8000

include "undertale_a.chr.asm"
include "undertale_b.chr.asm"
include "graphic_LesserDog.asm"
include "graphic_Options.asm"

{include("variables.asm")}
{include("random.asm")}
{include("generator.asm")}
{include("mem.asm")}
{include("extended-instructions.asm")}
{include("joy.asm")}
{include("audio.asm")}
{include("sfx.asm")}
{include("graphics.asm")}
{include("draw_buffer.asm")}
{include("oam.asm")}
{include("draw_text.asm")}
{include("type_text.asm")}
{include("frisk.asm")}
{include("nmi.asm")}
{include("lesser_dog/mod.asm")}

reset:
  sei        ; ignore IRQs
  cld        ; disable decimal mode
  ldx #$40
  stx $4017  ; disable APU frame IRQ
  ldx #$ff
  txs        ; Set up stack
  inx        ; now X = 0
  stx $2000  ; disable NMI
  stx $2001  ; disable rendering
  stx $4010  ; disable DMC IRQs

  ; Optional (omitted):
  ; Set up mapper and jmp to further init code here.

  ; If the user presses Reset during vblank, the PPU may reset
  ; with the vblank flag still true.  This has about a 1 in 13
  ; chance of happening on NTSC or 2 in 9 on PAL.  Clear the
  ; flag now so the @vblankwait1 loop sees an actual vblank.
  bit $2002

  ; First of two waits for vertical blank to make sure that the
  ; PPU has stabilized
-
  bit $2002
  bpl -

  ; We now have about 30,000 cycles to burn before the PPU stabilizes.
  ; One thing we can do with this time is put RAM in a known state.
  ; Here we fill it with $00, which matches what (say) a C compiler
  ; expects for BSS.  Conveniently, X is still 0.
  txa
-
  sta $000,x
  sta $100,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x  ; Remove this if you're storing reset-persistent data

  ; We skipped $200,x on purpose.  Usually, RAM page 2 is used for the
  ; display list to be copied to OAM.  OAM needs to be initialized to
  ; $EF-$FF, not 0, or you'll get a bunch of garbage sprites at (0, 0).

  inx
  bne -

  ; Other things you can do between vblank waits are set up audio
  ; or set up other mapper registers.

-
  bit $2002
  bpl -

  ; Enable NMI
  lda #%10000000
  sta $2000

  jsr draw_buffer.init
  jsr oam.init
  jsr joy.init
  jsr audio.init
  jsr graphics.initialize_nametable_0
  generator.stop TEXT_SFX_GENERATOR
  generator.stop SFX_GENERATOR

  nmi.set_loop nmi.main

  ; Loop the reset thread forever.
  ; The NMI thread will take care of things from here on.
reset.loop:
  jmp reset.loop

irq:
  rti

org $FFFA
.dw nmi
.dw reset
.dw irq

incbin "undertale_a.chr"
align $1000
incbin "undertale_b.chr"
align $1000

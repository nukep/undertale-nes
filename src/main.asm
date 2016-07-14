{include("ines-header.asm")}

org $8000

include "undertale_a.chr.asm"
include "undertale_b.chr.asm"
include "graphic_LesserDog.asm"
include "graphic_Options.asm"

{bytes("test_palette", [
  0x00, 0x30, 0x00, 0x00,
  0x00, 0x27, 0x30, 0x27,
  0x00, 0x37, 0x30, 0x0D,
  0x00, 0x00, 0x00, 0x00,

  0x0D, 0x15, 0x02, 0x03,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
])}

{include("variables.asm")}
{include("generator.asm")}
{include("mem.asm")}
{include("extended-instructions.asm")}
{include("joy.asm")}
{include("audio.asm")}
{include("graphics.asm")}
{include("text.asm")}
{include("print-text.asm")}
{include("animate_lesser_dog.asm")}
{include("menu.asm")}
{include("battle.asm")}

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

  lda #0
  sta $2000  ; disable NMI
  sta $2001  ; disable rendering

  initialize_generator MENU_GENERATOR, menu
  clear_generator SFX_GENERATOR
  initialize_generator LESSER_DOG_GENERATOR, animate_lesser_dog

  jsr graphics.draw_buffer_init
  jsr graphics.oam_init
  jsr joy.init
  jsr audio_init
  jsr graphics.initialize_nametable_0

  graphic_Options 0,25
  graphic_LesserDog 13,3

  jsr graphics.draw_text_box
  jsr graphics.draw_player_stats

  ; Draw Tile for sprite 0 to hit
  graphics.set_addr_to_xy 0,15
  lda #undertale_b.chr_27
  sta $2007

  jsr graphics.write_oam

  memcpy_ppu $3F00, test_palette, test_palette.size

  lda #0
  sta SCREEN_SPLIT_ENABLED

  lda #%10000000
  sta $2000
  lda #0
  sta $2001

loop:
  jmp loop

nmi:
  ; disable rendering
  lda #0
  sta $2000
  sta $2001

  jsr joy.read

  lda DRAW_BUFFER_SIZE
  jsr print_debug_byte
  lda #0
  sta $2000
  sta $2001

  jsr graphics.write_draw_buffer

  ;iterate_generator SFX_GENERATOR

  ; Scroll to the top-left
  graphics.set_vram_and_fine_x $2000, 0

  ; Turn off NMI and set $1000 Pattern Table for BG and SPR
  lda #%00011000
  sta $2000

  ; enable rendering
  lda #%00011110
  sta $2001

  jsr graphics.write_oam
nmi_no_ppu_after_this_point:
  lda SCREEN_SPLIT_ENABLED
  pha

  ; This must be the first sprite!
  jsr graphics.draw_sprite0_hit
  lda #1
  sta SCREEN_SPLIT_ENABLED

  iterate_generator MENU_GENERATOR
  iterate_generator TEXT_GENERATOR
  iterate_generator LESSER_DOG_GENERATOR

  pla ; SCREEN_SPLIT_ENABLED
  bne +
  jsr graphics.hide_unwritten_oam
  lda #%10011000
  sta $2000
  rti
+

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

  jsr graphics.hide_unwritten_oam
  ; Nothing else to do!

  rti

irq:
  ;inc $FE
  rti

org $FFFA
.dw nmi
.dw reset
.dw irq

incbin "undertale_a.chr"
align $1000
incbin "undertale_b.chr"
align $1000

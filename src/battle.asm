lesser_dog_battle:
  ldx #60
-
  phx
  jsr yield
  plx
  dex
  bne -

  generator.empty_current_stack
  jmp menu

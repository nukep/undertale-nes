lesser_dog_battle:
  ldx #60
-
  phx
  jsr yield
  plx
  dex
  bne -

  empty_current_generator_stack
  jmp menu

macro asl_n n
  rept n
  asl
  endr
endm

macro lsr_n n
  rept n
  lsr
  endr
endm

macro phx
  sta TEMP0_MACRO
  txa
  pha
  lda TEMP0_MACRO
endm

macro plx
  sta TEMP0_MACRO
  pla
  tax
  lda TEMP0_MACRO
endm

; 11 cycles
macro phy
  sta TEMP0_MACRO
  tya
  pha
  lda TEMP0_MACRO
endm

; 12 cycles
macro ply
  sta TEMP0_MACRO
  pla
  tay
  lda TEMP0_MACRO
endm

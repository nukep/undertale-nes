;struct GeneratorInfo {
;  byte stack_size;
;  byte locals[6];
;}
GeneratorInfo.stack_size = 0
GeneratorInfo.locals = 1
GeneratorInfo.locals.size = 6    ; depends on GENVAR0 to GENVAR5
GeneratorInfo.size = GeneratorInfo.locals+GeneratorInfo.locals.size

; There is a stack size limit of 127 bytes.
; Some metrics:
;  Iteration and yield_axy takes 284 CPU cycles.
;  Iteration and immediate yield takes 147 CPU cycles.
;  Loading stack byte: 14 cycles
;  Saving stack byte: 19 cycles

; Yield and save the A X Y and flags registers.
; This is really expensive! This macro takes up four bytes of stack space.
; (19+14)*4 = 132 cycles.
; The subroutine adds an additional 36 cycles.
; 132 + 36 = 168 cycles.
macro yield_axyp
  pha ; 3
  txa ; 2
  pha ; 3
  tya ; 2
  pha ; 3
  php ; 3
  jsr yield
  plp ; 4
  pla ; 4
  tay ; 2
  pla ; 4
  tax ; 2
  pla ; 4
endm

macro yield_xy
txa ; 2
pha ; 3
tya ; 2
pha ; 3
  jsr yield
  pla ; 4
  tay ; 2
  pla ; 4
  tax ; 2
endm

macro yield_axy
  pha ; 3
  txa ; 2
  pha ; 3
  tya ; 2
  pha ; 3
  jsr yield
  pla ; 4
  tay ; 2
  pla ; 4
  tax ; 2
  pla ; 4
endm

macro generator.initialize info, entrypoint
  stack=(info)+GeneratorInfo.size

  lda #<(entrypoint-1)
  sta stack
  lda #>(entrypoint-1)
  sta stack+1

  lda #2
  sta info+GeneratorInfo.stack_size
endm

macro generator.stop info
  generator.initialize info, generator.nothing
endm

macro generator.empty_current_stack
  ldx CURRENT_GENERATOR_COPY_UNTIL
  txs
endm

macro generator.push_current
  lda CURRENT_GENERATOR_INFO_LO
  pha
  lda CURRENT_GENERATOR_INFO_HI
  pha
  lda CURRENT_GENERATOR_STACK_LO
  pha
  lda CURRENT_GENERATOR_STACK_HI
  pha
  lda CURRENT_GENERATOR_COPY_UNTIL
  pha
endm

macro generator.pull_current
  pla
  sta CURRENT_GENERATOR_COPY_UNTIL
  pla
  sta CURRENT_GENERATOR_STACK_HI
  pla
  sta CURRENT_GENERATOR_STACK_LO
  pla
  sta CURRENT_GENERATOR_INFO_HI
  pla
  sta CURRENT_GENERATOR_INFO_LO
endm

macro generator.iterate info
  lda #<(info)
  sta CURRENT_GENERATOR_INFO_LO
  lda #>(info)
  sta CURRENT_GENERATOR_INFO_HI
  jsr generator.iterate_current
endm

macro generator.sta_field info, genvar
  sta ((info)+GeneratorInfo.locals+(genvar)-GENVAR0)
endm

macro generator.end
  jsr yield
  ; The generator will just keep looping here.
  ; A simple "rts" within a generator won't copy the stack, and resuming the
  ; generator will always leave us after the last yield.
  ; This is a workaround! While it works, the drawback is that we waste a yield
  ; whenever we jsr to a generator within a generator.
  ; TODO
  ; The proper solution would probably be to fix the yield and
  ; generator.iterate_current subroutines so that we just can use "rts" in the generator.
  rts
endm

yield:
  ;; Copy local variables (2 + 10*size)
  ldy #GeneratorInfo.locals
  i=0
  rept GeneratorInfo.locals.size
    lda GENVAR0+i   ; 3
    sta (CURRENT_GENERATOR_INFO_LO), y  ; 5
    iny
    i=i+1
  endr

  ;; Copy stack
  tsx
  txa
  ldy #0

  ; below loop is about 19 cycles per byte of stack data.
-
  pla ; 4
  sta (CURRENT_GENERATOR_STACK_LO), y  ; 6
  inx ; 2
  iny ; 2
  cpx CURRENT_GENERATOR_COPY_UNTIL  ; 3
  bne - ; 2 or 3

+
  ; Store the size of the stack
  tya
  ldy #GeneratorInfo.stack_size
  sta (CURRENT_GENERATOR_INFO_LO), y
  ; Jump to where the generator.iterate_current subroutine wants to return
  rts

generator.copy_sm_to_current_locals[\x]:
  ldy #GeneratorInfo.locals
  i=0
  rept GeneratorInfo.locals.size
    lda GENVAR0+i
    sta (CURRENT_GENERATOR_INFO_LO), y
    iny
    i=i+1
  endr
  rts

generator.copy_current_locals_to_sm[\x]:
  ldy #GeneratorInfo.locals
  i=0
  rept GeneratorInfo.locals.size
    lda (CURRENT_GENERATOR_INFO_LO), y  ; 5
    sta GENVAR0+i   ; 3
    iny
    i=i+1
  endr
  rts

generator.iterate_current:
  tsx
  stx CURRENT_GENERATOR_COPY_UNTIL

  ;; Get source stack pointer
  lda CURRENT_GENERATOR_INFO_LO
  clc
  adc #GeneratorInfo.size
  sta CURRENT_GENERATOR_STACK_LO

  lda CURRENT_GENERATOR_INFO_HI
  sta CURRENT_GENERATOR_STACK_HI

  ldy #GeneratorInfo.stack_size
  lda (CURRENT_GENERATOR_INFO_LO), y
  tay
  ; If the stack size is zero, then the generator is dead. Just return.
  beq ++
  dey
  bmi +

  ;; Copy stack
  ; below loop is about 14 cycles per byte of stack data.
-
  lda (CURRENT_GENERATOR_STACK_LO), y  ; 5
  pha ; 3
  dex ; 2
  dey ; 2
  bpl - ; 2 or 3

  ;; Copy local variables (2 + 10*size)
  ldy #GeneratorInfo.locals
  i=0
  rept GeneratorInfo.locals.size
    lda (CURRENT_GENERATOR_INFO_LO), y  ; 5
    sta GENVAR0+i   ; 3
    iny
    i=i+1
  endr

+
  ; Restore the stack pointer
  txs
  ; Jump to the generator PC
++
  rts

; Generators are never in a "do nothing" state.
; If a generator needs to do nothing, we point them here.
; Eg. at the end of a generator:
; jmp generator_nothing
generator.nothing:
  generator.empty_current_stack
-
  jsr yield
  jmp -

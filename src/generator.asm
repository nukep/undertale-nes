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

  ldy #GeneratorInfo.stack_size
  lda (CURRENT_GENERATOR_INFO_LO), y
  bne +
  ; The generator has ended.
  ldx CURRENT_GENERATOR_COPY_UNTIL
  txs
  rts
+

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
  ; Jump to where the iterate_current_generator subroutine wants to return
  rts

copy_sm_to_current_generator_locals[\x]:
  ldy #GeneratorInfo.locals
  i=0
  rept GeneratorInfo.locals.size
    lda GENVAR0+i
    sta (CURRENT_GENERATOR_INFO_LO), y
    iny
    i=i+1
  endr
  rts

copy_current_generator_locals_to_sm[\x]:
  ldy #GeneratorInfo.locals
  i=0
  rept GeneratorInfo.locals.size
    lda (CURRENT_GENERATOR_INFO_LO), y  ; 5
    sta GENVAR0+i   ; 3
    iny
    i=i+1
  endr
  rts

iterate_current_generator:
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


macro initialize_generator info, entrypoint
  stack=(info)+GeneratorInfo.size

  lda #<(entrypoint-1)
  sta stack
  lda #>(entrypoint-1)
  sta stack+1

  lda #2
  sta info+GeneratorInfo.stack_size
endm

macro clear_generator info
  ; Just empty the stack. This will stop the generator from iterating.
  lda #0
  sta info+GeneratorInfo.stack_size
endm

macro empty_current_generator_stack
  ldx CURRENT_GENERATOR_COPY_UNTIL
  txs
endm

macro push_current_generator
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

macro pull_current_generator
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

macro iterate_generator info
  lda #<(info)
  sta CURRENT_GENERATOR_INFO_LO
  lda #>(info)
  sta CURRENT_GENERATOR_INFO_HI
  jsr iterate_current_generator
endm

macro sta_generator_field info, genvar
  sta ((info)+GeneratorInfo.locals+(genvar)-GENVAR0)
endm

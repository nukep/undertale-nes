macro memcpy dest,src,size
lda #<src
sta TEMP0_MACRO

lda #>src
sta TEMP1_MACRO

lda #<dest
sta TEMP2_MACRO

lda #>dest
sta TEMP3_MACRO

; Copy entire pages first (256 byte chunks)...

ldx #>size
beq @remainder
ldy #0
-
lda (TEMP0_MACRO), y
sta (TEMP2_MACRO), y
dey
bne -
inc TEMP1_MACRO
inc TEMP3_MACRO
dex
bne -

@remainder:
; Then the remainder...

ldy #<size
beq @done
-
dey
lda (TEMP0_MACRO), y
sta (TEMP2_MACRO), y
cpy #0
bne -

@done:
endm


macro memcpy_ppu dest,src,size
lda #<src
sta TEMP0_MACRO

lda #>src
sta TEMP1_MACRO

lda #>dest
sta $2006

lda #<dest
sta $2006

; Copy entire pages first (256 byte chunks)...

ldx #>size
beq @remainder
ldy #0
-
lda (TEMP0_MACRO), y
sta $2007
iny
bne -
inc TEMP1_MACRO
dex
bne -

@remainder:
; Then the remainder...

ldy #0
cpy #<size
beq @done
-
lda (TEMP0_MACRO), y
sta $2007
iny
cpy #<size
bne -

@done:
endm

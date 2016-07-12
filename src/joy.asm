BUTTON.RIGHT = $01
BUTTON.LEFT = $02
BUTTON.DOWN = $04
BUTTON.UP = $08
BUTTON.START = $10
BUTTON.SELECT = $20
BUTTON.B = $40
BUTTON.A = $80

joy.init:
  lda #0
  sta BUTTONS
  sta BUTTONS_LAST
  rts

; Source: http://wiki.nesdev.com/w/index.php/Controller_Reading

; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
joy.read:
  lda BUTTONS
  sta BUTTONS_LAST

  lda #$01
  ; While the strobe bit is set, buttons will be continuously reloaded.
  ; This means that reading from JOYPAD1 will only return the state of the
  ; first button: button A.
  sta $4016
  sta BUTTONS
  lsr a        ; now A is 0
  ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
  ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
  sta $4016
-
  lda $4016
  lsr a	       ; bit0 -> Carry
  rol BUTTONS  ; Carry -> bit0; bit 7 -> Carry
  bcc -
  rts

; sets Z flag: set if true, clear if false
macro joy.is_button_down button
  lda BUTTONS
  and #button
  cmp #button
endm

; BUTTONS & (BUTTONS ^ BUTTONS_LAST)
; sets Z flag; set if true, clear if false
macro joy.is_button_tapped button
  lda BUTTONS
  eor BUTTONS_LAST
  and BUTTONS
  and #button
  cmp #button
endm

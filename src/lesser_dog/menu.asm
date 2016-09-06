{bytes("LesserDogAppears", text_menu("Lesser Dog appears."))}
{bytes("LesserDogCheck", text_menu(
  "LESSER DOG - ATK 7 DEF 0\nWields a stone dogger made of pomer-granite."
))}

{bytes_array("LesserDogNeutral",
  [text_menu(x) for x in [
  "Lesser Dog cocks its head to one side.",
  "Smells like dog chow.",
  "Lesser Dog thinks your weapon is a dog treat.",
  "Lesser Dog is really not paying attention."
]])}

{lookup_table_lo_hi("LesserDogNeutralLookup", ["LesserDogNeutral_"+str(i) for i in range(4)])}

macro menu.set_option_attributes a,b,c,d
  graphics.attribute_value_all.v=a
  a_attr=graphics.attribute_value_all

  graphics.attribute_value_all.v=b
  b_attr=graphics.attribute_value_all

  graphics.attribute_value_all.v=c
  c_attr=graphics.attribute_value_all

  graphics.attribute_value_all.v=d
  d_attr=graphics.attribute_value_all

  graphics.attribute_addr.x=0
  graphics.attribute_addr.y=24
  ldx DRAW_BUFFER_SIZE
  txa
  clc
  adc #(3+16)
  sta DRAW_BUFFER_SIZE

  lda #>(graphics.attribute_addr)
  sta DRAW_BUFFER,x
  lda #<(graphics.attribute_addr)
  sta DRAW_BUFFER+1,x
  lda #16
  sta DRAW_BUFFER+2,x

  lda #a_attr
  buffer=DRAW_BUFFER+3
  sta buffer+0,x
  sta buffer+1,x
  sta buffer+8,x
  sta buffer+9,x

  lda #b_attr
  buffer=DRAW_BUFFER+3+2
  sta buffer+0,x
  sta buffer+1,x
  sta buffer+8,x
  sta buffer+9,x

  lda #c_attr
  buffer=DRAW_BUFFER+3+4
  sta buffer+0,x
  sta buffer+1,x
  sta buffer+8,x
  sta buffer+9,x

  lda #d_attr
  buffer=DRAW_BUFFER+3+6
  sta buffer+0,x
  sta buffer+1,x
  sta buffer+8,x
  sta buffer+9,x
endm

macro menu.transition_to f
  jsr sfx.select
  jsr menu.clear_text
  lda menu.selection
  pha
  jsr f
  jsr menu.clear_text
  pla
  sta menu.selection
endm

menu.selection=GENVAR0
menu.wait_for_selection.total_selections=GENVAR1
menu:
  lda #0
  sta menu.selection
--
  type_text.initialize_generator TEXT_GENERATOR, LesserDogAppears, LesserDogAppears.size
-
  jsr menu.check_buttons
  stx TEMP0
  jsr menu.change_selection
  ldx TEMP0
  cpx #0
  beq +
  jsr sfx.choose
+
  lda menu.selection
  ; x = menu.selection*64 + 8
  asl_n 6
  adc #8
  sta graphics.draw_heart_sprite.x
  lda #(26*8+1)
  sta graphics.draw_heart_sprite.y
  jsr graphics.draw_heart_sprite

  jsr menu.color_selection

  jsr yield

  joy.is_button_tapped BUTTON.A
  bne -
  lda menu.selection
  cmp #1
  bne +
  jsr sfx.stop_text
  menu.transition_to menu.act
  jmp --
+
  jmp -


{bytes("MENU_LESSER_DOG", text("* Lesser Dog"))}
{bytes("MENU_CHECK", text("* Check"))}
{bytes("MENU_PET", text("* Pet"))}

menu.act:
  lda #0
  sta menu.selection
-
  draw_text.simple MENU_LESSER_DOG, MENU_LESSER_DOG.size, 4, 17
  lda #1
  sta menu.wait_for_selection.total_selections
  jsr menu.wait_for_selection
  cmp #$FF
  bne +
  rts
+

  menu.transition_to menu.lesser_dog_act
  jmp -

menu.lesser_dog_act:
  lda #0
  sta menu.selection
  draw_text.simple MENU_CHECK, MENU_CHECK.size, 4, 17
  draw_text.simple MENU_PET, MENU_PET.size, 18, 17
  jsr yield
  draw_text.simple MENU_PET, MENU_PET.size, 4, 19
  draw_text.simple MENU_PET, MENU_PET.size, 18, 19
  jsr yield
  draw_text.simple MENU_PET, MENU_PET.size, 4, 21
  draw_text.simple MENU_PET, MENU_PET.size, 18, 21
  lda #6
  sta menu.wait_for_selection.total_selections
  jsr menu.wait_for_selection
  cmp #$FF
  bne +
  rts
+
  cmp #0
  bne +
  ; Check
  menu.transition_to menu.lesser_dog_act_check
  jmp ++
+
  menu.transition_to menu.lesser_dog_act_pet
++
  jsr menu.clear_text
  ; Forget the state of the menu and jump right for the battle!
  generator.empty_current_stack
  jmp lesser_dog.battle

menu.lesser_dog_act_check:
  lda #<(LesserDogCheck)
  sta type_text.src_lo
  lda #>(LesserDogCheck)
  sta type_text.src_hi
  lda #(LesserDogCheck.size)
  sta type_text.length
  lda #2
  sta type_text.x
  lda #17
  sta type_text.y
  jsr type_text.generator
-
  joy.is_button_tapped BUTTON.A
  bne +
  rts
+
  jsr yield
  jmp -

menu.lesser_dog_act_pet:
  lda #<(lesser_dog.pet_0)
  sta type_text.src_lo
  lda #>(lesser_dog.pet_0)
  sta type_text.src_hi
  lda #(lesser_dog.pet_0.size)
  sta type_text.length
  lda #2
  sta type_text.x
  lda #17
  sta type_text.y
  jsr type_text.generator
-
  joy.is_button_tapped BUTTON.A
  bne +
  rts
+
  jsr yield
  jmp -



{bytes("MENU_HEART_X", [x*8-5 for x in [3, 17, 3, 17, 3, 17]])}
{bytes("MENU_HEART_Y", [y*8-2 for y in [17, 17, 19, 19, 21, 21]])}

macro menu.wait_for_selection.on button, diff
  joy.is_button_tapped button
  bne +
  lda menu.selection
  clc
  adc #diff
  cmp menu.wait_for_selection.total_selections
  bcs +
  sta menu.selection
+
endm

menu.wait_for_selection:
-
  joy.is_button_tapped BUTTON.B
  bne +
  lda #$FF
  rts
+
  joy.is_button_tapped BUTTON.A
  bne +
  lda menu.selection
  rts
+
  menu.wait_for_selection.on BUTTON.UP, -2
  menu.wait_for_selection.on BUTTON.DOWN, 2
  menu.wait_for_selection.on BUTTON.LEFT, -1
  menu.wait_for_selection.on BUTTON.RIGHT, 1
  ldx menu.selection
  lda MENU_HEART_X, x
  sta graphics.draw_heart_sprite.x
  lda MENU_HEART_Y, x
  sta graphics.draw_heart_sprite.y
  jsr graphics.draw_heart_sprite
  jsr yield
  jmp -

menu.clear_text:
  generator.stop TEXT_GENERATOR
  ldy #0
-
  sty graphics.clear_menu_text.y
  tya
  pha
  jsr graphics.clear_menu_text
  jsr yield
  pla
  tay
  iny
  cpy #6
  bne -
  rts

; returns with x = -1, 0, or +1
; if left or right was pressed, z will be clear
menu.check_buttons:
  ldx #0
  joy.is_button_tapped BUTTON.LEFT
  bne +
  dex
+
  joy.is_button_tapped BUTTON.RIGHT
  bne +
  inx
+
  rts

menu.change_selection:
  txa
  clc
  adc menu.selection
  cmp #$FF
  bne +
  lda #0
+
  cmp #4
  bne +
  lda #3
+
  sta menu.selection
  rts

menu.color_selection:
  lda menu.selection
  asl
  tax
  lda @lookup,x
  sta TEMP0
  inx
  lda @lookup,x
  sta TEMP1
  jmp (TEMP0)

@lookup:
  .dw @0,@1,@2,@3
@0:
  menu.set_option_attributes 2,1,1,1
  rts
@1:
  menu.set_option_attributes 1,2,1,1
  rts
@2:
  menu.set_option_attributes 1,1,2,1
  rts
@3:
  menu.set_option_attributes 1,1,1,2
  rts

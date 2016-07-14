{bytes("LesserDogAppears", text_menu("Lesser Dog appears."))}
{bytes("LesserDogCheck", text_menu(
  "LESSER DOG - ATK 7 DEF 0\nWields a stone dogger made of pomer-granite."
))}

{bytes_array("LesserDogPet",
  [text_menu(x) for x in [
  # 0
  "You barely lifted your hand and Lesser Dog got excited.",
  "You lightly touched the Dog.\nIt's already overexcited...",
  "You pet the Dog.\nIt raises its head up to meet your hand.",
  "You pet the Dog.\nIt was a good Dog.",
  "You pet the Dog.\nIts excitement knows no bounds.",
  "Critical pet!\nDog excitement increased.",
  "You have to jump up to pet the Dog.",
  "You don't even pet it.\nIt gets more excited.",
  "There is no way to stop this madness.",
  "Lesser Dog enters the realm of the clouds.",
  "You call the Dog but it is too late.\nIt cannot hear you.",
  "...",
  "You can reach Lesser Dog again.",
  # 13
  "You pet Lesser Dog.",
  "It's possible that you may have a problem.",
  "Lesser Dog is unpettable but appreciates the attempt.",
  "Perhaps mankind was not meant to pet this much.",
  "It continues.",
  "Lesser Dog is beyond your reach.",
  # 19
  "Really..."
]])}

; The index is after pet #<index>. i.e. 0 is after the first pet.
{lookup_table_lo_hi("LesserDogPetLookup", *[
  "LesserDogPet_"+str(i) for i in [
    0,1,2,3,4,5,6,7,8,9,10,11,12,
    *[13] * 6,
    *[14] * 12,
    *[15] * 10,
    16,
    *[17] * 6,
    *[18] * 2,
    19
  ]
])}

{bytes_array("LesserDogPetStatus",
  [text_menu(x) for x in [
  "Lesser Dog is barking excitedly.",
  "Lesser Dog is overstimulated.",
  "Lesser Dog shows no signs of stopping.",
  "Lesser Dog is lowering.",
  "Lesser Dog is learning to read.",
  "Lesser Dog is whining because it can't see you.",
  "Hello there.",
  "Lesser Dog is questioning your choices.",
  "Lesser Dog has gone where no Dog has gone before."
]])}

; The index is after pet #<index>. i.e. 0 is after the first pet.
{lookup_table_lo_hi("LesserDogPetStatusLookup", *[
  "LesserDogPetStatus_"+str(i) for i in [
    *[0]*3,
    *[1]*4,
    *[2]*6,
    *[3]*18,
    *[4]*2,
    *[5]*9,
    *[6]*3,
    *[7]*7,
    *[8]*2,
]])}

{bytes_array("LesserDogNeutral",
  [text_menu(x) for x in [
  "Lesser Dog cocks its head to one side.",
  "Smells like dog chow.",
  "Lesser Dog thinks your weapon is a dog treat.",
  "Lesser Dog is really not paying attention."
]])}

{lookup_table_lo_hi("LesserDogNeutralLookup", *["LesserDogNeutral_"+str(i) for i in range(4)])}

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
  initialize_text_generator LesserDogAppears, LesserDogAppears.size
-
  jsr menu.check_buttons
  stx TEMP0
  jsr menu.change_selection
  ldx TEMP0
  cpx #0
  beq +
  initialize_generator SFX_GENERATOR, play_select_sfx
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
  write_text_simple MENU_LESSER_DOG, MENU_LESSER_DOG.size, 4, 17
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
  write_text_simple MENU_CHECK, MENU_CHECK.size, 4, 17
  write_text_simple MENU_PET, MENU_PET.size, 18, 17
  jsr yield
  write_text_simple MENU_PET, MENU_PET.size, 4, 19
  write_text_simple MENU_PET, MENU_PET.size, 18, 19
  jsr yield
  write_text_simple MENU_PET, MENU_PET.size, 4, 21
  write_text_simple MENU_PET, MENU_PET.size, 18, 21
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
  empty_current_generator_stack
  jmp lesser_dog_battle

menu.lesser_dog_act_check:
  lda #<(LesserDogCheck)
  sta print_text.src_lo
  lda #>(LesserDogCheck)
  sta print_text.src_hi
  lda #(LesserDogCheck.size)
  sta print_text.length
  lda #2
  sta print_text.x
  lda #17
  sta print_text.y
  jsr print_text
-
  joy.is_button_tapped BUTTON.A
  bne +
  rts
+
  jsr yield
  jmp -

menu.lesser_dog_act_pet:
  lda #<(LesserDogPet_0)
  sta print_text.src_lo
  lda #>(LesserDogPet_0)
  sta print_text.src_hi
  lda #(LesserDogPet_0.size)
  sta print_text.length
  lda #2
  sta print_text.x
  lda #17
  sta print_text.y
  jsr print_text
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
  clear_generator TEXT_GENERATOR
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

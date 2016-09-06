{bytes_array("lesser_dog.pet",
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
{lookup_table_lo_hi("lesser_dog.pet_lookup", [
  "lesser_dog.pet_"+str(i) for i in [
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

{bytes_array("lesser_dog.pet_status",
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
{lookup_table_lo_hi("lesser_dog.pet_status_lookup", [
  "lesser_dog.pet_status_"+str(i) for i in [
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

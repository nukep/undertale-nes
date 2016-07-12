.enum $0000
; As a rule of thumb, these temporary variables cannot cross subroutine calls.
; They cannot be used inside macros.
; They can be aliased to subroutine parameters.
TEMP0   .dsb 1
TEMP1   .dsb 1

; As a rule of thumb, these temporary variables cannot cross macro expansions.
TEMP0_MACRO   .dsb 1
TEMP1_MACRO   .dsb 1
TEMP2_MACRO   .dsb 1
TEMP3_MACRO   .dsb 1

CURRENT_GENERATOR_INFO_LO     .dsb 1
CURRENT_GENERATOR_INFO_HI     .dsb 1
CURRENT_GENERATOR_STACK_LO    .dsb 1
CURRENT_GENERATOR_STACK_HI    .dsb 1
CURRENT_GENERATOR_COPY_UNTIL  .dsb 1

BUTTONS       .dsb 1
BUTTONS_LAST  .dsb 1

; Generator variables
; depends on GeneratorInfo.locals.size
GENVAR0   .dsb 1
GENVAR1   .dsb 1
GENVAR2   .dsb 1
GENVAR3   .dsb 1
GENVAR4   .dsb 1
GENVAR5   .dsb 1

DRAW_BUFFER_SIZE      .dsb 1
OAM_SIZE              .dsb 1
SCREEN_SPLIT_ENABLED  .dsb 1
.ende

OAM=$0200

DRAW_BUFFER=$0300

; State machines
.enum $0400
; Each structure is the size of GeneratorInfo.size, plus additional stack space
TEXT_GENERATOR  .dsb GeneratorInfo.size+16
MENU_GENERATOR     .dsb GeneratorInfo.size+16
SFX_GENERATOR   .dsb GeneratorInfo.size+16
.ende

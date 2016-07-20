.enum $0000
NMI_LOOP_LO  .dsb 1
NMI_LOOP_HI  .dsb 1

; As a rule of thumb, these temporary variables cannot cross subroutine calls.
; They cannot be used inside macros.
; They can be aliased to subroutine parameters.
TEMP0   .dsb 1
TEMP1   .dsb 1
TEMP2   .dsb 1
TEMP3   .dsb 1
TEMP4   .dsb 1
TEMP5   .dsb 1
TEMP6   .dsb 1

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
.ende

; $0200 - $02FF: The OAM buffer
OAM=$0200

; $0300 - $03FF: The draw buffer
DRAW_BUFFER=$0300

; State machines
.enum $0400
; Each structure is the size of GeneratorInfo.size, plus additional stack space
TEXT_GENERATOR        .dsb GeneratorInfo.size+16
TEXT_SFX_GENERATOR    .dsb GeneratorInfo.size+16
SFX_GENERATOR         .dsb GeneratorInfo.size+16
GENERATOR0            .dsb GeneratorInfo.size+16
GENERATOR1            .dsb GeneratorInfo.size+16
GENERATOR2            .dsb GeneratorInfo.size+16
.ende

.enum $0500
SQ1_VOLUME    .dsb 1    ; 0 is mute, 15 is full volume.
SQ1_DUTY      .dsb 1    ; 0, 1, 2, 3
SQ1_NOTE      .dsb 1

SQ2_VOLUME    .dsb 1    ; 0 is mute, 15 is full volume.
SQ2_DUTY      .dsb 1    ; 0, 1, 2, 3
SQ2_NOTE      .dsb 1

TRI_VOLUME    .dsb 1    ; 0 is mute, 1+ is full volume.
TRI_NOTE      .dsb 1

NOISE_VOLUME  .dsb 1    ; 0 is mute, 15 is full volume.
NOISE_SHORT   .dsb 1    ; 0 plays noise at a normal cycle, 1 shortens it drastically
                        ; (creates robotic noises, i.e. Mettaton!)
NOISE_PERIOD  .dsb 1    ; 0 to 15 inclusive

LAST_400x     .dsb $14
.ende

.enum $0600
RAND_H        .dsb 1
RAND_L        .dsb 1
.ende

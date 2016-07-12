MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

.db "NES", $1a
;number of 16KB PRG-ROM pages
.db 2
;number of 8KB CHR-ROM pages
.db 1
;mapper 0 and mirroring
.db $00|MIRRORING
;clear the remaining bytes
.dsb 9, $00

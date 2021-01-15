;;;;;;;;;;;;;;;;;;;;;;;
;;;   iNES HEADER   ;;;
;;;;;;;;;;;;;;;;;;;;;;;

.db  "NES", $1a     ;identification of the iNES header
.db  PRG_COUNT      ;number of 16KB PRG-ROM pages
.db  $01            ;number of 8KB CHR-ROM pages
.db  $00            ;NROM
.dsb $09, $00       ;clear the remaining bytes

.fillvalue $ff      ; Sets all unused space in rom to value $ff

;;;;;;;;;;;;;;;;;;;;;
;;;   VARIABLES   ;;;
;;;;;;;;;;;;;;;;;;;;;

.enum $0000 ; Zero Page variables

; main
nmis      .dsb 1
cur_keys  .dsb 2
new_keys  .dsb 2
ticks     .dsb 1

; player
snake_px        .dsb 1
snake_py        .dsb 1
snake_dir       .dsb 1
snake_next_dir  .dsb 1
snake_tile      .dsb 1

; read_pads (pads.asm)
thisRead      .dsb 2
firstRead     .dsb 2
lastFrameKeys .dsb 2

.ende

.enum $0400 ; Variables at $0400. Can start on any RAM page

.ende

;;;;;;;;;;;;;;;;;;;;;
;;;   CONSTANTS   ;;;
;;;;;;;;;;;;;;;;;;;;;

PRG_COUNT = 1       ; 1 = 16KB, 2 = 32KB
MIRRORING = %0001

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

KEY_A      = %10000000
KEY_B      = %01000000
KEY_SELECT = %00100000
KEY_START  = %00010000
KEY_UP     = %00001000
KEY_DOWN   = %00000100
KEY_LEFT   = %00000010
KEY_RIGHT  = %00000001

GAME_TICKS = 20

.org $c000

;;;;;;;;;;;;;;;;;
;;;   RESET   ;;;
;;;;;;;;;;;;;;;;;

reset:
    sei             ; disable irqs
    cld             ; disable decimal mode
    ldx #$40
    stx $4017       ; disable apu frame irq
    ldx #$ff
    txs             ; set up stack
    inx             ; now x = 0
    stx PPUCTRL     ; disable nmi
    stx PPUMASK     ; disable rendering
    stx $4010       ; disable dmc irqs

vblankwait1:      ; first wait for vblank to make sure ppu is ready
    bit PPUSTATUS
    bpl vblankwait1

clrmem:
    lda #$00
    sta $0000, x
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$fe
    sta $0200, x    ; move all sprites off screen
    inx
    bne clrmem

vblankwait2:      ; second wait for vblank, ppu is ready after this
    bit PPUSTATUS
    bpl vblankwait2
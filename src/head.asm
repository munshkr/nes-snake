;;;;;;;;;;;;;;;;;;;;;;;
;;;   iNES HEADER   ;;;
;;;;;;;;;;;;;;;;;;;;;;;

.db  "NES", $1a     ;identification of the iNES header
.db  PRG_COUNT      ;number of 16KB PRG-ROM pages
.db  $01            ;number of 8KB CHR-ROM pages
.db  $70|MIRRORING  ;mapper 7
.dsb $09, $00       ;clear the remaining bytes

.fillvalue $ff      ; Sets all unused space in rom to value $ff

;;;;;;;;;;;;;;;;;;;;;
;;;   VARIABLES   ;;;
;;;;;;;;;;;;;;;;;;;;;

.enum $0000 ; Zero Page variables

nmis    .dsb 1

.ende

.enum $0400 ; Variables at $0400. Can start on any RAM page

.ende

;;;;;;;;;;;;;;;;;;;;;
;;;   CONSTANTS   ;;;
;;;;;;;;;;;;;;;;;;;;;

PRG_COUNT = 1       ; 1 = 16KB, 2 = 32KB
MIRRORING = %0001

PPUCTRL   .equ $2000
PPUMASK   .equ $2001
PPUSTATUS .equ $2002
OAMADDR   .equ $2003
OAMDATA   .equ $2004
PPUSCROLL .equ $2005
PPUADDR   .equ $2006
PPUDATA   .equ $2007
OAMDMA    .equ $4014

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
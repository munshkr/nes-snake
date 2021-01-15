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

screenPtr       .dsb 2
metaTile        .dsb 1
counter         .dsb 1
rowCounter      .dsb 1
softPPU_Control .dsb 1
softPPU_Mask    .dsb 1

.ende

.enum $0400 ; Variables at $0400. Can start on any RAM page

sleeping        .dsb 1

.ende

;;;;;;;;;;;;;;;;;;;;;
;;;   CONSTANTS   ;;;
;;;;;;;;;;;;;;;;;;;;;

PRG_COUNT       = 1       ;1 = 16KB, 2 = 32KB
MIRRORING       = %0001

PPU_Control     .equ $2000
PPU_Mask        .equ $2001
PPU_Status      .equ $2002
PPU_Scroll      .equ $2005
PPU_Address     .equ $2006
PPU_Data        .equ $2007

spriteRAM       .equ $0200

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
  stx PPU_Control ; disable nmi
  stx PPU_Mask    ; disable rendering
  stx $4010       ; disable dmc irqs

vblankwait1:      ; first wait for vblank to make sure ppu is ready
  bit PPU_Status
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
  bit PPU_Status
  bpl vblankwait2
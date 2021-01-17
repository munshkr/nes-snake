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

; apples.asm
apple_px        .dsb 1
apple_py        .dsb 1

; pads.asm
thisRead      .dsb 2
firstRead     .dsb 2
lastFrameKeys .dsb 2

; prng.asm
seed    .dsb 2

.ende

.enum $0400 ; Variables at $0400. Can start on any RAM page

.ende

;;;;;;;;;;;;;;;;
;;;   CODE   ;;;
;;;;;;;;;;;;;;;;

setup:
    jsr load_palettes
    ; jsr load_background
    jsr init_player
    jsr spawn_apple

    lda #GAME_TICKS
    sta ticks

    ;; FIXME: should set a random seed based on the elapsed time between now and
    ;; when the user presses Start, or something like that...
    lda #$40
    sta seed

    ; lda #%10010000        ; enable nmi, sprites from pattern table 0 and bg from 1
    lda #%10000000        ; enable nmi, sprites from pattern table 0 only
    sta PPUCTRL
    lda #%00011000        ; enable sprites
    sta PPUMASK

main:
    ; Game logic
    jsr read_pads
    jsr move_player

    ; Drawing
    jsr draw_player
    jsr draw_apple

    ; Wait for vblank to write to PPU
    lda nmis
@vblankwait
    cmp nmis
    beq @vblankwait

    ; Update OAM
    lda #$00
    sta OAMADDR        ; set the low byte (00) of the ram address
    lda #$02
    sta OAMDMA         ; set the high byte (02) of the ram address, start the transfer

    jmp main           ; jump back to forever, infinite loop


load_palettes:
    lda PPUSTATUS         ; read ppu status to reset the high/low latch
    lda #$3f
    sta PPUADDR           ; write the high byte of $3f00 address (where palettes should be stored)
    lda #$00
    sta PPUADDR           ; write the low byte of $3f00 address
    ldx #$00              ; start out at 0
@loop:
    lda palette, x        ; load data from address (palette + the value in x)
    sta PPUDATA           ; write to ppu
    inx                   ; x = x + 1
    cpx #$20              ; there are 2 palettes (bg and sprites), each of 16/$10 bytes
    bne @loop
    rts


load_background:
    ;; set nt #0
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    lda #$2a
    ldx #$100
@loop:
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    dex
    bne @loop

    ;; set attributes for nt #0
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR

    lda #%11111111
    ldx #$40
@attrLoop:
    sta PPUDATA
    dex
    bne @attrLoop

    rts


nmi:
    inc nmis           ; trigger NMI signal on main routine
    rti

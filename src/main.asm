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

setup_ppu:
    jsr init_player

    lda #%10000000        ; enable nmi, sprites from pattern table 1
    sta PPUCTRL
    lda #%00010000        ; enable sprites
    sta PPUMASK

main:
    ; Game logic
    jsr read_pads
    jsr move_player
    jsr draw_player

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

nmi:
    inc nmis           ; trigger NMI signal on main routine
    rti

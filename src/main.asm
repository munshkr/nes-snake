load_palettes:
  lda PPUSTATUS         ; read ppu status to reset the high/low latch
  lda #$3f
  sta PPUADDR           ; write the high byte of $3f00 address (where palettes should be stored)
  lda #$00
  sta PPUADDR           ; write the low byte of $3f00 address
  ldx #$00              ; start out at 0
load_palettes_loop:
  lda palette, x        ; load data from address (palette + the value in x)
  sta PPUDATA           ; write to ppu
  inx                   ; x = x + 1
  cpx #$20              ; there are 2 palettes (bg and sprites), each of 16/$10 bytes
  bne load_palettes_loop

load_sprites:
  ldx #$00              ; start at 0
load_sprites_loop:
  lda sprites, x        ; load data from address (sprites +  x)
  sta $0200, x          ; store into ram address ($0200 + x)
  inx                   ; x = x + 1
  cpx #$40              ; 16/$10 sprites * 4 bytes for each sprite = 64/$40
  bne load_sprites_loop

  lda #%10000000        ; enable nmi, sprites from pattern table 1
  sta PPUCTRL
  lda #%00010000        ; enable sprites
  sta PPUMASK

forever:
  jmp forever           ; jump back to forever, infinite loop

nmi:
  lda #$00
  sta OAMADDR           ; set the low byte (00) of the ram address
  lda #$02
  sta OAMDMA            ; set the high byte (02) of the ram address, start the transfer

  rti                   ; return from interrupt
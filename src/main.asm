loadpalettes:
  lda $2002             ; read ppu status to reset the high/low latch
  lda #$3f
  sta $2006             ; write the high byte of $3f00 address
  lda #$00
  sta $2006             ; write the low byte of $3f00 address
  ldx #$00              ; start out at 0

loadpalettesloop:
  lda palette, x        ; load data from address (palette + the value in x)
  sta $2007             ; write to ppu
  inx                   ; x = x + 1
  cpx #$20              ; compare x to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  bne loadpalettesloop

loadsprites:
  ldx #$00              ; start at 0

loadspritesloop:
  lda sprites, x        ; load data from address (sprites +  x)
  sta $0200, x          ; store into ram address ($0200 + x)
  inx                   ; x = x + 1
  cpx #$40              ; compare x to hex $20, decimal 32
  bne loadspritesloop

  lda #%10000000   ; enable nmi, sprites from pattern table 1
  sta $2000
  lda #%00010000   ; enable sprites
  sta $2001

forever:
  jmp forever     ;jump back to forever, infinite loop

nmi:
  lda #$00
  sta $2003       ; set the low byte (00) of the ram address
  lda #$02
  sta $4014       ; set the high byte (02) of the ram address, start the transfer

  rti             ; return from interrupt
init_player:
    lda #$80
    sta snake_px
    lda #$70
    sta snake_py
    rts

move_player:
    ; TODO: change snake direction based on cur_keys dir pads

    dec ticks               ; advance game tick
    bne @skip
    lda snake_px            ; move snake to the right 8 pixels
    adc #8
    sta snake_px
    lda #GAME_TICKS         ; reset ticks variable
    sta ticks
@skip:

    rts

draw_player:
    lda snake_py
    sta $200
    lda #$05
    sta $201
    lda #0
    sta $202
    lda snake_px
    sta $203
    rts
init_player:
    lda #$80
    sta snake_px
    lda #$70
    sta snake_py
    rts

move_player:
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
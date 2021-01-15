init_player:
    lda #$80
    sta snake_px
    lda #$70
    sta snake_py
    lda #1
    sta snake_dir
    rts

move_player:
    ; change snake direction based on cur_keys dir pads
    lda cur_keys
    and #KEY_RIGHT
    beq @notRight
    sta snake_dir_now
@notRight:
    lda cur_keys
    and #KEY_LEFT
    beq @notLeft
    sta snake_dir_now
@notLeft:
    lda cur_keys
    and #KEY_DOWN
    beq @notDown
    sta snake_dir_now
@notDown:
    lda cur_keys
    and #KEY_UP
    beq @notUp
    sta snake_dir_now
@notUp:

    dec ticks               ; advance game tick
    bne @skip
    lda snake_dir_now       ; game has ticked. now we can update direction
    sta snake_dir
    lda #GAME_TICKS         ; reset ticks variable
    sta ticks
@skip:

move_sprite:
    lda snake_dir
    and #KEY_RIGHT
    beq @notRight
    inc snake_px
@notRight:
    lda snake_dir
    and #KEY_LEFT
    beq @notLeft
    dec snake_px
@notLeft:
    lda snake_dir
    and #KEY_DOWN
    beq @notDown
    inc snake_py
@notDown:
    lda snake_dir
    and #KEY_UP
    beq @notUp
    dec snake_py
@notUp:

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
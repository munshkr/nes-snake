init_player:
    lda #$80
    sta snake_px
    lda #$70
    sta snake_py
    lda #0
    sta snake_dir
    lda #5
    sta snake_tile
    rts


move_player:
    ;; change snake direction based on cur_keys dir pads
    lda cur_keys
    and #KEY_RIGHT
    beq @notRight
    sta snake_next_dir
@notRight:
    lda cur_keys
    and #KEY_LEFT
    beq @notLeft
    sta snake_next_dir
@notLeft:
    lda cur_keys
    and #KEY_DOWN
    beq @notDown
    sta snake_next_dir
@notDown:
    lda cur_keys
    and #KEY_UP
    beq @notUp
    sta snake_next_dir
@notUp:

    dec ticks                ; advance game tick
    bne skip_game_tick
    lda snake_next_dir       ; game has ticked. now we can update direction (from left/right to up/down or viceversa)
    sta snake_dir

update_sprite_tile:
    ldx #1
    and #KEY_UP
    beq @notUp
    stx snake_tile
@notUp:
    inx
    lda snake_dir
    and #KEY_DOWN
    beq @notDown
    stx snake_tile
@notDown:
    inx
    lda snake_dir
    and #KEY_LEFT
    beq @notLeft
    stx snake_tile
@notLeft:
    inx
    lda snake_dir
    and #KEY_RIGHT
    beq @notRight
    stx snake_tile
@notRight:

    lda #GAME_TICKS         ; reset ticks variable
    sta ticks
skip_game_tick:

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
    lda snake_tile
    sta $201
    lda #0
    sta $202
    lda snake_px
    sta $203
    rts
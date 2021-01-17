spawn_apple:
    jsr prng            ; generate a random byte
    lsr
    lsr                 ; divide by 4, we want a random number between 0 and 64

    asl
    asl
    asl                 ; multiply by 8 for we need pixel position (grid cells are 8x8)
    adc #BASE_X_OFFSET  ; base x offset is 1 pixel
    sta apple_px

    jsr prng            ; generate a random byte
    lsr
    lsr                 ; divide by 4, we want a random number between 0 and 64

    asl
    asl
    asl                 ; multiply by 8 for we need pixel position (grid cells are 8x8)
    adc #BASE_Y_OFFSET  ; base y offset is 6 pixels
    sta apple_py

    rts


draw_apple:
    lda apple_py
    sta $204
    lda #$06
    sta $205
    lda #0
    sta $206
    lda apple_px
    sta $207
    rts
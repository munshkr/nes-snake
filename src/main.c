#include <string.h>

#include "neslib.h"

#define GAME_TICKS 8
#define BASE_X_OFFSET 1
#define BASE_Y_OFFSET 6

byte ticks;
byte snake_px, snake_py;
byte snake_dir, snake_next_dir;
byte snake_tile;
byte apple_px, apple_py;

const char PALETTE[32] = {
    0x0f,                   // screen color
    0x31,0x32,0x33,0x34,    // background palette 0
    0x35,0x36,0x37,0x38,    // background palette 1
    0x39,0x3a,0x3b,0x3c,    // background palette 2
    0x3d,0x3e,0x0f,         // background palette 3

    0x0f,
    0x3b, 0x15, 0x0f, 0x0f, // sprite palette 0
    0x02, 0x0f, 0x0f, 0x0f, // sprite palette 1
    0x1c, 0x15, 0x14, 0x31, // sprite palette 2
    0x02, 0x38, 0x3c        // sprite palette 3
};

void put_str(unsigned int adr, const char *str) {
    vram_adr(adr);                 // set PPU read/write address
    vram_write(str, strlen(str));  // write bytes to PPU
}

void __fastcall__ clear_screen(void) {
    memfill(0x2000, 0, 960);
}

void __fastcall__ setup_graphics(void) {
    // clear sprites
    oam_hide_rest(0);
    // set palette colors
    pal_all(PALETTE);
}

void __fastcall__ titlescreen(void) {
    byte pad;

    put_str(NTADR_A(4, 10), "VIBORITA");
    put_str(NTADR_A(4, 15), "PRESS START TO PLAY");

    ppu_on_all();

    while (1) {
        pad = pad_poll(0);
        if (pad & PAD_START) break;
        ppu_wait_frame();
    };
}

void __fastcall__ init_player(void) {
    snake_px = 0x80 + BASE_X_OFFSET;
    snake_py = 0x70 + BASE_Y_OFFSET;
    snake_dir = 0;
    snake_tile = 5;
}

void __fastcall__ spawn_apple(void) {}

void __fastcall__ gameloop(void) {
    char oam_id;  // sprite ID

    clear_screen();
    init_player();
    // spawn_apple();

    ticks = GAME_TICKS;

    while (1) {
        // start with OAMid/sprite 0
        oam_id = 0;

        // draw snake
        oam_id = oam_spr(snake_px, snake_py, 0, 0, oam_id);

        // hide rest of sprites
        // if we haven't wrapped oam_id around to 0
        if (oam_id != 0) oam_hide_rest(oam_id);

        // advance game tick
        --ticks;
        // if game has ticked, update direction
        if (ticks == 0) {
            ticks = GAME_TICKS;
        }

        ppu_wait_frame();
    }
}

// main function, run after console reset
void main(void) {
    setup_graphics();

    // infinite game loop
    while (1) {
        titlescreen();
        gameloop();
    }
}

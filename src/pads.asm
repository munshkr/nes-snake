;
; NES controller reading code
; Copyright 2009-2011 Damian Yerrick
; Copyright 2021 munshkr
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;
;
; 2011-07: Damian Yerrick added labels for the local variables and
;          copious comments and made USE_DAS a compile-time option
; 2021-01: munshkr added some changes:
;          - migrated to asm6 syntax
;          - removed autorepeat support to simplify.
;

JOY1  .equ $4016
JOY2  .equ $4017

read_pads:
; FIXME:
; thisRead = 0
; firstRead = 2
; lastFrameKeys = 4

  ; store the current keypress state to detect key-down later
  lda cur_keys
  sta lastFrameKeys
  lda cur_keys+1
  sta lastFrameKeys+1

  ; Read the joypads twice in case DMC DMA caused a clock glitch.
  jsr read_pads_once
  lda thisRead
  sta firstRead
  lda thisRead+1
  sta firstRead+1
  jsr read_pads_once

  ; For each player, make sure the reads agree, then find newly
  ; pressed keys.
  ldx #1
@fixupKeys:

  ; If the player's keys read out the same way both times, update.
  ; Otherwise, keep the last frame's keypresses.
  lda thisRead,x
  cmp firstRead,x
  bne @dontUpdateGlitch
  sta cur_keys,x
@dontUpdateGlitch:

  lda lastFrameKeys,x   ; A = keys that were down last frame
  eor #$FF              ; A = keys that were up last frame
  and cur_keys,x        ; A = keys down now and up last frame
  sta new_keys,x
  dex
  bpl @fixupKeys
  rts

read_pads_once:
  ; Bits from the controllers are shifted into thisRead and
  ; thisRead+1.  In addition, thisRead+1 serves as the loop counter:
  ; once the $01 gets shifted left eight times, the 1 bit will
  ; end up in carry, terminating the loop.
  lda #$01
  sta thisRead+1
  ; Write 1 then 0 to JOY1 to send a latch signal, telling the
  ; controllers to copy button states into a shift register
  sta JOY1
  lsr a
  sta JOY1
  loop:
    ; On NES and AV Famicom, button presses always show up in D0.
    ; On the original Famicom, presses on the hardwired controllers
    ; show up in D0 and presses on plug-in controllers show up in D1.
    ; D2-D7 consist of data from the Zapper, Power Pad, Vs. System
    ; DIP switches, and bus capacitance; ignore them.
    lda JOY1       ; read player 1's controller
    and #%00000011 ; ignore D2-D7
    cmp #1         ; CLC if A=0, SEC if A>=1
    rol thisRead   ; put one bit in the register
    lda JOY2       ; read player 2's controller the same way
    and #$03
    cmp #1
    rol thisRead+1
    bcc loop       ; once $01 has been shifted 8 times, we're done
  rts

status = $00ff
result = $00fe

* = $8000

start:
  sei
  clc
  xce
  rep #$30

  sep #$20
  lda #$00
  sta status
  sta result
  rep #$20

  lda const1234
  sta $0400
  lda const5678
  sta $0402

  lda $0400
  cmp const1234
  bne fail01

  ldx const1234
  cpx const1234
  bne fail02

  ldy const5678
  cpy const5678
  bne fail03

  lda const1234
  clc
  adc const0001
  cmp const1235
  bne fail04

  sec
  sbc const0001
  cmp const1234
  bne fail05

  lda const1234
  and const00ff
  cmp const0034
  bne fail06

  lda const1200
  ora const0034
  cmp const1234
  bne fail07

  lda const12ff
  eor const00ff
  cmp const1200
  bne fail08

  lda const0001
  asl
  cmp const0002
  bne fail09

  lsr
  cmp const0001
  bne fail10

  clc
  rol
  cmp const0002
  bne fail11

  sec
  ror
  cmp const8001
  bne fail12

  lda const0001
  sta $0404
  inc $0404
  lda $0404
  cmp const0002
  bne fail13

  dec $0404
  lda $0404
  cmp const0001
  bne fail14

  ldx const0001
  inx
  cpx const0002
  bne fail15

  dex
  cpx const0001
  bne fail16

  ldy const0001
  iny
  cpy const0002
  bne fail17

  dey
  cpy const0001
  bne fail18

  lda constf0f0
  bit const4000
  bvs bit_ok
  jmp fail19
bit_ok:

  lda constffff
  tsb $0406
  lda $0406
  cmp constffff
  bne fail20

  lda const00ff
  trb $0406
  lda $0406
  cmp constff00
  bne fail21

  lda const1234
  pha
  lda const0000
  pla
  cmp const1234
  bne fail22

  ldx const1234
  phx
  ldx const0000
  plx
  cpx const1234
  bne fail23

  ldy const5678
  phy
  ldy const0000
  ply
  cpy const5678
  bne fail24

  jsr subroutine
  cmp const9abc
  bne fail25

  lda const0000
  beq branch_two
  jmp fail26
branch_two:
  lda const8000
  bmi branch_three
  jmp fail27
branch_three:
  lda const0000
  bpl branch_four
  jmp fail28
branch_four:

  stz $0410
  lda $0410
  cmp const0000
  bne fail29

  sep #$20
  lda #$42
  cmp #$42
  bne fail30

  rep #$20
  lda const1234
  tcs
  tsc
  cmp const1234
  bne fail31

  sep #$20
  lda #$aa
  sta status
pass:
  bra pass

subroutine:
  lda const9abc
  rts

fail01: jmp fail_01
fail02: jmp fail_02
fail03: jmp fail_03
fail04: jmp fail_04
fail05: jmp fail_05
fail06: jmp fail_06
fail07: jmp fail_07
fail08: jmp fail_08
fail09: jmp fail_09
fail10: jmp fail_10
fail11: jmp fail_11
fail12: jmp fail_12
fail13: jmp fail_13
fail14: jmp fail_14
fail15: jmp fail_15
fail16: jmp fail_16
fail17: jmp fail_17
fail18: jmp fail_18
fail19: jmp fail_19
fail20: jmp fail_20
fail21: jmp fail_21
fail22: jmp fail_22
fail23: jmp fail_23
fail24: jmp fail_24
fail25: jmp fail_25
fail26: jmp fail_26
fail27: jmp fail_27
fail28: jmp fail_28
fail29: jmp fail_29
fail30: jmp fail_30
fail31: jmp fail_31

set_fail:
  sep #$20
  sta result
  lda #$ff
  sta status
fail_loop:
  bra fail_loop

fail_01: lda #$01
  jmp set_fail
fail_02: lda #$02
  jmp set_fail
fail_03: lda #$03
  jmp set_fail
fail_04: lda #$04
  jmp set_fail
fail_05: lda #$05
  jmp set_fail
fail_06: lda #$06
  jmp set_fail
fail_07: lda #$07
  jmp set_fail
fail_08: lda #$08
  jmp set_fail
fail_09: lda #$09
  jmp set_fail
fail_10: lda #$0a
  jmp set_fail
fail_11: lda #$0b
  jmp set_fail
fail_12: lda #$0c
  jmp set_fail
fail_13: lda #$0d
  jmp set_fail
fail_14: lda #$0e
  jmp set_fail
fail_15: lda #$0f
  jmp set_fail
fail_16: lda #$10
  jmp set_fail
fail_17: lda #$11
  jmp set_fail
fail_18: lda #$12
  jmp set_fail
fail_19: lda #$13
  jmp set_fail
fail_20: lda #$14
  jmp set_fail
fail_21: lda #$15
  jmp set_fail
fail_22: lda #$16
  jmp set_fail
fail_23: lda #$17
  jmp set_fail
fail_24: lda #$18
  jmp set_fail
fail_25: lda #$19
  jmp set_fail
fail_26: lda #$1a
  jmp set_fail
fail_27: lda #$1b
  jmp set_fail
fail_28: lda #$1c
  jmp set_fail
fail_29: lda #$1d
  jmp set_fail
fail_30: lda #$1e
  jmp set_fail
fail_31: lda #$1f
  jmp set_fail

const0000:
  .word $0000
const0001:
  .word $0001
const0002:
  .word $0002
const0034:
  .word $0034
const00ff:
  .word $00ff
const1200:
  .word $1200
const12ff:
  .word $12ff
const1234:
  .word $1234
const1235:
  .word $1235
const4000:
  .word $4000
const5678:
  .word $5678
const8000:
  .word $8000
const8001:
  .word $8001
const9abc:
  .word $9abc
constf0f0:
  .word $f0f0
constff00:
  .word $ff00
constffff:
  .word $ffff

* = $ffe4
  .word start
  .word start
  .word start
  .word start
  .word start
  .word start

* = $fff4
  .word start
  .word start
  .word start
  .word start
  .word start
  .word start

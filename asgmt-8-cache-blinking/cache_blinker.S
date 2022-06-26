#include "csd_zynq_peripherals.h"

#define SWITCH_ADDR 0x41210000
#define COUNTER     0x400000

.global main

main:
    ldr r0, =SWITCH_ADDR
    ldr r1, =L2_reg1_ctrl
    ldr r2, =csd_LED_ADDR

    mov r3, #0x3C
    str r3, [r2]

forever:
    ldr r4, [r0]
    tst r4, #0b1
    moveq r5, #0    @ Switch if off, i.e. disable cache
    movne r5, #1    @ Switch is on, i.e. enable cache

    @ Enable/Disable L2 Cache
    str r5, [r1]

    @ Enable/Disable IL1, DL1 Caches
    mrc p15, 0, r6, c1, c0, 0

    biceq r6, r6, #(1 << 12)
    biceq r6, r6, #(1 << 2)
    orrne r6, r6, #(1 << 12)
    orrne r6, r6, #(1 << 2)

    mcr p15, 0, r6, c1, c0, 0

    ldr r7, =COUNTER
    stmfd sp!, {r7}
counter:
    ldmfd sp!, {r7}
    subs r7, r7, #1
    stmfd sp!, {r7}
    bne counter

    ldr r8, [r2]
    eor r8, r8, #0xFF
    str r8, [r2]

    b forever

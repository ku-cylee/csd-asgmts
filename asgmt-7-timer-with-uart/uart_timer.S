#include "csd_zynq_peripherals.h"
#include "uart_regs.h"
#include "uart_init.s"

#define TIMER_INITIAL	2999999

.align 5

timer_vector_tbl:
	b .
	b .
	b .
	b .
	b .
	b .
	b timer_interrupt
	b .

.global main
main:
    cpsid i

    cps #0x12
    ldr sp, =irq_stack_top

    cps #0x1F
    ldr r0, =timer_vector_tbl
    mcr p15, 0, r0, c12, c0, 0
    dsb
    isb

    cpsie i

	@ GIC setup
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	orr r1, r1, #1
	str r1, [r0]

	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29
	orr r1, r1, r2
	str r1, [r0]

	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x10 << 8
	orr r1, r1, r2
	str r1, [r0]

	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1
	orr r1, r1, r2
	str r1, [r0]

	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF
	orr r1, r1, r2
	str r1, [r0]
	@ GIC setup END

	@ Timer setup
    ldr r0, =PRIVATE_LOAD
    ldr r1, =TIMER_INITIAL
    str r1, [r0]

    ldr r0, =PRIVATE_CONTROL
    mov r1, #110 << 8
    orr r1, r1, #7
    str r1, [r0]
	@ Timer setup END

forever:
	b forever

timer_interrupt:
    cpsid i

	ldr r0, =GICC_IAR
	ldr r12, [r0]

    ldr r0, =uart_TX_RX_FIFO0
    ldr r1, =uart_Channel_sts_reg0
	ldr r2, =time_info
	ldr r3, =digit_limits
	mov r4, #1

update_time_digit:
	ldrb r5, [r2], #1
	ldr r6, [r3], #4

	cmp r6, #0
	bmi update_time_digit
	beq send_time

	add r5, r5, r4
	cmp r5, r6
	moveq r5, #48
	moveq r4, #1
	movne r4, #0

	strb r5, [r2, #-1]
	b update_time_digit

send_time:
    ldr r7, [r1]
	tst r7, #0b10000
	bne send_time

	ldrb r6, [r2, #-1]!
	strb r6, [r0]
	cmp r6, #0x00
	bne send_time

	@ clear interrupt status bit
	ldr r0, =PRIVATE_STATUS
	mov r1, #1
	str r1, [r0]

	@ end of interrupt
	ldr r0, =GICC_EOIR
	str r12, [r0]

    cpsie i
	subs pc, lr, #4

.data
.align 4

time_info:
	.byte 0x00
	.ascii "00:00:00"
	.byte 0x0D

digit_limits:	.word -1, 58, 54, -1, 58, 54, -1, 58, 54, 0

irq_stack:		.space 1024
irq_stack_top:

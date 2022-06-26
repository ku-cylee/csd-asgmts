#include "uart_regs.h"
#include "uart_init.s"

#define LED_ADDR 0x41200000

.global main

main:
	UART_init

	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0
	ldr r2, =menumsg
	ldr r3, =LED_ADDR
	mov r4, #0b1
	mov r5, #10

send_menumsg:
	ldr r6, [r1]
	and r6, r6, #0b10000
	cmp r6, #0b10000
	beq send_menumsg

	ldrb r7, [r2], #1
	strb r7, [r0]
	cmp r7, #0x00
	bne send_menumsg

receive:
	ldr r6, [r1]
	and r6, r6, #0b10
	cmp r6, #0b10
	beq led_on_and_change

	mov r8, r5

	ldr r7, [r0]
	str r7, [r0]

	sub r5, r7, #48
	cmp r5, #0
	movle r5, r8
	cmp r5, #8
	moveq r5, #10
	movgt r5, r8

led_on_and_change:
	lsl r9, r5, #26
	str r4, [r3]

led_on_loop:
	subs r9, r9, #1
	bne led_on_loop

	cmp r4, #0b10000000
	moveq r4, #0b1
	lslne r4, r4, #1

	b receive

menumsg:
	.ascii "----------- LED OnDuration -----------\r\n"
	.ascii "1. 100ms  2. 200ms  3. 300ms  4. 400ms\r\n"
	.ascii "5. 500ms  6. 600ms  7. 700ms  8. 1 sec\r\n"
	.ascii "--------------------------------------\r\n"
	.ascii "Select: "
	.byte 0x00

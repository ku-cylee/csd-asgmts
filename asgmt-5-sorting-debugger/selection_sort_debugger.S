#include "uart_regs.h"
#include "uart_init.s"

.global main

.macro DEBUG
	str r14, [sp, #60]
	bl print_registers
.endm

// r0: pSrc
// r1: pDst
// r2: pLoopEnd
// r3: pMin
// r4: min
// r5: pMinSearch
// r6: minSearch
// r7: tmp
// r8: dst

main:
	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0

	ldr r10, =init_hline
	bl send_str

	ldr r0, =Input_data     // int *pSrc = src;
	ldr r1, =Output_data    // int *pDst = dst;
	add r2, r0, #128        // int *pLoopEnd = src + 32;
	DEBUG

loop:						// while (1)
	mov r3, r0              // int *pMin = pSrc;
	ldr r4, [r3]            // int min = *pMin;
	mov r5, r0              // int *pMinSearch = pSrc;
	DEBUG

subloop:					// while (1)
	ldr r6, [r5]			// int minSearch = *pMinSearch;
	DEBUG

	cmp r6, r4              // if (*pMinSearch < *pMin)
	DEBUG
	movmi r3, r5            // pMin = pMinSearch;
	movmi r4, r6			// min = minSearch;
	DEBUG

	add r5, r5, #4          // pMinSearch++;
	DEBUG
	cmp r5, r2              // if (pMinSearch - pLoopEnd == 0)
	DEBUG
	bne subloop             // break;

	str r4, [r1], #4        // *pDst++ = min;
	ldr r7, [r0], #4		// int tmp = *pSrc++;
	str r7, [r3]			// *pMin = tmp;
	DEBUG

	cmp r0, r2				// if (pSrc - pLoopEnd == 0)
	DEBUG
	bne loop				// break;

	ldr r8, =Output_data
	DEBUG

forever:
	b forever

init_debug:
	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0

	ldr r10, =init_hline
	bl send_str
	mov pc, lr

print_registers:
	@ Store registers into the stack
	stmfa sp!, {r0 - r12}
	sub r0, r13, #52
	ldr r1, [sp, #8]
	sub r2, lr, #4
	mrs r3, cpsr
	stmfa sp!, {r0 - r3}
	@ END Store registers into the stack

	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0

	@ Print all registers in hex
	mvn r3, #63				@ r3 = -64
	ldr r10, =register_names

	@ Print a single register in hex
send_register:
	bl send_str
	ldr r4, [sp, r3]
	mov r5, #28
	mov r6, #0xF0000000
	mov r7, #0x5F			@ r7 = '_'

	@ Get and print hex code of 4 bits
send_register_hex:
	and r8, r4, r6
	lsr r8, r8, r5
	cmp r8, #10
	addlt r9, r8, #48
	addge r9, r8, #55

	bl wait_empty
	strb r9, [r0]

	@ Print delimter (_)
	bl wait_empty
	cmp r5, #16
	streqb r7, [r0]
	@ END Print delimter (_)

	@ Seek next 4 bits
	lsr r6, r6, #4
	subs r5, r5, #4
	bge send_register_hex
	@ END Get and print hex code of 4 bits

	@ Seek next register
	add r3, r3, #4
	cmp r3, #4
	bne send_register
	@ END Print a single register in hex
	@ END Print all registers in hex

	@ Print CPSR details
	ldr r10, =delimiter
	bl send_str

	@ Print CPSR NZCV bits
	and r8, r4, #0x80000000
	cmp r8, #0x80000000
	moveq r9, #0x4e
	movne r9, #0x6e
	bl wait_empty
	strb r9, [r0]

	and r8, r4, #0x40000000
	cmp r8, #0x40000000
	moveq r9, #0x5a
	movne r9, #0x7a
	bl wait_empty
	strb r9, [r0]

	and r8, r4, #0x20000000
	cmp r8, #0x20000000
	moveq r9, #0x43
	movne r9, #0x63
	bl wait_empty
	strb r9, [r0]

	and r8, r4, #0x10000000
	cmp r8, #0x10000000
	moveq r9, #0x56
	movne r9, #0x76
	bl wait_empty
	strb r9, [r0]
	@ END Print CPSR NZCV bits

	ldr r10, =delimiter
	bl send_str

	@ Print CPSR interrupt bits
	bl wait_empty
	and r8, r4, #0x100
	cmp r8, #0x100
	moveq r9, #0x41
	streqb r9, [r0]

	bl wait_empty
	and r8, r4, #0x80
	cmp r8, #0x80
	moveq r9, #0x49
	streqb r9, [r0]

	bl wait_empty
	and r8, r4, #0x40
	cmp r8, #0x40
	moveq r9, #0x46
	streqb r9, [r0]
	@ END Print CPSR interrupt bits

	@ Print CPSR ISA
	ldr r10, =delimiter
	bl send_str

	and r8, r4, #0b100000
	cmp r8, #0b100000
	moveq r5, #0b01
	movne r5, #0b00
	lsr r6, r4, #24
	and r8, r6, #0b1
	cmp r8, #0b1
	addeq r5, #0b10
	addne r5, #0b00

	cmp r5, #0b00
	ldreq r10, =isa_arm
	cmp r5, #0b01
	ldreq r10, =isa_thumb
	cmp r5, #0b10
	ldreq r10, =isa_jazelle
	cmp r5, #0b11
	ldreq r10, =isa_thumbee
	bl send_str
	@ END Print CPSR ISA

	@ Print CPSR Mode
	ldr r10, =delimiter
	bl send_str

	and r8, r4, #0b11111
	cmp r8, #0b10000
	ldreq r10, =mode_usr
	cmp r8, #0b10001
	ldreq r10, =mode_fiq
	cmp r8, #0b10010
	ldreq r10, =mode_irq
	cmp r8, #0b10011
	ldreq r10, =mode_svc
	cmp r8, #0b10110
	ldreq r10, =mode_mon
	cmp r8, #0b10111
	ldreq r10, =mode_abt
	cmp r8, #0b11010
	ldreq r10, =mode_hyp
	cmp r8, #0b11011
	ldreq r10, =mode_und
	cmp r8, #0b11111
	ldreq r10, =mode_sys
	bl send_str
	@ END Print CPSR Mode
	@ END Print CPSR details

	ldr r10, =hline
	bl send_str

	@ Load registers from the stack
	ldmfa sp!, {r0, r1, r2, r3}
	add r2, r2, #4
	str r2, [sp, #12]
	msr cpsr, r3

	ldmfa sp!, {r0 - r12}
	ldr r14, [sp, #60]
	ldr r15, [sp, #64]
	@ END Load registers from the stack

wait_empty:
	ldr r11, [r1]
	and r11, r11, #0b10000
	cmp r11, #0b10000
	beq wait_empty

	mov pc, lr

send_str:
	ldr r11, [r1]
	and r11, r11, #0b10000
	cmp r11, #0b10000
	beq send_str

	ldrb r12, [r10], #1
	strb r12, [r0]
	cmp r12, #0x00
	bne send_str

	mov pc, lr


init_hline:
	.ascii "----------------------- Selection Sort  Debugger -----------------------"
	.byte 0x00

hline:
	.ascii "\r\n------------------------------------------------------------------------"
	.byte 0x00

register_names:
	.ascii "\r\n  r0 = 0x"
	.byte 0x00
	.ascii "  r1 = 0x"
	.byte 0x00
	.ascii "  r2 = 0x"
	.byte 0x00
	.ascii "  r3 = 0x"
	.byte 0x00
	.ascii "\r\n  r4 = 0x"
	.byte 0x00
	.ascii "  r5 = 0x"
	.byte 0x00
	.ascii "  r6 = 0x"
	.byte 0x00
	.ascii "  r7 = 0x"
	.byte 0x00
	.ascii "\r\n  r8 = 0x"
	.byte 0x00
	.ascii "  r9 = 0x"
	.byte 0x00
	.ascii " r10 = 0x"
	.byte 0x00
	.ascii " r11 = 0x"
	.byte 0x00
	.ascii "\r\n r12 = 0x"
	.byte 0x00
	.ascii " r13 = 0x"
	.byte 0x00
	.ascii " r14 = 0x"
	.byte 0x00
	.ascii " r15 = 0x"
	.byte 0x00
	.ascii "\r\ncpsr = 0x"
	.byte 0x00

isa_arm:
	.ascii "ARM"
	.byte 0x00

isa_thumb:
	.ascii "Thumb"
	.byte 0x00

isa_jazelle:
	.ascii "Jazelle"
	.byte 0x00

isa_thumbee:
	.ascii "ThumbEE"
	.byte 0x00

mode_usr:
	.ascii "USR"
	.byte 0x00

mode_fiq:
	.ascii "FIQ"
	.byte 0x00

mode_irq:
	.ascii "IRQ"
	.byte 0x00

mode_svc:
	.ascii "SVC"
	.byte 0x00

mode_mon:
	.ascii "MON"
	.byte 0x00

mode_abt:
	.ascii "ABT"
	.byte 0x00

mode_hyp:
	.ascii "HYP"
	.byte 0x00

mode_und:
	.ascii "UND"
	.byte 0x00

mode_sys:
	.ascii "SYS"
	.byte 0x00

delimiter:
	.ascii "; "
	.byte 0x00

.data
.align 4

Input_data:	.word 2, 0, -7, -1, 3, 8, -4, 10
			.word -9, -16, 15, 13, 1, 4, -3, 14
			.word -8, -10, -15, 6, -13, -5, 9, 12
			.word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:	.word 0, 0, 0, 0, 0, 0, 0, 0
				.word 0, 0, 0, 0, 0, 0, 0, 0
				.word 0, 0, 0, 0, 0, 0, 0, 0
				.word 0, 0, 0, 0, 0, 0, 0, 0

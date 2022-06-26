#define LED_ADDR 0x41200000
#define ITERS_PER_MS 669800

.extern getDurationFromSwitch

.global main

main:
    ldr r0, =LED_ADDR
    ldr r1, =ITERS_PER_MS
    mov r2, #1

loop:
    str r2, [r0]

	stmfd sp!, {r0 - r2}
    bl getDurationFromSwitch
    mul r3, r0, r1
	ldmfd sp!, {r0 - r2}

led_on_loop:
	subs r3, r3, #1
	bne led_on_loop

    cmp r2, #128
    moveq r2, #1
    lslne r2, r2, #1

    b loop

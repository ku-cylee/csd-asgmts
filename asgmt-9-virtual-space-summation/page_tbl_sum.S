.align 5

csd_vector_table:
	b .
	b .
	b .
	b csd_prefetch_abort
	b csd_data_abort
	b .
	b .
	b .

.global main

main:
	@ Set VBAR
	ldr r0, =csd_vector_table
	mcr p15, 0, r0, c12, c0, 0
	dsb
	isb

	@ Disable MMU
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #0x1
	mcr	p15, 0, r0, c1, c0, 0

	@ Invalidate caches and TLBs
	mov	r0,#0
	mcr	p15, 0, r0, c8, c7, 0
	mcr	p15, 0, r0, c7, c5, 0
	mcr	p15, 0, r0, c7, c5, 6

	@ Set Memory
	mov r0, #0x400000
	ldr r1, =#-1024
	mov r2, #3072
memloop:
	cmp r1, #0
	addeq r1, r1, #1
	str r1, [r0], #4
	add r1, r1, #1
	subs r2, r2, #1
	bne memloop

	@ Set TTBR0
	ldr	r0, =mmu_tbl_sect_
	orr	r0, r0, #0x5B
	mcr	15, 0, r0, c2, c0, 0

	@ Clear PD0 in TTBCR
	mrc p15, 0, r2, c2, c0, 2
	bic r2, r2, #(1<<4)
	mcr p15, 0, r2, c2, c0, 2

	@ Enable MMU
	mrc	p15, 0, r0, c1, c0, 0
	bic r0, r0, #(1<<12)
	bic r0, r0, #(1<<2)
	orr r0, r0, #(1<<0)
	mcr	p15, 0, r0, c1, c0, 0
	dsb
	isb

	mov r0, #0
	mov r1, #0x200000
	mov r2, #3072
sumloop:
	ldr r3, [r1], #4
	add r0, r0, r3
	subs r2, r2, #1
	bne sumloop

forever:
	b forever

csd_prefetch_abort:
	b .

csd_data_abort:
	b .

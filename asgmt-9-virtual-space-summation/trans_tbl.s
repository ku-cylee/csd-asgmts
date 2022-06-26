.globl mmu_tbl_page_
.section .mmu_tbl_page, "a"

mmu_tbl_page_:
	.set BASE_PAGE, 0x400000
	.set PAGE, BASE_PAGE
	.word PAGE + 0x2
	.set PAGE, BASE_PAGE + 0x1000
	.word PAGE + 0x2
	.set PAGE, BASE_PAGE + 0x2000
	.word PAGE + 0x2

@ mmu_tbl_page_:
@ 	.set BASE_PAGE, 0x400000
@ 	.set PAGE, BASE_PAGE
@ 	.word PAGE + 0x2
@ 	.set PAGE, BASE_PAGE + 0x2000
@ 	.word PAGE + 0x2
@ 	.set PAGE, BASE_PAGE
@ 	.word PAGE + 0x2

.globl mmu_tbl_sect_
.section .mmu_tbl_sect, "a"

mmu_tbl_sect_:
	.set BASE_SECT, 0x0
	.set SECT, BASE_SECT
	.word SECT + 0x15de6
	.set SECT, BASE_SECT + 0x100000
	.word SECT + 0x15de6
	.word mmu_tbl_page_ + 0x1e1

	.end

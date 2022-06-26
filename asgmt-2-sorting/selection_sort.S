.global main

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
	ldr r0, =Input_data     // int *pSrc = src;
	ldr r1, =Output_data    // int *pDst = dst;
	add r2, r0, #128        // int *pLoopEnd = src + 32;

loop:						// while (1)
	mov r3, r0              // int *pMin = pSrc;
	ldr r4, [r3]            // int min = *pMin;
	mov r5, r0              // int *pMinSearch = pSrc;

subloop:					// while (1)
	ldr r6, [r5]			// int minSearch = *pMinSearch;

	cmp r6, r4              // if (*pMinSearch < *pMin)
	movmi r3, r5            // pMin = pMinSearch;
	movmi r4, r6			// min = minSearch;

	add r5, r5, #4          // pMinSearch++;
	cmp r5, r2              // if (pMinSearch - pLoopEnd == 0)
	bne subloop             // break;

	str r4, [r1], #4        // *pDst++ = min;
	ldr r7, [r0], #4		// int tmp = *pSrc++;
	str r7, [r3]			// *pMin = tmp;

	cmp r0, r2				// if (pSrc - pLoopEnd == 0)
	bne loop				// break;

	ldr r8, =Output_data

forever:
	b forever

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

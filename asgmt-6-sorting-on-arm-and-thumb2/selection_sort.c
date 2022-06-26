#pragma GCC target ("thumb")

int main() {
	int indata[32] = { 2, 0, -7, -1, 3, 8, -4, 10,
					-9, -16, 15, 13, 1, 4, -3, 14,
					-8, -10, -15, 6, -13, -5, 9, 12,
					-11, -14, -6, 11, 5, 7, -2, -12 };
	int outdata[32] = { 0 };

	for (int i = 0; i < 32; i++) {                              // go over every index
        int min_idx = i;                                        // initialize min_idx as current index
		for (int j = i; j < 32; j++) {                          // go over every index after i
			if (indata[j] < indata[min_idx]) min_idx = j;       // Update min_idx if min_idx-th value is smaller
		}
        outdata[i] = indata[min_idx];                           // Store min_idx-th data to outdata
        indata[min_idx] = indata[i];                            // Move current data to min_idx position
	}
}

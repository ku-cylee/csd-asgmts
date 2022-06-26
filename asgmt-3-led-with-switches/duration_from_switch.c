#define SWITCH_ADDR 0x41210000

int getDurationFromSwitch() {
    unsigned char *pSwitch = (unsigned char*)SWITCH_ADDR;
    int duration = 1000;
    int shiftCount = 0;
    unsigned char mask = 1 << 7;

    for (; shiftCount < 8 && duration == 1000; shiftCount++, mask >>= 1) {
        if ((*pSwitch & mask) == mask) duration = (shiftCount + 1) * 100;
    }

    return duration;
}

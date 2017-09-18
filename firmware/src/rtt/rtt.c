
#include "SEGGER_RTT.h"

#define DEBUG_BUF_SIZE 256

static const char* debug_buf_name = "Debug Output";
static char* debug_buf[DEBUG_BUF_SIZE];

void init_rtt() {
    SEGGER_RTT_ConfigUpBuffer(0, debug_buf_name, debug_buf, DEBUG_BUF_SIZE, SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL);
}

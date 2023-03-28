#include "global.h"

//====================================================================

pl_io_num ionum = PL_IO_NUM_0;

void on_sys_init () {
	sys.debugprint("Welcome!");
}

void on_button_pressed() {
	sys.debugprint("Button Pressed\r\n");
	io.num = ionum;
	io.enabled = YES;
	io.state = LOW;
	pat.play("G-R-B-~", PL_PAT_CANINT);
}

void on_button_released() {
	io.invert(ionum);
	ionum =  (pl_io_num) (ionum+1); 
}
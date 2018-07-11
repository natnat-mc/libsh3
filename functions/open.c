DEPENDS(proc_t, t)

proc_t *open() {
	// allocate a struct
	proc_t *sh3=malloc(sizeof(proc_t));
	if(!sh3) return sh3;
	
	// set PC to 0xa0000000
	sh3->PC=0xa0000000
	
	// set VBR to 0x00000000
	sh3->VBR=0x00000000
	
	// return said struct
	return sh3;
}

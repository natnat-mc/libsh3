DEPENDS(proc_t, t)

DEPENDS(setSR, f)

proc_t *open() {
	// allocate a struct
	proc_t *sh3=malloc(sizeof(proc_t));
	if(!sh3) return sh3;
	
	// set PC and PR to 0xa0000000
	sh3->PC=0xa0000000;
	sh3->PR=0xa0000000;
	
	// set SR to 0x70000xfx
	sh3->MD=sh3->RB=sh3->BL=1;
	sh3->IMASK=0xf;
	sh3->FD=0;
	// non-standard but supposedly undefined
	sh3->M=sh3->Q=sh3->S=sh3->T=0;
	
	// set VBR to 0x00000000
	sh3->VBR=0x00000000;
	
	// return said struct
	return sh3;
}

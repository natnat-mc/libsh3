DEPENDS(proc_t, t)

DEPENDS(invalidatePipeline, f)

proc_t *open() {
	// allocate a struct
	proc_t *sh3=malloc(sizeof(proc_t));
	if(!sh3) return sh3;
	
	// set PC and PR to 0xa0000000
	sh3->registers.PC=0xa0000000;
	sh3->registers.PR=0xa0000000;
	
	// set SR to 0x70000xfx
	sh3->flags.MD=sh3->flags.RB=sh3->flags.BL=1;
	sh3->flags.IMASK=0xf;
	sh3->flags.FD=0;
	
	// set VBR to 0x00000000
	sh3->registers.VBR=0x00000000;
	
	// invalidate the instruction pipeline
	invalidatePipeline(sh3);
	
	// return said struct
	return sh3;
}

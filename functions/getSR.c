DEPENDS(proc_t, t)
DEPENDS(longword_t, t)
DEPENDS(sr_t, t)

INTERNAL(longword_t getSR(proc_t *sh3) {
	// initialize SR to zeros
	sr_t SR;
	SR.word=0x000000;
	
	// flags
	SR.T=sh3->T;
	SR.S=sh3->S;
	SR.Q=sh3->Q;
	SR.M=sh3->M;
	
	// interrupt mask
	SR.IMASK=sh3->IMASK;
	
#if defined(LEAST_SH3)
	// FPU disable
	SR.FD=sh3->FD;
	
	// exception block
	SR.BL=sh3->BL;
	
	// register bank
	SR.RB=sh3->RB;
	
	// operating mode
	SR.MD=sh3->MD;
#endif
	
	return SR.word;
})

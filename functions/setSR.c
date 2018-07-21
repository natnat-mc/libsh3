DEPENDS(proc_t, t)
DEPENDS(longword_t, t)
DEPENDS(sr_t, t)

INTERNAL(void setSR(proc_t *sh3, longword_t data) {
	// initialize SR to zeros
	sr_t SR;
	SR.word=data;
	
	// flags
	sh3->T=SR.T;
	sh3->S=SR.S;
	sh3->Q=SR.Q;
	sh3->M=SR.M;
	
	// interrupt mask
	sh3->IMASK=SR.IMASK;
	
	// FPU disable
	sh3->FD=SR.FD;
	
	// exception block
	sh3->BL=SR.BL;
	
	// register bank
	sh3->RB=SR.RB;
	
	// operating mode
	sh3->MD=SR.MD;
})
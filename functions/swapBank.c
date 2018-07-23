DEPENDS(proc_t, t)
DEPENDS(longword_t, t)

INTERNAL(void swapBank(proc_t *sh3) {
	for(int i=0; i<8; i++) {
		longword_t old=sh3->R[i];
		sh3->R[i]=sh3->RB[i];
		sh3->RB[i]=old;
	}
})

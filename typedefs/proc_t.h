DEPENDS(ulongword_t)
DEPENDS(longword_t)

typedef struct{
	// general purpose registers
	longword_t R[16];
	
	// PC-related registers
	longword_t PC, PR, SPC;
	
	// multiplication registers
	longword_t MACH, MACL;
	
	// system and control registers
	longword_t VBR, GBR;
	longword_t SPC;
	
	// flags, not in registers
	ulongword_t T, S, M, Q;
	ulongword_t MD, RB, BL, FD;
	ulongword_t IMASK;
} proc_t;

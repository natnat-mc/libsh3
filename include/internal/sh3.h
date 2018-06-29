#ifndef _SH3_H
#define _SH3_H

#include "typedef.h"
#include "macro.h"
#include "mmu.h"

// SR register struct
typedef union LONGWORD sh3_sr_u {
	longword_t longword;
	struct LONGWORD {
		unsigned:1; // zero
		unsigned MD:1;
		unsigned RB:1;
		unsigned BL:1;
		unsigned:12; // RC
		unsigned:3; // zero
		unsigned:1; // DSP
		unsigned:1; // DMY
		unsigned:1; // DMX
		unsigned M:1;
		unsigned Q:1;
		unsigned I:4;
		unsigned:1; // RF1
		unsigned:1; // RF0
		unsigned S:1;
		unsigned T:1;
	}
} sh3_sr_t;

// status bitfield
typedef struct LONGWORD sh3_status_st {
	unsigned delayed:1;
	unsigned interrupts:1;
} sh3_status_t

// SH3 state struct
typedef struct BIG ALIGN(4) sh3_state_st {
	// general registers
	longword_t R[16];
	
	// system registers
	sh3_sr_t SR;
	longword_t MACH, MACL, PR;
	longword_t PC;
	
	// control registers
	longword_t GBR, VBR, SSR, SPC;
	
	// MMU
	mmu_t mmu;
	
	// status bitfield
	sh3_status_t status;
} sh3_state_t;

// initialization function
void SH3_init(sh3_state_t *sh3);

// execution function
void SH3_exec(sh3_state_t *sh3);

#endif //_SH3_H

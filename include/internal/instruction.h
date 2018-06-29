#ifndef _INSTRUCTION_H
#define _INSTRUCTION_H

#include "typedef.h"
#include "macro.h"

// instruction union
typedef union WORD instruction_u {
	word_t word;
	struct WORD {
		unsigned nibble:4;
	};
	struct WORD {
		unsigned x:16;
	} fmt_0;
	struct WORD {
		unsigned x:4;
		unsigned n:4;
		unsigned x1:8;
	} fmt_n;
	struct WORD {
		unsigned x:4;
		unsigned m:4;
		unsigned x1:8;
	} fmt_m;
	struct WORD {
		unsigned x:4;
		unsigned n:4;
		unsigned m:4;
		unsigned x1:4;
	} fmt_nm;
	struct WORD {
		unsigned x:8;
		unsigned m:4;
		unsigned d:4;
	} fmt_md;
	struct WORD {
		unsigned x:8;
		unsigned n:4;
		unsigned d:4;
	} fmt_nd4;
	struct WORD {
		unsigned x:4;
		unsigned n:4;
		unsigned m:4;
		unsigned d:4;
	} fmt_nmd;
	struct WORD {
		unsigned x:8;
		unsigned d:8;
	} fmt_d;
	struct WORD {
		unsigned x:4;
		unsigned d:12;
	} fmt_d12;
	struct WORD {
		unsigned x:4;
		unsigned n:4;
		unsigned d:8;
	} fmt_nd8;
	struct WORD {
		unsigned x:8;
		signed i:8;
	} fmt_i;
	struct WORD {
		unsigned x:4;
		unsigned n:4;
		signed i:8;
	} fmt_ni;
} instruction_t;

#endif //_INSTRUCTION_H

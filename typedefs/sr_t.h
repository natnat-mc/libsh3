DEPENDS(longword_t)

TYPE(union)

INTERNAL(typedef union sr_t {
	longword_t word;
	struct {
		unsigned:1;
		
		/* operating mode (SH3+)
			* 1: privileged mode
			* 0: user mode
			*/
#if defined(LEAST_SH3)
		unsigned MD:1;
#else
		unsigned:1;
#endif
		
		/* register bank (SH3+)
			* 1: bank 1
			* 0: register 0
			*/
#if defined(LEAST_SH3)
		unsigned RB:1;
#else
		unsigned:1
#endif
		
		/* exception block (SH3+)
			* 1: blocks exceptions
			* 0: accepts exceptions
			*/
#if defined(LEAST_SH3)
		unsigned BL:1;
#else
		unsigned:1
#endif
		
		unsigned:12;
		
		/* FPU disable (SH3+)
			* 1: disable FPU and throws exceptions
			* 0: enables FPU
			*/
#if defined(LEAST_SH3)
		unsigned FD:1;
#else
		unsigned:1
#endif
		
		unsigned:5;
		
		/* division flags
			* used by DIV0S, DIV0U and DIV1
			*/
		unsigned M:1;
		unsigned Q:1;
		
		/* interrupt mask
			* controls which interrupts should be received
			*/
		unsigned IMASK:4:
		
		unsigned:2;
		
		/* saturate flag
			* used in MAC instructions
			*/
		unsigned S:1;
		
		/* T flag
			* used basically anything
			* also means True
			*/
		unsigned T:1;
	};
} sr_t;)

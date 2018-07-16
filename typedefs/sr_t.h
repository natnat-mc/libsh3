DEPENDS(longword_t)

INTERNAL(typedef union {
	longword_t word;
	struct {
		unsigned:1;
		
		/* operating mode
		 * 1: privileged mode
		 * 0: user mode
		 */
		unsigned MD:1;
		
		/* register bank
		 * 1: bank 1
		 * 0: register 0
		 */
		unsigned RB:1;
		
		/* block
		 * 1: blocks exceptions
		 * 0: accepts exceptions
		 */
		unsigned BL:1;
		
		unsigned:12;
		
		/* FPU disable
		 * 1: disable FPU and throws exceptions
		 * 0: enables FPU
		 */
		unsigned FD:1;
		
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

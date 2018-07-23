DEPENDS(ulongword_t)
DEPENDS(longword_t)
DEPENDS(word_t)
DEPENDS(instruction_f_t)

TYPE(struct)
OPAQUE(true)

typedef struct proc_t {
	/* processor registers
	 * these are registers that are accessible via instructions
	 * these do not have a dedicated memory address
	 */
	struct {
		/* general purpose registers
		 * these registers are used in instructions
		 * R0 is also the return value of functions and has special capabilities
		 * R15 is also the stack pointer
		 */
		longword_t R[16];
		
		/* banked out general purpose registers (SH3+)
		 * these are the R0-R7 that are not currently being used
		 * these are swapped when RB changes
		 * the swap function is swapBank and is internal
		 * it is called by setSR
		 */
#if defined(LEAST_SH3)
		longword_t RB[8];
#endif
		
		/* system registers
		 * PC is the program counter, the address at which the processor starts to prefetch instructions
		 * PR is the procedure register, in which the PC is stored on subroutine call
		 * MACH and MACL are the destination registers for multiply and MAC instruction
		 * FPUSCR (SH4+ with FPU) is the FPU control register
		 * FPUL (SH4+ with FPU) is the floating point communication register
		 */
		longword_t PC, PR;
		longword_t MACH, MACL;
#if defined(LEAST_SH4)&&!defined(NOFPU)
		longword_t FPUSCR, FPUL;
#endif
		
		/* control registers
		 * SR (actually stored as individual flags) is the status register which is responsible for tracking the current state of the CPU
		 * VBR is the vector base register, the base address used to calculate jump address in case of interrupt or exception
		 * GBR is the general base register, the base address used in GBR indirect addressing mode
		 * SPC (SH3+) is the save program counter register, in which the PC is stored on interrupt or exception
		 * SSR (SH3+) is the save status register, in which the SR is stored on interrupt or exception
		 * SGR (SH4A) is the save general register, in which R15 is stored on interrupt or exception
		 * DBR (SH4+) is the debug base register, which is used instead of VBR when debug mode is enabled
		 */
		longword_t VBR, GBR;
#if defined(LEAST_SH3)
		longword_t SPC, SSR;
#endif
#if defined(SH4A)
		longword_t SGR;
#endif
#if defined(LEAST_SH4)
		longword_t DBR
#endif
	} registers;
	
	/* flags
	 * the processor flags are not stored in registers
	 * this way, it is actually faster to use them because they will reside on the cache most of the time
	 * also, this means that SR isn't stored in this struct and must be reconstructed
	 */
	struct {
		int T, S, M, Q;
#if defined(LEAST_SH3)
		int MD, RB, BL, FD;
#endif
		int IMASK;
	} flags;
	
	/* instruction pipeline
	 * contains the instruction fetched from RAM and the decoded instruction
	 */
	struct {
		word_t inst0, inst1;
		instruction_f_t inst;
		int delayed;
	} pipeline;
} proc_t;

DEPENDS(ulongword_t)
DEPENDS(longword_t)
DEPENDS(word_t)

typedef struct {
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
		
		/* PC-related registers
		 * PC is the program counter, the address in RAM at which the instructions will be fetched
		 * PR is the subroutine register, in which PC is stored when calling a subroutine
		 * SPC is the save PC register, in which PC is stored when entering exception processing mode
		 */
		longword_t PC, PR, SPC;
		
		/* multiplication registers
		 * these form a 64bit word
		 * these registers are written by multiplication instructions
		 */
		longword_t MACH, MACL;
		
		/* system and control registers
		 * VBR is the base address of the interrupt handler
		 * GBR is the base address at which to start reading memory
		 * SSR is the save status register, in which SR is stored when entering exception processing mode
		 */
		longword_t VBR, GBR;
		longword_t SSR;
	} registers;
	
	/* flags
	 * the processor flags are not stored in registers
	 * this way, it is actually faster to use them because they will reside on the cache most of the time
	 * also, this means that SR isn't stored in this struct and must be reconstructed
	 */
	struct {
		ulongword_t T, S, M, Q;
		ulongword_t MD, RB, BL, FD;
		ulongword_t IMASK;
	} flags;
	
	/* instruction pipeline
	 * contains the instruction fetched from RAM
	 */
	struct {
		word_t inst0, inst1;
	} pipeline;
} proc_t;

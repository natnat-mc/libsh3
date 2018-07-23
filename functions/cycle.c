DEPENDS(proc_t, t)

DEPENDS(decode, f)
DEPENDS(read_word, f)

void cycle(proc_t *sh3) {
	// execute decoded instruction
	if(sh3->pipeline.inst) sh3->pipeline.inst(sh3->pipeline.inst0);
	
	// decode next instruction
	sh3->pipeline.inst0=sh3->pipeline.inst1;
	int result=decode(sh3->pipeline.inst0, sh3->flags.MD, sh3->pipeline.delayed, &sh3->pipeline.inst);
	
	// check for illegal values
	if(result==-1) {
		// general illegal instruction (or privileged, actually)
	} else if(result==-2) {
		// slot illegal instruction
	}
	
	// we're no longer in a delay slot
	sh3->pipeline.delayed=0;
	
	// read next instruction
	result=read_word(sh3, sh3->registers.PC, &sh3->pipeline.inst1);
	
	// check for read error
	if(result) {
		// bad read
	}
}

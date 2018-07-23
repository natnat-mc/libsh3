DEPENDS(proc_t, t)

#define NOP 0x0090

INTERNAL(void invalidatePipeline(proc_t *sh3) {
	// fill the pipeline with NOPs
	sh3->pipeline.inst0=NOP;
	sh3->pipeline.inst1=NOP;
	
	// reset the instruction function
	sh3->pipeline.inst=NULL;
	
	// we're not delayed anymore
	sh2->pipeline.delayed=0;
})

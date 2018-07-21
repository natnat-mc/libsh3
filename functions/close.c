DEPENDS(proc_t, t)

void close(proc_t* sh3) {
	// free struct
	free(sh3);
}

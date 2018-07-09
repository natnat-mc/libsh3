DEPENDS(word_t)

INTERNAL(typedef union WORD {
	word_t word;
	struct {
		unsigned x:16
	} fmt_0;
} instruction_t;)

DEPENDS(word_t)

TYPE(union)

INTERNAL(typedef union instruction_t {
	word_t word;
	struct {
		unsigned x:16;
	} fmt_0;
} instruction_t;)

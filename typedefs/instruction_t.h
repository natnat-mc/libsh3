DEPENDS(word_t)

TYPE(union)

INTERNAL(typedef union instruction_t {
	word_t word;
	struct {
		unsigned nibble:4;
	};
	struct {
		unsigned x:16;
	} fmt_0;
	struct {
		unsigned x:4;
		unsigned n:4;
		unsigned x1:8;
	} fmt_n;
	struct {
		unsigned x:4;
		unsigned m:4;
		unsigned x1:8;
	} fmt_m;
	struct {
		unsigned x:4;
		unsigned n:4;
		unsigned m:4;
		unsigned x1:4;
	} fmt_nm;
	struct {
		unsigned x:8;
		unsigned m:4;
		unsigned d:4;
	} fmt_md;
	struct {
		unsigned x:8;
		unsigned n:4;
		unsigned d:4;
	} fmt_nd4;
	struct {
		unsigned x:4;
		unsigned n:4;
		unsigned m:4;
		unsigned d:4;
	} fmt_nmd;
	struct {
		unsigned x:8;
		unsigned d:8;
	} fmt_d;
	struct {
		unsigned x:4;
		unsigned d:12;
	} fmt_d12;
	struct {
		unsigned x:4;
		unsigned n:4;
		unsigned d:8;
	} fmt_nd8;
	struct {
		unsigned x:8;
		signed i:8;
	} fmt_i;
	struct {
		unsigned x:4;
		unsigned n:4;
		signed i:8;
	} fmt_ni;
} instruction_t;)

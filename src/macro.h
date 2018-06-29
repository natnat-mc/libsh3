#ifndef _MACRO_H
#define _MACRO_H

// n-byte alignment struct attribute
#define ALIGN(n)  __attribute__((packed,aligned(n)))

// big-endian struct attribute
#define BIG __attribute__((scalar_storage_order("big-endian")))

// word- and longword-based struct attributes
#define WORD __attribute__((scalar_storage_order("big-endian"),packed,aligned(2)))
#define LONGWORD __attribute__((scalar_storage_order("big-endian"),packed,aligned(4)))

// mask check
#define MASK_EQ(a, b, mask) (((a)&(mask))==((b)&(mask)))

// sign extension
#define SIGN_EXTEND8(a) (((a)&0x80)?(0x000000ff&(a)):(0xffffff00|(a)))
#define SIGN_EXTEND12(a) (((a)&0x800)?(0x00000fff&(a)):(0xfffff000|(a)))
#define SIGN_EXTEND16(a) (((a)&0x8000)?(0x0000ffff&(a)):(0xffff0000|(a)))

#endif //_MACRO_H

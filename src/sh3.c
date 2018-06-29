#include "sh3.h"
#include "macro.h"
#include "typedef.h"
#include "instruction.h"
#include "mmu.h"

//BEGIN macros
// macros to handle interrupts
#include <stdio.h>
#include <stdlib.h>
#define interrupt(code) do { \
	fprintf(stderr, "Interrupt: %d\n", code); \
	abort(); \
} while(0)
#define INTERRUPT_READ 0
#define INTERRUPT_WRITE 1
#define INTERRUPT_DELAYED 2

// macros to define instructions
#define INST0(name) void name(sh3_state_t *sh3)
#define INST1(name, a) void name(sh3_state_t *sh3, longword_t a)
#define INST2(name, a, b) void name(sh3_state_t *sh3, longword_t a, longword_t b)
#define INST3(name, a, b, c) void name(sh3_state_t *sh3, longword_t a, longword_t b, longword_t c)

// macro to detect instruction
#define INST_DETECT(code, mask, action) if(MASK_EQ(op.word, code, mask)) do {action;} while(0)

// macros to get registers
#define R sh3->R
#define PC sh3->PC
#define PR sh3->PR
#define T sh3->SR.T
#define S sh3->SR.S
#define GBR sh3->GBR
#define MACH sh3->MACH
#define MACL sh3->MACL

// macros to access memory
#define readByte(address, var) do { \
	byte_t byte; \
	if(!MMU_getByte(&sh3->mmu, address, &byte)) interrupt(INTERRUPT_READ); \
	var=byte&0xff; \
} while(0)
#define readWord(address, var) do { \
	word_t word; \
	if(!MMU_getWord(&sh3->mmu, address, &var)) interrupt(INTERRUPT_READ); \
	var=word&0xffff; \
} while(0)
#define readLongword(address, var) do { \
	if(!MMU_getLongword(&sh3->mmu, address, &var)) interrupt(INTERRUPT_READ); \
} while(0)
#define writeByte(address, var) do { \
	if(!MMU_setByte(&sh3->mmu, address, (byte_t) var)) interrupt(INTERRUPT_WRITE); \
} while(0)
#define writeWord(address, var) do { \
if(!MMU_setWord(&sh3->mmu, address, (word_t) var)) interrupt(INTERRUPT_WRITE); \
} while(0)
#define writeLongword(address, var) do { \
if(!MMU_setLongword(&sh3->mmu, address, var)) interrupt(INTERRUPT_WRITE); \
} while(0)
//END macros

//BEGIN prototypes
void inst(sh3_state_t *sh3);
void delay(sh3_state_t *sh3, int len);
void instImp(sh3_state_t *sh3, instruction_t op);

// arithmetic operations
INST2(inst_ADD, m, n);
INST2(inst_ADDI, i, n);
INST2(inst_ADDC, m, n);
INST2(inst_ADDV, m, n);

// logical operations
INST2(inst_AND, m, n);
INST1(inst_ANDI, i);
INST1(inst_ANDM, i);

// branch operations
INST1(inst_BF, d);
INST1(inst_BFS, d);
INST1(inst_BRA, d);
INST1(inst_BRAF, m);
INST1(inst_BSR, d);
INST1(inst_BSRF, m);
INST1(inst_BT, d);
INST1(inst_BTS, d);

// control operations
INST0(inst_CLRMAC);
INST0(inst_CLRS);
INST0(inst_CLRT);
//END prototypes

//BEGIN lib functions
void SH3_init(sh3_state_t *sh3) {
	// clear general purpose registers (although not required by the spec)
	for(int i=0; i<16; i++) sh3->R[i]=0;
	
	// set the default bits in SR
	sh3->SR.longword=0;
	sh3->SR.MD=1;
	sh3->SR.RB=1;
	sh3->SR.BL=1;
	
	// clear control registers (although not required by the spec)
	sh3->GBR=0;
	sh3->SSR=0;
	sh3->SPC=0;
	
	// clear system registers (although not required by the spec)
	sh3->MACH=0;
	sh3->MACL=0;
	sh3->PR=0;
	
	// set PC to 0xa0000000
	sh3->PC=0xa0000000
	
	// set VBR to 0x00000000
	sh3->VBR=0x00000000
	
	// set status bitfield
	//TODO be more accurate
	sh3->status.delayed=0;
	sh3->status.interrupts=1;
}

void SH3_exec(sh3_state_t *sh3) {
	// execute instructions until we are killed
	// TODO do better than this
	while(1) inst(sh3);
}
//END lib functions

//BEGIN helper functions
// function to execute a single instruction
void inst(sh3_state_t *sh3) {
	instruction_t op;
	
	// fetch instruction from RAM
	//TODO be more accurate
	if(!MMU_fetchInstruction(PC-4, &op)) interrupt(INTERRUPT_READ);
	
	// execute the instruction
	instImp(sh3, op);
}
// function to execute the instruction
void instImp(sh3_state_t *sh3, instruction_t op) {
	// arithmetic operations
	INST_DETECT(0b0011000000001100, 0xf00f, inst_ADD(sh3, op.fmn_nm.m, op.fmt_nm.n));
	INST_DETECT(0b0111000000000000, 0xf000, inst_ADDI(sh3, op.fmt_ni.i, op.fmt_ni.n));
	INST_DETECT(0b0011000000001110, 0xf00f, inst_ADDC(sh3, op.fmt_nm.m, op.fmt_nm.n));
	INST_DETECT(0b0011000000001111, 0xf00f, inst_ADDV(sh3, op.fmt_nm.m, op.fmt_nm.n));
	
	// logical operations
	INST_DETECT(0b0010000000001001, 0xf00f, inst_AND(sh3, op.fmt_nm.m, op.fmt_nm.n));
	INST_DETECT(0b1100100100000000, 0xff00, inst_ANDI(sh3, op.fmt_i.i));
	INST_DETECT(0b1100110100000000, 0xff00, inst_ANDM(sh3, op.fmt_i.i));
	
	// branch operations
	INST_DETECT(0b1000101100000000, 0xff00, inst_BF(sh3, op.fmt_d.d));
	INST_DETECT(0b1000111100000000, 0xff00, inst_BFS(sh3, op.fmt_d.d));
	INST_DETECT(0b1010000000000000, 0xf000, inst_BRA(sh3, op.fmt_d12.d));
	INST_DETECT(0b0000000000100011, 0xf0ff, inst_BRAF(sh3, op.fmt_m.m));
	INST_DETECT(0b1011000000000000, 0xf000, inst_BSR(sh3, op.fmt_d12.d));
	INST_DETECT(0b0000000000000011, 0xf0ff, inst_BSRF(sh3, op.fmt_m.m));
	INST_DETECT(0b1000100100000000, 0xff00, inst_BT(sh3, op.fmt_d.d));
	INST_DETECT(0b1000110100000000, 0xff00, inst_BTS(sh3, op.fmt_d.d));
	
	// control operations
	INST_DETECT(0b0000000000101000, 0xffff, inst_CLRMAC(sh3));
	INST_DETECT(0b0000000001001000, 0xffff, inst_CLRS(sh3));
	INST_DETECT(0b0000000000001000, 0xffff, inst_CLRT(sh3));
}

//function to execute instruction while delaying
void delay(sh3_state_t *sh3, longword_t slot) {
	//TODO make something more accurate
	if(sh3->status.delayed) interrupt(INTERRUPT_DELAYED);
	sh3->status.delayed=1;
	sh3->status.interrupts=0;
	
	// fetch instruction from RAM
	//TODO be more accurate
	if(!MMU_fetchInstruction(slot-4, &op)) interrupt(INTERRUPT_READ);
	
	instImp(sh3, op);
	
	sh3->status.delayed=0;
	sh3->status.interrupts=1;
}
//END helper functions

//BEGIN instructions

//BEGIN arithmetic operations
// ADD Rm,Rn
INST2(inst_ADD, m, n) {
	R[n]+=R[m];
	PC+=2;
}
// ADD #imm,Rn
INST2(inst_ADDI, i, n) {
	R[n]+=SIGN_EXTEND8(i);
	PC+=2;
}
// ADDC Rm,Rn
INST2(inst_ADDC, m, n) {
	longword_t tmp0, tmp1;
	
	tmp1=R[n]+[m];
	tmp0=R[n];
	
	R[n]=tmp1+T;
	if(tmp0>tmp1) T=1;
	else T=0;
	if(tmp1>R[n]) T=1;
	
	PC+=2;
}
// ADDV Rm,Rn
INST2(inst_ADDV, m, n) {
	longword_t dest, src, ans;
	
	if(R[n]>=0) dest=0;
	else dest=1;
	
	if(R[m]>=0) src=0;
	else src=1;
	
	src+=dest;
	R[n]+=R[m];
	
	if(R[n]>=0) ans=0;
	else ans=1;
	ans+=dest;
	
	if(src==0||src==2) {
		if(ans==1) T=1;
		else T=0;
	} else {
		T=0;
	}
	
	PC+=2;
}
//END arithmetic operations

//BEGIN logical operations
// AND Rm,Rn
INST2(inst_AND, m, n) {
	R[n]&=R[m];
	PC+=2;
}
// AND #imm,R0
INST1(inst_ANDI, i) {
	R[0]&=0xff&i;
	PC+=2;
}
// AND #imm,@(R0,GBR)
INST1(inst_ANDM, i) {
	longword_t tmp;
	readByte(GBR+R[0], tmp);
	writeByte(GBR+R[0], tmp&i);
	PC+=2;
}
//END logical operations

//BEGIN branch operatons
// BF label
INST1(inst_BF, d) {
	if(T) PC+=2;
	else PC+=(SIGN_EXTEND8(d)<<1)+4;
}
// BF/S label
INST1(inst_BFS, d) {
	longword_t tmp=PC;
	
	if(T) {
		PC+=2;
	} else {
		PC+=(SIGN_EXTEND8(d)<<1)+4;
		delay(tmp+2);
	}
}
// BRA label
INST1(inst_BRA, d) {
	longword_t tmp=PC;
	PC+=(SIGN_EXTEND12(d)<<1)+4;
	delay(tmp+2);
}
// BRAF Rm
INST1(inst_BRAF, m) {
	longword_t tmp=PC;
	PC+=R[m];
	delay(temp+2);
}
// BSR label
INST1(inst_BSR, d) {
	PR=PC;
	PC+=(SIGN_EXTEND12(d)<<1)+4;
	delay(PR+2);
}
// BSRF Rm
INST1(inst_BSRF, m) {
	PR=PC;
	PC+=R[m];
	delay(PR+2);
}
// BT label
INST1(inst_BT, d) {
	if(T) PC+=(SIGN_EXTEND8(d)<<1)+4;
	else PC+=2;
}
// BT/S label
INST1(inst_BTS, d) {
	longword_t tmp=PC;
	
	if(T) {
		PC+=(SIGN_EXTEND8(d)<<1)+4;
		delay(tmp+2);
	} else {
		PC+=2;
	}
}
//END branch operations

//BEGIN control operations
// CLRMAC
INST0(inst_CLRMAC) {
	MACH=0;
	MACL=0;
	PC+=2;
}
// CLRS
INST0(inst_CLRS) {
	S=0;
	PC+=2;
}
// CLRT
INST0(inst_CLRT) {
	T=0;
	PC+=2;
}
//END control operations

//END instructions

//TODO continue at page 187/581

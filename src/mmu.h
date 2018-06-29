#ifndef _MMU_H
#define _MMU_H

#include "typedef.h"
#include "macro.h"
#include "instruction.h"

// getters
typedef int(*byte_getter_t)(longword_t, byte_t*);
typedef int(*word_getter_t)(longword_t, word_t*);
typedef int(*longword_getter_t)(longword_t, longword_t*);

// setters
typedef int(*byte_setter_t)(longword_t, byte_t);
typedef int(*word_setter_t)(longword_t, word_t);
typedef int(*longword_setter_t)(longword_t, longword_t);

// access checkers
typedef int(*access_checker_t)(longword_t, longword_t);

// MMU element
typedef struct ALIGN(4) mmu_element_st {
	// element type and access
	longword_t type;
	access_checker_t accessChecker;
	union ALIGN(4) {
		// either getters and setters or direct pointer
		struct ALIGN(4) {
			void* privData;
			byte_getter_t byteGetter;
			byte_setter_t byteSetter;
			word_getter_t wordGetter;
			word_setter_t wordSetter;
			longword_getter_t longwordGetter;
			longword_setter_t longwordSetter;
		};
		longword_t* ptr;
	};
} mmu_element_t;

// the MMU itself
typedef struct ALIGN(4) mmu_st {
	int count;
	longword_t lastAddress;
	mmu_element_t elements[32];
} mmu_t;

// memory access functions
int MMU_getByte(mmu_t *mmu, longword_t address, byte_t *value);
int MMU_getWord(mmu_t *mmu, longword_t address, word_t *value);
int MMU_getLongword(mmu_t *mmu, longword_t address, longword_t *value);
int MMU_setByte(mmu_t *mmu, longword_t address, byte_t value);
int MMU_setWord(mmu_t *mmu, longword_t address, word_t value);
int MMU_setLongword(mmu_t *mmu, longword_t address, longword_t value);

// instruction fetch functions
int MMU_fetchInstruction(mmu_t *mmu, instruction_t *value);

// initialization function
void MMU_init(mmu_t *mmu);

#endif //_MMU_H

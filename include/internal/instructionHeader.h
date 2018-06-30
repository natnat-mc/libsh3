// include required libs
#include "instruction.h"
#include "sh3.h"
#include "common.h"
#include "macro.h"
#include "typedef.h"

// easy access to registers
#define R sh3->R
#define PC sh3->PC
#define PR sh3->PR
#define GBR sh3->GBR
#define MACH sh3->MACH
#define MACL sh3->MACL

// easy access to flags
#define T sh3->SR.T
#define S sh3->SR.S

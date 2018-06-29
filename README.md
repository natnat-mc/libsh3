#Super-H emulator
This lib is intended to emulate a SH3, SH4 or SH4A processor.  
The type of processor and its options are controlled at compile time with #define statements in config.h  

#TODO list
1. Implement all instruction
2. Make files containing the instructions, their name, the C code to implement them, their bits and their description
3. Parse these files to generate some code auto-magically (the decoder, and part of the interpreter, assembler and disassembler)
4. Also generate documentation file, to be completed manually
5. Implement the processor status and interruptions according to the spec
6. Implement the peripherals like the MMU according to the spec
7. Implement hardware ports and hardware registers according to the spec
8. Implement an assembler and a disassembler using the auto-generated code and docs
9. Implement a debugger

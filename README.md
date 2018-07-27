# Super-H emulator
The type of processor and its options are controlled at config time.  
A huge part of the code is generated auto-magically by the lua code in `auto`; this allows for automatic generation of documentation, instruction implementation code, decoder code and assembler code.

# Configuration files
These files, in `ini` format are responsible for controlling the generation of the library.
They accept values referring to other values from past sections in the format `%section.key%`

## `config.ini`
This file contains the general configuration, such as the emulated processor and MPU, the program name, version and release mode, the naming convention of the functions and types as well as what code to generate.

## `deps.ini`
This file contains the top-level dependencies of the designated target, that is, the functions and types that the target should export to the user.

## `files.ini`
This file contains the list of all the templates used by the auto-magical generator. It is responsible for converting a function or type name to a filename on disk.

# Supported models
See the `models` and `mpus` folders  
* SH1  
* SH2  
* SH3  
* SH4  
* soon SH4A  
* potentially SH3-DSP  
* potentially SH2A if I find a way to handle dual-word instructions  

# ToDo list
* implement all instructions  
* then check for the NOP code to invalidate the pipeline  
* implement peripherals according to the spec  
* implement assembler and disassembler  
* implement a debugger  

# Building
To build, you should first edit `config.ini` to target a specific processor model and MPU.  
Then, you should go into the `auto` folder and execute `auto.lua` with a Lua interpreter (tested with lua5.3).  
Then, when the code is generated, you should go into the `output` folder and execute `make` to compile the generated code. This will generate all the target you specified in the config file.

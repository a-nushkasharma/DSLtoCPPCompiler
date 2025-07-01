# DSL to CPP Compiler 

A tool that converts simplified smart contracts written in a custom Domain-Specific Language (DSL) into equivalent C++ code.

## Project Overview

This compiler parses and semantically analyzes a Solidity-like language and generates equivalent C++ source code. 
Each file contains the code for teh complete DSl semantics commented at the end of it!
It supports:

- **Primitive types**: `uint`, `int`, `bool`, `address`
- **Function declarations** with parameters and return types
- **Arithmetic**, **logical**, and **comparison** operators
- **Control flow constructs**: `if`, `else`, and `return`
- **Static typing** and **basic type checking**
- Generation of **clean, readable, and valid C++**

---
## Directory Structure
```bash
dsl-compiler/
├── build/ #contains the build files                
│   ├── contract.cpp  #final CPP file
│   └── ...
├── test/             #.dsl files
│   └── contract.dsl
├── parser.y             # Bison grammar rules
├── scanner.l            # Flex token definitions
├── main.cpp             # Compiler driver
├── CMakeLists.txt       # CMake build configuration
├──ast.h                  # Abstract syntax tree node definitions
└── README.md
```
---
# Build Instructions
```bash
git clone https://github.com/a-nushkasharma/DSLtoCPPCompiler.git
cd (to the file)
```
Incase one wishes to remove the existing build:
```bash
rm -rf build
```
To build:
```bash
mkdir build 
cd build
cmake .. -G "MinGW Makefiles"
mingw32-make clean
mingw32-make
```

#Using the Compiler
After building the project:
```bash
./dsl_compiler ../input.dsl > output.cpp
```
To compile the generated C++:
```bash
g++ -std=c++17 -o program output.cpp
./program
```

Note: An example case is already present in  test/contract.dsl and its correcponsing CPP code is in build/contract.cpp

## Bottlenecks and Challenges encountered in development:
1. Designing the Grammar
- Creating the grammar for DSL was tricky.
-Had to make sure it was clear, avoided conflicts, and could handle all the language features (like expressions and function calls) correctly.
-Hence startes with implementing small parts of the grammar.

2. Implementing AST for all of the grammar
---
3. Building System Integration
Combining Flex, Bison, and C++ in the same build system caused some issues, like missing header files or files being built in the wrong order.


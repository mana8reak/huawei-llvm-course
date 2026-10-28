LLVM_CONFIG ?= llvm-config
LLVM_CPPFLAGS := $(shell $(LLVM_CONFIG) --cppflags)
LLVM_LDFLAGS := $(shell $(LLVM_CONFIG) --ldflags)
LLVM_LIBS := $(shell $(LLVM_CONFIG) --libs core)

GENERATOR := src/app_generator.cpp
GR_DEPS := ../graphic-app/src/sim.c -lSDL2
GR_MAIN := ../graphic-app/src/start.c

make-gen:
	clang++ $(LLVM_CPPFLAGS) $(LLVM_LDFLAGS) $(LLVM_LIBS) $(GENERATOR) -o generator.out

generate: make-gen
	./generator.out > generated.ll

make-emu:
	clang++ $(LLVM_CPPFLAGS) $(LLVM_LDFLAGS) $(LLVM_LIBS) $(GENERATOR) $(GR_DEPS) -o emulator.out

emulate: make-emu
	./emulator.out

app: generate
	clang generated.ll $(GR_DEPS) $(GR_MAIN) -o app

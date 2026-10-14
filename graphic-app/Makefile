all: app app-opt ir

ir: appO2.ll appOs.ll

appO2: appO2.ll

appOs: appOs.ll

appO2.ll: src/app.c
	mkdir -p LLVM-IR
	clang -O2 -emit-llvm -S src/app.c -o LLVM-IR/$@

appOs.ll: src/app.c
	mkdir -p LLVM-IR
	clang -Os -emit-llvm -S src/app.c -o LLVM-IR/$@

app: src/start.c src/sim.c src/app.c
	clang $^ -lSDL2 -o $@
app-opt: src/start.c src/sim.c src/app.c
	clang $^ -lSDL2 -o $@ -O2

clean:
	rm -rf LLVM-IR
	rm -f app app-opt
.PHONY: all clean appO2 appOs ir

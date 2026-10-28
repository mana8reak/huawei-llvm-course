#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/raw_ostream.h"
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/Support/TargetSelect.h>

#define EMULATE 1

#if EMULATE
#include "../../graphic-app/src/sim.h"
#endif

#include <cstdlib>
#include <memory>
#include <llvm/ExecutionEngine/GenericValue.h>

namespace llvm {
    class ExecutionEngine;
}

using namespace llvm;

namespace {
    struct Runtime {
        LLVMContext &context;
        Module &module;
        IRBuilder<> builder;
        Type *voidTy;
        Type *i1Ty;
        Type *i16Ty;
        Type *i32Ty;
        Type *i64Ty;
        PointerType *i32PtrTy;
        FunctionCallee putPixel;
        FunctionCallee flush;
        FunctionCallee hasClick;
        FunctionCallee getClick;
        FunctionCallee rand;
        FunctionCallee signedMin;
        FunctionCallee unsignedMin;

        Runtime(LLVMContext &context, Module &module)
            : context(context), module(module), builder(context),
              voidTy(Type::getVoidTy(context)), i1Ty(Type::getInt1Ty(context)),
              i16Ty(Type::getInt16Ty(context)), i32Ty(Type::getInt32Ty(context)),
              i64Ty(Type::getInt64Ty(context)),
              i32PtrTy(PointerType::getUnqual(context)) {
            // declare void @simPutPixel(i32, i32, i32)
            putPixel = module.getOrInsertFunction(
                "simPutPixel",
                FunctionType::get(voidTy, {i32Ty, i32Ty, i32Ty}, false));
            // declare void @simFlush(...)
            flush = module.getOrInsertFunction(
                "simFlush", FunctionType::get(voidTy, {}, true));
            // declare i32 @simHasClick(...)
            hasClick = module.getOrInsertFunction(
                "simHasClick", FunctionType::get(i32Ty, {}, true));
            // declare i32 @simGetClick(...)
            getClick = module.getOrInsertFunction(
                "simGetClick", FunctionType::get(i32Ty, {}, true));
            // declare i32 @simRand(...)
            rand = module.getOrInsertFunction(
                "simRand", FunctionType::get(i32Ty, {}, true));
            // declare i32 @llvm.smin.i32(i32, i32)
            signedMin = module.getOrInsertFunction(
                "llvm.smin.i32", FunctionType::get(i32Ty, {i32Ty, i32Ty}, false));
            // declare i32 @llvm.umin.i32(i32, i32)
            unsignedMin = module.getOrInsertFunction(
                "llvm.umin.i32", FunctionType::get(i32Ty, {i32Ty, i32Ty}, false));
        }

        ConstantInt *i32(int value) { return builder.getInt32(value); }
        ConstantInt *i64(int64_t value) { return builder.getInt64(value); }
    };

    Function *createFunction(Runtime &rt, StringRef name, ArrayRef<Type *> args) {
        return Function::Create(FunctionType::get(rt.voidTy, args, false),
                                Function::ExternalLinkage, name, &rt.module);
    }

    void buildDrawCell(Runtime &rt, Function *function) {
        // define void @drawCell(i32 %x, i32 %y, i32 %color)
        auto args = function->arg_begin();
        Value *x = &*args++;
        Value *y = &*args++;
        Value *color = &*args;

        BasicBlock *entry = BasicBlock::Create(rt.context, "entry", function);
        BasicBlock *row = BasicBlock::Create(rt.context, "row", function);
        BasicBlock *pixel = BasicBlock::Create(rt.context, "pixel", function);
        BasicBlock *nextRow = BasicBlock::Create(rt.context, "next_row", function);
        BasicBlock *done = BasicBlock::Create(rt.context, "done", function);

        rt.builder.SetInsertPoint(entry);
        // %4 = shl nsw i32 %x, 2
        Value *baseX = rt.builder.CreateShl(x, rt.i32(2), "", false, true);
        // %5 = shl nsw i32 %y, 2
        Value *baseY = rt.builder.CreateShl(y, rt.i32(2), "", false, true);
        // br label %row
        rt.builder.CreateBr(row);

        rt.builder.SetInsertPoint(row);
        // %dy = phi i32 [ 0, %entry ], [ %nextDy, %nextRow ]
        PHINode *dy = rt.builder.CreatePHI(rt.i32Ty, 2, "dy");
        dy->addIncoming(rt.i32(0), entry);
        // %screenY = add nuw nsw i32 %dy, %baseY
        Value *screenY = rt.builder.CreateAdd(dy, baseY, "", true, true);
        // br label %pixel
        rt.builder.CreateBr(pixel);

        rt.builder.SetInsertPoint(pixel);
        // %dx = phi i32 [ 0, %row ], [ %nextDx, %pixel ]
        PHINode *dx = rt.builder.CreatePHI(rt.i32Ty, 2, "dx");
        dx->addIncoming(rt.i32(0), row);
        // %screenX = add nuw nsw i32 %dx, %baseX
        Value *screenX = rt.builder.CreateAdd(dx, baseX, "", true, true);
        // call void @simPutPixel(i32 %screenX, i32 %screenY, i32 %color)
        rt.builder.CreateCall(rt.putPixel, {screenX, screenY, color});
        // %nextDx = add nuw nsw i32 %dx, 1
        Value *nextDx = rt.builder.CreateAdd(dx, rt.i32(1), "", true, true);
        // %lastPixel = icmp eq i32 %nextDx, 4
        Value *lastPixel = rt.builder.CreateICmpEQ(nextDx, rt.i32(4));
        // br i1 %lastPixel, label %nextRow, label %pixel
        rt.builder.CreateCondBr(lastPixel, nextRow, pixel);
        dx->addIncoming(nextDx, pixel);

        rt.builder.SetInsertPoint(nextRow);
        // %nextDy = add nuw nsw i32 %dy, 1
        Value *nextDy = rt.builder.CreateAdd(dy, rt.i32(1), "", true, true);
        // %lastRow = icmp eq i32 %nextDy, 4
        Value *lastRow = rt.builder.CreateICmpEQ(nextDy, rt.i32(4));
        // br i1 %lastRow, label %done, label %row
        rt.builder.CreateCondBr(lastRow, done, row);
        dy->addIncoming(nextDy, nextRow);

        rt.builder.SetInsertPoint(done);
        // ret void
        rt.builder.CreateRetVoid();
    }

    void buildCreateMap(Runtime &rt, Function *function) {
        // define void @createMap(ptr %map)
        Value *map = &*function->arg_begin();
        BasicBlock *entry = BasicBlock::Create(rt.context, "entry", function);
        BasicBlock *row = BasicBlock::Create(rt.context, "row", function);
        BasicBlock *column = BasicBlock::Create(rt.context, "column", function);
        BasicBlock *border = BasicBlock::Create(rt.context, "border", function);
        BasicBlock *middle = BasicBlock::Create(rt.context, "middle", function);
        BasicBlock *wall = BasicBlock::Create(rt.context, "wall", function);
        BasicBlock *water = BasicBlock::Create(rt.context, "water", function);
        BasicBlock *land = BasicBlock::Create(rt.context, "land", function);
        BasicBlock *nextColumn = BasicBlock::Create(rt.context, "next_column", function);
        BasicBlock *nextRow = BasicBlock::Create(rt.context, "next_row", function);
        BasicBlock *done = BasicBlock::Create(rt.context, "done", function);

        rt.builder.SetInsertPoint(entry);
        // %waterRow = getelementptr i32, ptr %map, i64 192
        Value *waterRow = rt.builder.CreateGEP(rt.i32Ty, map, rt.i64(192));
        // br label %row
        rt.builder.CreateBr(row);

        rt.builder.SetInsertPoint(row);
        // %y = phi i64 [ 0, %entry ], [ %nextY, %nextRow ]
        PHINode *y = rt.builder.CreatePHI(rt.i64Ty, 2, "y");
        y->addIncoming(rt.i64(0), entry);
        // %5 = icmp eq i64 %4, 0
        Value *firstRow = rt.builder.CreateICmpEQ(y, rt.i64(0));
        // %6 = icmp eq i64 %4, 191
        Value *lastRow = rt.builder.CreateICmpEQ(y, rt.i64(191));
        // %rowOffset = mul nuw nsw i64 %y, 384
        Value *rowOffset = rt.builder.CreateMul(y, rt.i64(384), "", true, true);
        // %y32 = trunc i64 %y to i32
        Value *y32 = rt.builder.CreateTrunc(y, rt.i32Ty);
        // %pattern = urem i32 %y32, 25
        Value *pattern = rt.builder.CreateURem(y32, rt.i32(25));
        // %patternWall = icmp ult i32 %pattern, 12
        Value *patternWall = rt.builder.CreateICmpULT(pattern, rt.i32(12));
        // %waterRowPtr = getelementptr i32, ptr %waterRow, i64 %rowOffset
        Value *waterRowPtr = rt.builder.CreateGEP(rt.i32Ty, waterRow, rowOffset);
        // %mapRowPtr = getelementptr i32, ptr %map, i64 %rowOffset
        Value *mapRowPtr = rt.builder.CreateGEP(rt.i32Ty, map, rowOffset);
        // br label %column
        rt.builder.CreateBr(column);

        rt.builder.SetInsertPoint(column);
        // %x = phi i64 [ 0, %row ], [ %nextX, %nextColumn ]
        PHINode *x = rt.builder.CreatePHI(rt.i64Ty, 2, "x");
        x->addIncoming(rt.i64(0), row);
        // %20 = icmp eq i64 %19, 0
        Value *firstColumn = rt.builder.CreateICmpEQ(x, rt.i64(0));
        // icmp eq i64 %19, 383
        Value *lastColumn = rt.builder.CreateICmpEQ(x, rt.i64(383));
        // or i1 %20, %21
        Value *isBorder = rt.builder.CreateOr(firstColumn, lastColumn);
        // or i1 %5, %22
        isBorder = rt.builder.CreateOr(isBorder, firstRow);
        // or i1 %6, %23
        isBorder = rt.builder.CreateOr(isBorder, lastRow);
        // br i1 %isBorder, label %border, label %middle
        rt.builder.CreateCondBr(isBorder, border, middle);

        rt.builder.SetInsertPoint(border);
        // %26 = getelementptr i32, ptr %13, i64 %19
        Value *borderCell = rt.builder.CreateGEP(rt.i32Ty, mapRowPtr, x);
        // store i32 1, ptr %26, align 4, !tbaa !9
        rt.builder.CreateStore(rt.i32(1), borderCell);
        // br label %34
        rt.builder.CreateBr(nextColumn);

        rt.builder.SetInsertPoint(middle);
        // %28 = icmp eq i64 %19, 192
        Value *isWaterColumn = rt.builder.CreateICmpEQ(x, rt.i64(192));
        // br i1 %28, label %29, label %32
        rt.builder.CreateCondBr(isWaterColumn, wall, land);

        rt.builder.SetInsertPoint(wall);
        // br i1 %10, label %30, label %31
        rt.builder.CreateCondBr(patternWall, water, land);

        rt.builder.SetInsertPoint(water);
        // store i32 1, ptr (getelementptr i32, ptr %waterRowPtr, i64 %x)
        rt.builder.CreateStore(rt.i32(1), waterRowPtr);
        rt.builder.CreateBr(nextColumn);

        rt.builder.SetInsertPoint(land);
        // store i32 0, ptr (getelementptr i32, ptr %mapRowPtr, i64 %x)
        rt.builder.CreateStore(rt.i32(0),
                               rt.builder.CreateGEP(rt.i32Ty, mapRowPtr, x));
        rt.builder.CreateBr(nextColumn);

        rt.builder.SetInsertPoint(nextColumn);
        // %nextX = add nuw nsw i64 %x, 1
        Value *nextX = rt.builder.CreateAdd(x, rt.i64(1), "", true, true);
        // %36 = icmp eq i64 %35, 384
        Value *lastX = rt.builder.CreateICmpEQ(nextX, rt.i64(384));
        // br i1 %36, label %15, label %18, !llvm.loop !13
        rt.builder.CreateCondBr(lastX, nextRow, column);
        x->addIncoming(nextX, nextColumn);

        rt.builder.SetInsertPoint(nextRow);
        // %nextY = add nuw nsw i64 %y, 1
        Value *nextY = rt.builder.CreateAdd(y, rt.i64(1), "", true, true);
        Value *lastY = rt.builder.CreateICmpEQ(nextY, rt.i64(192));
        rt.builder.CreateCondBr(lastY, done, row);
        y->addIncoming(nextY, nextRow);

        rt.builder.SetInsertPoint(done);
        // ret void
        rt.builder.CreateRetVoid();
    }

    void buildCalcWave(Runtime &rt, Function *function) {
        // define void @calcWave(ptr %current, ptr %next, ptr %map)
        auto args = function->arg_begin();
        Value *current = &*args++;
        Value *next = &*args++;
        Value *map = &*args;
        BasicBlock *entry = BasicBlock::Create(rt.context, "entry", function);
        BasicBlock *row = BasicBlock::Create(rt.context, "row", function);
        BasicBlock *column = BasicBlock::Create(rt.context, "column", function);
        BasicBlock *update = BasicBlock::Create(rt.context, "update", function);
        BasicBlock *nextColumn = BasicBlock::Create(rt.context, "next_column", function);
        BasicBlock *nextRow = BasicBlock::Create(rt.context, "next_row", function);
        BasicBlock *done = BasicBlock::Create(rt.context, "done", function);

        rt.builder.SetInsertPoint(entry);
        // br label %row
        rt.builder.CreateBr(row);
        rt.builder.SetInsertPoint(row);
        // %y = phi i64 [ 1, %entry ], [ %nextY, %nextRow ]
        PHINode *y = rt.builder.CreatePHI(rt.i64Ty, 2, "y");
        y->addIncoming(rt.i64(1), entry);
        Value *rowOffset = rt.builder.CreateMul(y, rt.i64(384), "", true, true);
        rt.builder.CreateBr(column);

        rt.builder.SetInsertPoint(column);
        // %x = phi i64 [ 1, %row ], [ %nextX, %nextColumn ]
        PHINode *x = rt.builder.CreatePHI(rt.i64Ty, 2, "x");
        x->addIncoming(rt.i64(1), row);
        Value *index = rt.builder.CreateAdd(x, rowOffset);
        Value *mapCell = rt.builder.CreateLoad(
            rt.i32Ty, rt.builder.CreateGEP(rt.i32Ty, map, index));
        Value *blocked = rt.builder.CreateICmpEQ(mapCell, rt.i32(1));
        rt.builder.CreateCondBr(blocked, nextColumn, update);

        rt.builder.SetInsertPoint(update);
        Value *cell = rt.builder.CreateGEP(rt.i32Ty, current, index);
        Value *sum = rt.builder.CreateAdd(
            rt.builder.CreateLoad(rt.i32Ty,
                                  rt.builder.CreateGEP(rt.i32Ty, cell, rt.i64(-384))),
            rt.builder.CreateLoad(rt.i32Ty,
                                  rt.builder.CreateGEP(rt.i32Ty, cell, rt.i64(384))));
        sum = rt.builder.CreateAdd(
            sum, rt.builder.CreateLoad(rt.i32Ty,
                                       rt.builder.CreateGEP(rt.i32Ty, cell, rt.i64(-1))));
        sum = rt.builder.CreateAdd(
            sum, rt.builder.CreateLoad(rt.i32Ty,
                                       rt.builder.CreateGEP(rt.i32Ty, cell, rt.i64(1))));
        Value *average = rt.builder.CreateSDiv(sum, rt.i32(2));
        // %average = sdiv i32 %sum, 2
        Value *oldNext = rt.builder.CreateLoad(rt.i32Ty,
                                               rt.builder.CreateGEP(rt.i32Ty, next, index));
        Value *difference = rt.builder.CreateSub(average, oldNext);
        Value *damping = rt.builder.CreateAShr(difference, rt.i32(7));
        // %difference/%damping
        rt.builder.CreateStore(rt.builder.CreateSub(difference, damping),
                               rt.builder.CreateGEP(rt.i32Ty, next, index));
        rt.builder.CreateBr(nextColumn);

        rt.builder.SetInsertPoint(nextColumn);
        // %nextX = add nuw nsw i64 %x, 1;
        Value *nextX = rt.builder.CreateAdd(x, rt.i64(1), "", true, true);
        Value *lastX = rt.builder.CreateICmpEQ(nextX, rt.i64(383));
        rt.builder.CreateCondBr(lastX, nextRow, column);
        x->addIncoming(nextX, nextColumn);

        rt.builder.SetInsertPoint(nextRow);
        // %nextY = add nuw nsw i64 %y, 1; br to done or row
        Value *nextY = rt.builder.CreateAdd(y, rt.i64(1), "", true, true);
        Value *lastY = rt.builder.CreateICmpEQ(nextY, rt.i64(191));
        rt.builder.CreateCondBr(lastY, done, row);
        y->addIncoming(nextY, nextRow);

        rt.builder.SetInsertPoint(done);
        // ret void
        rt.builder.CreateRetVoid();
    }

    void buildDrawField(Runtime &rt, Function *function) {
        // define void @drawField(ptr %wave, ptr %map)
        auto args = function->arg_begin();
        Value *wave = &*args++;
        Value *map = &*args;
        BasicBlock *entry = BasicBlock::Create(rt.context, "entry", function);
        BasicBlock *row = BasicBlock::Create(rt.context, "row", function);
        BasicBlock *cell = BasicBlock::Create(rt.context, "cell", function);
        BasicBlock *obstacle = BasicBlock::Create(rt.context, "obstacle", function);
        BasicBlock *water = BasicBlock::Create(rt.context, "water", function);
        BasicBlock *nextCell = BasicBlock::Create(rt.context, "next_cell", function);
        BasicBlock *nextRow = BasicBlock::Create(rt.context, "next_row", function);
        BasicBlock *done = BasicBlock::Create(rt.context, "done", function);

        rt.builder.SetInsertPoint(entry);
        // br label %row
        rt.builder.CreateBr(row);
        rt.builder.SetInsertPoint(row);
        // %y = phi i64 [ 0, %entry ], [ %nextY, %nextRow ]
        PHINode *y = rt.builder.CreatePHI(rt.i64Ty, 2, "y");
        y->addIncoming(rt.i64(0), entry);
        Value *rowOffset = rt.builder.CreateMul(y, rt.i64(384), "", true, true);
        Value *y32 = rt.builder.CreateTrunc(y, rt.i32Ty);
        rt.builder.CreateBr(cell);

        rt.builder.SetInsertPoint(cell);
        // %x = phi i64 [ 0, %row ], [ %nextX, %nextCell ]
        PHINode *x = rt.builder.CreatePHI(rt.i64Ty, 2, "x");
        x->addIncoming(rt.i64(0), row);
        Value *index = rt.builder.CreateAdd(x, rowOffset);
        Value *mapValue = rt.builder.CreateLoad(
            rt.i32Ty, rt.builder.CreateGEP(rt.i32Ty, map, index));
        Value *isWall = rt.builder.CreateICmpEQ(mapValue, rt.i32(1));
        rt.builder.CreateCondBr(isWall, obstacle, water);

        rt.builder.SetInsertPoint(obstacle);
        // call void @drawCell(i32 %x, i32 %y, i32 -8355712)
        rt.builder.CreateCall(rt.module.getFunction("drawCell"),
                              {
                                  rt.builder.CreateTrunc(x, rt.i32Ty), y32,
                                  rt.i32(-8355712)
                              });
        rt.builder.CreateBr(nextCell);

        rt.builder.SetInsertPoint(water);
        Value *waveValue = rt.builder.CreateLoad(
            rt.i32Ty, rt.builder.CreateGEP(rt.i32Ty, wave, index));
        Value *negative = rt.builder.CreateICmpSLT(waveValue, rt.i32(0));
        Value *positive = rt.builder.CreateICmpSGT(waveValue, rt.i32(0));
        Value *red = rt.builder.CreateCall(rt.signedMin,
                                           {
                                               rt.builder.CreateSub(rt.i32(0), waveValue),
                                               rt.i32(255)
                                           });
        Value *green = rt.builder.CreateCall(
            rt.signedMin, {rt.builder.CreateAShr(waveValue, rt.i32(2)), rt.i32(255)});
        Value *blue = rt.builder.CreateCall(
            rt.unsignedMin,
            {
                rt.builder.CreateLShr(rt.builder.CreateMul(waveValue, waveValue),
                                      rt.i32(5)),
                rt.i32(255)
            });
        Value *redPart = rt.builder.CreateShl(red, rt.i32(16));
        Value *greenPart = rt.builder.CreateShl(green, rt.i32(8));
        Value *positiveBlue = rt.builder.CreateSelect(positive, blue, rt.i32(0));
        Value *negativeBase =
                rt.builder.CreateOr(redPart, rt.i32(-16777216));
        Value *base = rt.builder.CreateSelect(negative, negativeBase,
                                              rt.i32(-16777216));
        Value *color = rt.builder.CreateOr(
            rt.builder.CreateOr(base, rt.builder.CreateSelect(positive, greenPart,
                                                              rt.i32(0))),
            positiveBlue);
        rt.builder.CreateCall(rt.module.getFunction("drawCell"),
                              {rt.builder.CreateTrunc(x, rt.i32Ty), y32, color});
        rt.builder.CreateBr(nextCell);

        rt.builder.SetInsertPoint(nextCell);
        // %nextX = add nuw nsw i64 %x, 1
        Value *nextX = rt.builder.CreateAdd(x, rt.i64(1), "", true, true);
        Value *lastX = rt.builder.CreateICmpEQ(nextX, rt.i64(384));
        rt.builder.CreateCondBr(lastX, nextRow, cell);
        x->addIncoming(nextX, nextCell);

        rt.builder.SetInsertPoint(nextRow);
        // %nextY = add nuw nsw i64 %y, 1
        Value *nextY = rt.builder.CreateAdd(y, rt.i64(1), "", true, true);
        Value *lastY = rt.builder.CreateICmpEQ(nextY, rt.i64(192));
        rt.builder.CreateCondBr(lastY, done, row);
        y->addIncoming(nextY, nextRow);

        rt.builder.SetInsertPoint(done);
        // ret void
        rt.builder.CreateRetVoid();
    }

    void buildAddSplash(Runtime &rt, Function *function) {
        // define void @addSplash(ptr %wave, ptr %map, i32 %click)
        auto args = function->arg_begin();
        Value *wave = &*args++;
        Value *map = &*args++;
        Value *click = &*args;

        BasicBlock *entry = BasicBlock::Create(rt.context, "entry", function);
        BasicBlock *row = BasicBlock::Create(rt.context, "row", function);
        BasicBlock *cell = BasicBlock::Create(rt.context, "cell", function);
        BasicBlock *write = BasicBlock::Create(rt.context, "write", function);
        BasicBlock *nextCell = BasicBlock::Create(rt.context, "next_cell", function);
        BasicBlock *nextRow = BasicBlock::Create(rt.context, "next_row", function);
        BasicBlock *done = BasicBlock::Create(rt.context, "done", function);

        rt.builder.SetInsertPoint(entry);
        // %centerX = sdiv i32 (lshr i32 %click, 16), 4
        Value *centerX = rt.builder.CreateSDiv(
            rt.builder.CreateLShr(click, rt.i32(16)), rt.i32(4));
        // %centerY = sdiv i32 (and i32 %click, 65535), 4
        Value *centerY = rt.builder.CreateSDiv(
            rt.builder.CreateAnd(click, rt.i32(65535)), rt.i32(4));
        rt.builder.CreateBr(row);
        rt.builder.SetInsertPoint(row);
        // %dy = phi i32 [ -1, %entry ], [ %nextDy, %nextRow ]
        PHINode *dy = rt.builder.CreatePHI(rt.i32Ty, 2, "dy");
        dy->addIncoming(rt.i32(-1), entry);
        Value *y = rt.builder.CreateAdd(dy, centerY);
        Value *validY = rt.builder.CreateAnd(
            rt.builder.CreateICmpSGT(y, rt.i32(0)),
            rt.builder.CreateICmpSLT(y, rt.i32(191)));
        Value *rowOffset = rt.builder.CreateMul(y, rt.i32(384), "", true, true);
        rt.builder.CreateBr(cell);

        rt.builder.SetInsertPoint(cell);
        // %dx = phi i32 [ -1, %row ], [ %nextDx, %nextCell ]
        PHINode *dx = rt.builder.CreatePHI(rt.i32Ty, 2, "dx");
        dx->addIncoming(rt.i32(-1), row);
        // %x = add i32 %dx, %centerX
        Value *x = rt.builder.CreateAdd(dx, centerX);
        Value *leftOfInterior = rt.builder.CreateICmpULT(
            rt.builder.CreateAdd(x, rt.i32(-1)), rt.i32(382));
        Value *valid = rt.builder.CreateAnd(
            rt.builder.CreateAnd(leftOfInterior, validY), rt.builder.CreateICmpSGT(x, rt.i32(0)));
        rt.builder.CreateCondBr(valid, write, nextCell);

        rt.builder.SetInsertPoint(write);
        // %index = zext (add nuw nsw i32 %x, %rowOffset) to i64
        Value *index = rt.builder.CreateZExt(
            rt.builder.CreateAdd(x, rowOffset, "", true, true), rt.i64Ty);
        Value *mapValue = rt.builder.CreateLoad(rt.i32Ty,
                                                rt.builder.CreateGEP(rt.i32Ty, map, index));
        Value *blocked = rt.builder.CreateICmpEQ(mapValue, rt.i32(1));
        rt.builder.CreateCondBr(blocked, nextCell, write);

        BasicBlock *store = BasicBlock::Create(rt.context, "store", function);
        write->getTerminator()->eraseFromParent();
        rt.builder.SetInsertPoint(write);
        rt.builder.CreateCondBr(blocked, nextCell, store);
        rt.builder.SetInsertPoint(store);
        // store i32 1500, ptr (getelementptr i32, ptr %wave, i64 %index)
        rt.builder.CreateStore(rt.i32(1500),
                               rt.builder.CreateGEP(rt.i32Ty, wave, index));
        rt.builder.CreateBr(nextCell);

        rt.builder.SetInsertPoint(nextCell);
        Value *nextDx = rt.builder.CreateAdd(dx, rt.i32(1));
        rt.builder.CreateCondBr(rt.builder.CreateICmpEQ(nextDx, rt.i32(2)),
                                nextRow, cell);
        dx->addIncoming(nextDx, nextCell);

        rt.builder.SetInsertPoint(nextRow);
        Value *nextDy = rt.builder.CreateAdd(dy, rt.i32(1));
        rt.builder.CreateCondBr(rt.builder.CreateICmpEQ(nextDy, rt.i32(2)),
                                done, row);
        dy->addIncoming(nextDy, nextRow);

        rt.builder.SetInsertPoint(done);
        // ret void
        rt.builder.CreateRetVoid();
    }

    void buildApp(Runtime &rt, Function *function) {
        // define void @app()
        ArrayType *bufferTy = ArrayType::get(rt.i32Ty, 73728);
        BasicBlock *entry = BasicBlock::Create(rt.context, "entry", function);
        BasicBlock *loop = BasicBlock::Create(rt.context, "loop", function);
        BasicBlock *clicks = BasicBlock::Create(rt.context, "clicks", function);
        BasicBlock *random = BasicBlock::Create(rt.context, "random", function);
        BasicBlock *splash = BasicBlock::Create(rt.context, "splash", function);
        BasicBlock *continueLoop =
                BasicBlock::Create(rt.context, "continue", function);

        rt.builder.SetInsertPoint(entry);
        // %1/%2/%3 = alloca [73728 x i32]
        Value *map = rt.builder.CreateAlloca(bufferTy, nullptr, "map");
        Value *first = rt.builder.CreateAlloca(bufferTy, nullptr, "first");
        Value *second = rt.builder.CreateAlloca(bufferTy, nullptr, "second");
        Value *mapPtr = rt.builder.CreateInBoundsGEP(bufferTy, map,
                                                     {rt.i32(0), rt.i32(0)});
        Value *firstPtr = rt.builder.CreateInBoundsGEP(bufferTy, first,
                                                       {rt.i32(0), rt.i32(0)});
        Value *secondPtr = rt.builder.CreateInBoundsGEP(bufferTy, second,
                                                        {rt.i32(0), rt.i32(0)});
        rt.builder.CreateMemSet(firstPtr, rt.builder.getInt8(0),
                                73728 * sizeof(int), MaybeAlign(16));
        rt.builder.CreateMemSet(secondPtr, rt.builder.getInt8(0),
                                73728 * sizeof(int), MaybeAlign(16));
        rt.builder.CreateMemSet(mapPtr, rt.builder.getInt8(0),
                                73728 * sizeof(int), MaybeAlign(16));
        // call void @createMap(ptr %mapPtr)
        rt.builder.CreateCall(rt.module.getFunction("createMap"), {mapPtr});
        rt.builder.CreateBr(loop);

        rt.builder.SetInsertPoint(loop);
        // %current/%next = phi ptr [ %second/%first, %entry ], [ %next/%current, %continue ]
        PHINode *current = rt.builder.CreatePHI(rt.i32PtrTy, 2, "current");
        PHINode *next = rt.builder.CreatePHI(rt.i32PtrTy, 2, "next");
        current->addIncoming(secondPtr, entry);
        next->addIncoming(firstPtr, entry);
        rt.builder.CreateCall(rt.module.getFunction("drawField"), {current, mapPtr});
        rt.builder.CreateCall(rt.flush);
        rt.builder.CreateCall(rt.module.getFunction("calcWave"),
                              {current, next, mapPtr});
        Value *hasInput = rt.builder.CreateICmpNE(
            rt.builder.CreateCall(rt.hasClick), rt.i32(0));
        // %hasInput = icmp ne i32 (call i32 @simHasClick()), 0
        rt.builder.CreateCondBr(hasInput, clicks, random);

        rt.builder.SetInsertPoint(clicks);
        // %click = call i32 @simGetClick(); call @addSplash(...)
        Value *click = rt.builder.CreateCall(rt.getClick);
        rt.builder.CreateCall(rt.module.getFunction("addSplash"),
                              {next, mapPtr, click});
        Value *moreClicks = rt.builder.CreateICmpNE(
            rt.builder.CreateCall(rt.hasClick), rt.i32(0));
        rt.builder.CreateCondBr(moreClicks, clicks, random);

        rt.builder.SetInsertPoint(random);
        // %randomValue = srem i32 (call i32 @simRand()), 100
        Value *randomValue = rt.builder.CreateSRem(rt.builder.CreateCall(rt.rand),
                                                   rt.i32(100));
        rt.builder.CreateCondBr(rt.builder.CreateICmpEQ(randomValue, rt.i32(0)),
                                splash, continueLoop);

        rt.builder.SetInsertPoint(splash);
        Value *randomX = rt.builder.CreateShl(
            rt.builder.CreateSRem(rt.builder.CreateCall(rt.rand), rt.i32(1536)),
            rt.i32(16));
        Value *randomY = rt.builder.CreateSRem(rt.builder.CreateCall(rt.rand),
                                               rt.i32(768));
        rt.builder.CreateCall(rt.module.getFunction("addSplash"),
                              {next, mapPtr, rt.builder.CreateOr(randomX, randomY)});
        rt.builder.CreateBr(continueLoop);

        rt.builder.SetInsertPoint(continueLoop);
        rt.builder.CreateBr(loop);
        current->addIncoming(next, continueLoop);
        next->addIncoming(current, continueLoop);
    }
}

int main() {
    LLVMContext context;
    auto module = std::make_unique<Module>("app.c", context);
    Runtime rt(context, *module);

    Function *drawCell =
            createFunction(rt, "drawCell", {rt.i32Ty, rt.i32Ty, rt.i32Ty});
    Function *createMap = createFunction(rt, "createMap", {rt.i32PtrTy});
    Function *calcWave =
            createFunction(rt, "calcWave", {rt.i32PtrTy, rt.i32PtrTy, rt.i32PtrTy});
    Function *drawField =
            createFunction(rt, "drawField", {rt.i32PtrTy, rt.i32PtrTy});
    Function *addSplash =
            createFunction(rt, "addSplash", {rt.i32PtrTy, rt.i32PtrTy, rt.i32Ty});
    Function *app = createFunction(rt, "app", {});

    buildDrawCell(rt, drawCell);
    buildCreateMap(rt, createMap);
    buildCalcWave(rt, calcWave);
    buildDrawField(rt, drawField);
    buildAddSplash(rt, addSplash);
    buildApp(rt, app);

    module->print(outs(), nullptr);
    bool failed = verifyModule(*module, &outs());
#if EMULATE
    outs() << "[VERIFICATION] " << (failed ? "FAIL\n" : "OK\n");

    outs() << "[EE] Run\n";
    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();

    ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(std::move(module))).create();
    ee->InstallLazyFunctionCreator([](const std::string &fnName) -> void * {
        if (fnName == "simPutPixel") {
            return reinterpret_cast<void *>(simPutPixel);
        }
        if (fnName == "simFlush") {
            return reinterpret_cast<void *>(simFlush);
        }
        if (fnName == "simGetClick") {
            return reinterpret_cast<void *>(simGetClick);
        }
        if (fnName == "simHasClick") {
            return reinterpret_cast<void *>(simHasClick);
        }
        if (fnName == "simRand") {
            return reinterpret_cast<void *>(simRand);
        }
        if (fnName == "memset") {
            return reinterpret_cast<void *>(std::memset);
        }
        outs() << "[ExecutionEngine] Can't find function " << fnName
                << ". Catch the Segmentation fault:)\n";
        return nullptr;
    });
    ee->finalizeObject();

    simInit();

    ArrayRef<GenericValue> noargs;
    GenericValue v = ee->runFunction(app, noargs);
    outs() << "[EE] Result: " << v.IntVal << '\n';

    simExit();
#endif

    return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}

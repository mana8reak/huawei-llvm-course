#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include "llvm/IR/Verifier.h"
#include <unordered_set>

using namespace llvm;

struct UserOperandInstrumentationPass : public PassInfoMixin<UserOperandInstrumentationPass> {
    bool isLoggerFunc(StringRef name) {
        return name == "logUserOperand" || name == "registerOpcodeName";
    }

    void resolvePhi(PHINode *phi, std::unordered_set<Instruction*> &incoming, std::unordered_set<PHINode*> &resolved) {
        if (resolved.find(phi) != resolved.end()) {
            return;
        }
        resolved.insert(phi);
        
        for (Value *v : phi->incoming_values()) {
            if (auto *incPhi = dyn_cast<PHINode>(v)) {
                resolvePhi(incPhi, incoming, resolved);
            } else if (auto *incI = dyn_cast<Instruction>(v)) {
                incoming.insert(incI);
            }
        }
    }

    PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM) {
        LLVMContext &Ctx = M.getContext();
        IRBuilder<> builder(Ctx);

        auto voidType = Type::getVoidTy(Ctx);
        auto int16Ty = Type::getInt16Ty(Ctx);
        auto int8PtrTy = Type::getInt8Ty(Ctx)->getPointerTo();

        FunctionCallee logFunc = M.getOrInsertFunction(
            "logUserOperand",
            FunctionType::get(voidType, {int16Ty, int16Ty}, false)
        );
        FunctionCallee regFunc = M.getOrInsertFunction(
            "registerOpcodeName",
            FunctionType::get(voidType, {int16Ty, int8PtrTy}, false)
        );

        std::size_t insertions = 0;
        std::unordered_map<unsigned, std::string> instrNames;

        for (Function &F: M) {
            if (F.isDeclaration() || isLoggerFunc(F.getName())) continue;

            for (auto &BB: F) {
                for (auto &I: BB) {
                    unsigned op_id = I.getOpcode();
                    instrNames.try_emplace(op_id, I.getOpcodeName());

                    for (auto &U: I.uses()) {
                        if (isa<PHINode>(U.getUser())) continue;

                        if (auto *UI = dyn_cast<Instruction>(U.getUser())) {
                            if (auto *call = dyn_cast<CallInst>(UI)) {
                                if (isLoggerFunc(call->getCalledFunction()->getName())) continue;
                            }

                            auto userOpId = UI->getOpcode();
                            builder.SetInsertPoint(UI);
                            Value *userOpVal = builder.getInt16(userOpId);

                            if (auto *phi = dyn_cast<PHINode>(&I)) {
                                std::unordered_set<Instruction*> incoming;
                                std::unordered_set<PHINode*> resolved;
                                resolvePhi(phi, incoming, resolved);
                                for (auto *incI: incoming) {
                                    Value *operandOpVal = builder.getInt16(incI->getOpcode());
                                    builder.CreateCall(logFunc, {userOpVal, operandOpVal});
                                    insertions++;
                                }
                                continue;
                            }

                            Value *operandOpVal = builder.getInt16(op_id);
                            builder.CreateCall(logFunc, {userOpVal, operandOpVal});
                            insertions++;
                        }
                    }
                }
            }
        }

        Function *registerOpcodes = Function::Create(
            FunctionType::get(Type::getVoidTy(Ctx), false),
            GlobalValue::InternalLinkage, "__reg_opcodes", M
        );
        BasicBlock *bb = BasicBlock::Create(Ctx, "", registerOpcodes);
        builder.SetInsertPoint(bb);
        for (auto &[id, name]: instrNames) {
            builder.CreateCall(regFunc, {builder.getInt16(id), builder.CreateGlobalStringPtr(name)});
        }
        builder.CreateRetVoid();
        appendToGlobalCtors(M, registerOpcodes, 0);

        bool verif = verifyModule(M);
        outs() << "[Verification] " << (verif ? "FAIL\n\n" : "OK\n\n");
        outs() << "[Instrumentation] Inserted " << insertions << " logging calls.\n";
        return PreservedAnalyses::none();
    }
};

PassPluginLibraryInfo getPassPluginInfo() {
    const auto callback = [](PassBuilder &PB) {
        PB.registerOptimizerLastEPCallback([](ModulePassManager &MPM, auto) {
            MPM.addPass(UserOperandInstrumentationPass{});
            return true;
        });
    };
    return {LLVM_PLUGIN_API_VERSION, "UserOperandInstrumentation", "0.0.1", callback};
};

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
    return getPassPluginInfo();
}

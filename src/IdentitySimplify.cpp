
#include "llvm/ADT/Statistic.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Plugins/PassPlugin.h"

#define DEBUG_TYPE "optforge-simplify"

using namespace llvm;

STATISTIC(NumIdentitiesRemoved,
          "Number of algebraic identities removed");

namespace {

// Check whether an LLVM value is a constant integer zero.
bool isZero(const Value *V) {
    const auto *C = dyn_cast<ConstantInt>(V);
    return C && C->isZero();
}

// Check whether an LLVM value is a constant integer one.
bool isOne(const Value *V) {
    const auto *C = dyn_cast<ConstantInt>(V);
    return C && C->isOne();
}

// True when every bit is one, e.g. -1 for signed integers.
bool isAllOnes(const Value *V) {
    const auto *C = dyn_cast<ConstantInt>(V);
    return C && C->getValue().isAllOnes();
}

// Return the operand that can replace a redundant instruction.
// nullptr means no supported optimization applies.
Value *findReplacement(BinaryOperator &I) {
    Value *L = I.getOperand(0);
    Value *R = I.getOperand(1);

    switch (I.getOpcode()) {
        case Instruction::Add:
            // 0 + x = x, x + 0 = x
            if (isZero(L)) return R;
            if (isZero(R)) return L;
            break;

        case Instruction::Sub:
            // x - 0 = x
            if (isZero(R)) return L;
            break;

        case Instruction::Mul:
            // 1 * x = x, x * 1 = x
            if (isOne(L)) return R;
            if (isOne(R)) return L;
            break;

        case Instruction::And:
            // x & -1 = x
            if (isAllOnes(L)) return R;
            if (isAllOnes(R)) return L;
            break;

        case Instruction::Or:
        case Instruction::Xor:
            // x | 0 = x, x ^ 0 = x
            if (isZero(L)) return R;
            if (isZero(R)) return L;
            break;

        case Instruction::Shl:
        case Instruction::LShr:
        case Instruction::AShr:
            // Shifting by zero does nothing.
            if (isZero(R)) return L;
            break;

        case Instruction::UDiv:
        case Instruction::SDiv:
            // x / 1 = x
            if (isOne(R)) return L;
            break;

        default:
            break;
    }

    return nullptr;
}

class IdentitySimplifyPass
    : public PassInfoMixin<IdentitySimplifyPass> {

public:
    PreservedAnalyses run(Function &F,
                          FunctionAnalysisManager &) {

        bool Changed = false;

        // Visit each basic block in the current function.
        for (BasicBlock &BB : F) {

            // Advance the iterator before potentially erasing.
            for (auto It = BB.begin(); It != BB.end();) {
                Instruction &I = *It++;

                auto *Binary = dyn_cast<BinaryOperator>(&I);
                if (!Binary)
                    continue;

                Value *Replacement = findReplacement(*Binary);
                if (!Replacement)
                    continue;

                // Update every SSA use of this instruction.
                I.replaceAllUsesWith(Replacement);

                // The old instruction is now redundant.
                I.eraseFromParent();

                ++NumIdentitiesRemoved;
                Changed = true;
            }
        }

        return Changed
            ? PreservedAnalyses::none()
            : PreservedAnalyses::all();
    }
};

} // namespace

// Entry point used by LLVM to discover this plugin.
extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo
llvmGetPassPluginInfo() {

    return {
        LLVM_PLUGIN_API_VERSION,
        "OptForgePass",
        LLVM_VERSION_STRING,

        [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name,
                   FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {

                    if (Name != "optforge-simplify")
                        return false;

                    FPM.addPass(IdentitySimplifyPass());
                    return true;
                }
            );
        }
    };
}


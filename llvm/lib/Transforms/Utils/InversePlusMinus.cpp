#include "llvm/Transforms/Utils/InversePlusMinus.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"

namespace llvm {
PreservedAnalyses InversePlusMinusPass::run(Function &F,
                                            FunctionAnalysisManager &AM) {
  for (auto &&BB : F) {
    for (auto &&instr : BB) {
      if (auto binary = dyn_cast<BinaryOperator>(&instr)) {
        bool isAddition = false;

        switch (binary->getOpcode()) {
        case BinaryOperator::BinaryOps::Add: {
          isAddition = true;
          [[fallthrough]];
        }
        case BinaryOperator::BinaryOps::Sub: {
          auto newOpcode = isAddition ? BinaryOperator::BinaryOps::Sub
                                      : BinaryOperator::BinaryOps::Add;
          auto newBinary = BinaryOperator::Create(newOpcode, binary->getOperand(0),
                                                  binary->getOperand(1), binary->getName());
          newBinary->copyMetadata(*binary);
          ReplaceInstWithInst(binary, newBinary);
          break;
        }
        default:
          break;
        }
      }
    }
  }

  return PreservedAnalyses::none();
}
} // namespace llvm
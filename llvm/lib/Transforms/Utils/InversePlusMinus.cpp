#include "llvm/Transforms/Utils/InversePlusMinus.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"

namespace llvm
{
  PreservedAnalyses InversePlusMinusPass::run(Function &F,
                                              FunctionAnalysisManager &AM)
  {
    if (F.getName() != "replace") { return PreservedAnalyses::all(); }

    std::vector<BinaryOperator *> instructions;

    for (auto &&BB : F)
    {
      for (auto &&instr : BB)
      {
        if (auto binary = dyn_cast<BinaryOperator>(&instr))
        {
          switch (binary->getOpcode())
          {
          case BinaryOperator::BinaryOps::Add: [[fallthrough]];
          case BinaryOperator::BinaryOps::Sub: instructions.push_back(binary); break;
          default:
            break;
          }
        }
      }
    }

    if (instructions.empty()) { return PreservedAnalyses::all(); }

    for (auto instrPtr : instructions)
    {
      if (instrPtr == nullptr) [[unlikely]] { assert(false); continue; }

      auto newOpcode = (instrPtr->getOpcode() == BinaryOperator::BinaryOps::Add)
                     ? BinaryOperator::BinaryOps::Sub
                     : BinaryOperator::BinaryOps::Add;

      auto newBinary = BinaryOperator::Create(newOpcode,
                                              instrPtr->getOperand(0),
                                              instrPtr->getOperand(1));
      newBinary->copyMetadata(*instrPtr);
      ReplaceInstWithInst(instrPtr, newBinary);
    }

    return PreservedAnalyses::none();
  }
} // namespace llvm
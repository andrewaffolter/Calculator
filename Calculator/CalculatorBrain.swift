//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Andrew Affolter on 3/11/15.
//  Copyright (c) 2015 Affolter, Andrew. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    //not inheritance, this :Printable is a protocol to tell Swift that this enum implements this Protocol
    private enum Op: Printable{
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    
        //only computed properties in enums and only read-only
    var description: String{
        get{
            switch  self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                    return symbol
            case .BinaryOperation(let symbol, _):
                    return symbol
            }
        }
    }
}
    
    //special syntax for array
    private var opStack = [Op]()
    
    //special syntax for dictonary
    private var knownOps = [String:Op]()
    
    //public
    init(){
        //i can put functions inside init
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷"){$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−"){$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)

    }
    
    //ops is passed by value so it is is read-only as it's an enum which is pass by value not pass by refrence
    //recursion
    //this function returns a tuple
   private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            //we need to store the value of ops into a local variable because ops is read-only
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaulation = evaluate(remainingOps)
                if let operand = operandEvaulation.result{
                    return (operation(operand), operandEvaulation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaulation = evaluate(remainingOps)
                if let operand1 = op1Evaulation.result{
                    let op2Evaluation = evaluate(op1Evaulation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                //no need for default case as we have handled all the possible type of ops the enum
            }
        }
        return(nil,ops)
    }
    
    //this needs to be an optional because in case i dont have any operands and somebody wants to do an operation
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    //public
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    //public
    func performOperation(symbol:String) -> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
}
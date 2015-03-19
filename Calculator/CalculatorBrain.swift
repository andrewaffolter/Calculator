//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Andrew Affolter on 3/11/15.
//  Copyright (c) 2015 Affolter, Andrew. All rights reserved.
//

//Foundation is the core services layer, no UI stuff in it. So we are not importing UIKit into a model class, nor would we ever want to.
import Foundation

class CalculatorBrain
{
    private enum Op: Printable{
        
        case Variable(String)
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    
        var description: String{
            get{
                switch  self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                        return symbol
                case .BinaryOperation(let symbol, _):
                        return symbol
                case .Variable(let symbol):
                    return symbol
                    }
                }
            }
        }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = Dictionary<String, Double>()
    
    var description:String?
        {
        get{
            if let (result, _) = evaulateDescription(opStack){
                return result!
            }
            return nil
        }
    }
    
    init(){
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷"){$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−"){$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    private func evaulateDescription(ops: [Op]) -> (description:String?, remainingOps: [Op])?{
        if !ops.isEmpty{
            var description = ""
            let comma:Character = ","
            
            var remainingOps = ops
            
            let op = remainingOps.removeLast()
            
            switch op{
            case .Operand(let operand):
                return(nil,ops)
        
            case .Variable(let variable):
                return(nil,ops)
            
            case .UnaryOperation(_, let operation):
                return(nil,ops)
            
            case .BinaryOperation(_, let operation):
                return(nil,ops)
            
            }
        }
        return(nil,ops)
    }
    
   private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {

            var remainingOps = ops
            
            let op = remainingOps.removeLast()
            
            switch op{
            
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .Variable(let variable):
                if let variableValue = variableValues[variable] {
                    return (variableValue, remainingOps)
                }
    
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
            }
        }
        return(nil,ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }

    func performOperation(symbol:String) -> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOpStack(){
        opStack.removeAll(keepCapacity: true)
    }
    
    func clearVarStack(){
        variableValues.removeAll(keepCapacity: true)
    }
    
    func clearAll(){
        clearOpStack()
        clearVarStack()
    }
}
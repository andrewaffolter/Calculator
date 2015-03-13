//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Andrew Affolter on 3/11/15.
//  Copyright (c) 2015 Affolter, Andrew. All rights reserved.
//

//Foundation is the core services layer, no UI stuff in it. So we are not importing UIKit into a model class, nor would we ever want to.
import Foundation

//doesn't inherit from any other objects. Some models may inherit from NSObject. This one is just a base Swift class.
class CalculatorBrain
{
  
    //No inheritance for enums, this :Printable is a protocol to tell Swift that this enum implements this Protocol. Enums are for  basic types and are great when you something that is one thing one time and a different thng a different time and never both at the same time. Enums can also have functions.
    //Op is our data structure that can be either an operand or an operation, but never both
    private enum Op: Printable{
        //The values defined in an enumeration (such as Operand, UnaryOperation, and BinaryOperation) are the member values (or members) of that enumeration. The case keyword indicates that a new line of member values is about to be defined.
        //Swift allows us to associate data of a specific type
        case Operand(Double)
        //single value operation like square root, string will hold the symbol, and the second parameter will hold the function so in this case it's a function that accepts a single double value and returns a double
        case UnaryOperation(String, Double -> Double)
        //binary value operation like multiplication, string will hold the symbol, and the second parameter will hold the function so in this case it's a function that accepts two double values and returns a double
        case BinaryOperation(String, (Double, Double) -> Double)
    
        //Enums can only have computed properties and only read-only. It has to be called description and it has to be String since it's a String description of it.
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
    
    //Preferred syntax for array used here, this is an alternate syntax just a different way of typing it in. Previously we did var operandStack = Array<Double>(). This array stores but operations (symbols) and operands (digits). This is our data structure, but we don't want an arry of Doubles like we did before since we are going to be storing both operands and operations in a single data structure. We really want a new Type, in this case a type of Op which can be either an operation or an operand.For that Type we will use an Enum. Op could have been a class with property for operand and operator and a function that does it. But it's weird to have a class where some times some things are set if other things are not set. What we really want is an Enum. In pushOperand we add digits to this array, in performOperation we add symbols to this array.
    private var opStack = [Op]()
    
    //Preferred syntax for dictonary. Normal syntax would be var knownOps = Dictonary<String, Op>()
    //This dictonary holds all of the known operations that can be done such as multiply, divide, addition, subtraction etc.
    private var knownOps = [String:Op]()
    
    //ublic because it's not private so it's public by default. This is part of our API. Anytime some says let brain = CalculatorBrain() it will call this init.
    init(){
        //i can put functions inside init
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        //We want to load up the known ops into our knownOps dictonary
        //Times "x" is a Binary Operation
        learnOp(Op.BinaryOperation("×", *))
        //We can put the closure on the outside since it's the last argument in the list of paremeters
        learnOp(Op.BinaryOperation("÷"){$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−"){$1 - $0})
        //These are unary operations
        //In the case here we can pass sqrt as a function
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    //ops is passed by value so it is is read-only as it's an enum which is pass by value not pass by refrence
    //This function uses recursion. So if the stack has a 6, then a 5, then +, then 4 and then *. Using recursion will take a stack of ops to evaulate and it will only look at the top item. So it will evalulate the * first, then the 4 and so on. If the function encounters an operand it will just return the result and the remainingOps, if it encounters an operation like +, * etc. then it needs to find all the operands for that operation.
    //This function can't use the big opStack, it has to use it's own copy because each time it recurses it's going to consume some of the stack.
    //This function returns a tuple which is a mini-data structure. You put them in parenthesis, but they don't need to be the same type.
    //This function has to be private because it is working with Op which is private.
   private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            //We need to store the value of ops into a local variable because ops is read-only because it is pass-by-value. Arrays and Dictonaries are not classes in Swift, they are Structs. Two biggest difference between classes and structs is that structs are passed by value and classes are passed by refrence and classes can have inheritance. There is an inherit 'let' in front of things that you pass so you can't mutate it (i.e. .removeLast()) which is a mutating function.
            var remainingOps = ops
            //This recursive function takes the last Op off the stack of Ops and then uses a switch statement to evaluate it.
            let op = remainingOps.removeLast()
            
            //Switch on the op and look at all the cases, case Op.Operand, Op.UnaryOperation and Op.BinaryOperation.
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps)
                
            //Using the underbar _ is the universal way to say I don't care about this value.
            case .UnaryOperation(_, let operation):
                //Now we will recurse by calling evaluate again.
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
        //this is the failure case in which case I will return a result of nil and I will return the ops. I can return nil becuase Double is an optional.
        return(nil,ops)
    }
    
    //This needs to be an optional because in case I dont have any operands and somebody wants to do an operation like + so the evaulate function can't do that. In that case we will return nil.
    func evaluate() -> Double? {
        //Here we are saying let a tuple equal the result of a function that returns a tuple so result = result and remainder = remainingOps. We are calling the recursive evaulation function here.
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    //public because it's not private so it's public by default. This is part of our API. pushOperand takes a single double value and returns an optional double in case you pass a value that can't be evaluated
    func pushOperand(operand: Double) -> Double? {
        //append the operand to the stack. Take the passed in operand which will be a digit like 7 and add it to the stack as type Enum Op.Operand
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    //public because it's not private so it's public by default. This is part of our API. Only use the word public if you are shipping out a framework and I want people to be able to use them outside my framework.
    //The argument here is the math symbol like x for multiply.
    func performOperation(symbol:String) -> Double?{
        //We were passed a symbol like X, + etc and we use subscript notatin to look it up in the list of knownOps
        //Whenever you look up something in a dictonary it always returns an optional which will be either the value from the key you used to look it up or nil if it can't find it.
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
}
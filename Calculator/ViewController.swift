//
//  ViewController.swift
//  Calculator
//
//  Created by Affolter, Andrew on 2/26/15.
//  Copyright (c) 2015 Affolter, Andrew. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    //this is an implicitly unwrapped optional
    @IBOutlet weak var display: UILabel!
 
    var userIsInTheMiddleOfTypingANumber  = false
    
    @IBAction func appendDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        
        switch digit{
        case "π": digit = "\(M_PI)"
        default:break
        }
        
        if !(display.text!.rangeOfString(".") != nil && digit == ".") {
            if userIsInTheMiddleOfTypingANumber {
                    display.text = display.text! + digit
                    historyStack.append(digit)
                    println("historyStack = \(historyStack)")
            }else{
                display.text = digit
                historyStack.append(digit)
                println("historyStack = \(historyStack)")
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        historyStack.append(operation)
        println("historyStack = \(historyStack)")
        if userIsInTheMiddleOfTypingANumber{
            enter()
        }
        //switches in Swift must be exhaustive so that is why we have the default case since we can't switch on every possible String. Switches in Swift also don't fallthrough by default.
        switch operation{
            //this is a closure
        case "×":performOperation{ $0 * $1 }
        case "÷":performOperation{ $1 / $0 }
        case "+":performOperation{ $0 + $1 }
        case "−":performOperation{ $1 - $0 }
        case "√":performOperation{ sqrt($0) }
        case "sin":performOperation{ sin($0) }
        case "cos":performOperation{ cos($0) }
        default: break
        }
        
    }
    
    func performOperation(operation: (Double, Double) -> Double)
    {
        if operandStack.count >= 2{
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    
    func performOperation(operation: Double -> Double)
    {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    //this is an array, we don't need to say Array<Double> on the left side because Swift supports type inference
    var operandStack = Array<Double>()
    
    var historyStack = Array<String>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        //println("operandStack = \(operandStack)")
    }
    
    @IBAction func clear() {
        display.text = "0"
        operandStack.removeAll(keepCapacity: false)
        historyStack.removeAll(keepCapacity: false)
        userIsInTheMiddleOfTypingANumber  = false
    }
    
    //this is a computed property. The getter gets the value from the display text and the setter sets it. Inside the get we are computing the display.text to convert it into a double.
    var displayValue:Double
        {
        get{
            //NSNumberFormatter().numberFromString is an objective-C function.
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            //newValue gets the value that will go into displayValue, we then use String Interpolation
            display.text =  "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
}


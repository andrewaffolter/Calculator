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
 
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber  = false
    
    //this is the controller using the model
    var brain = CalculatorBrain()
    
    var historyStack = Array<String>()
    
    @IBAction func appendDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        
        switch digit{
        case "π": digit = "\(M_PI)"
        default:break
        }
        
        if !(display.text!.rangeOfString(".") != nil && digit == ".") {
            if userIsInTheMiddleOfTypingANumber {
                    display.text = display.text! + digit
                    updateHistory(digit)
            }else{
                display.text = digit
                updateHistory(digit)
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        
        //updateHistory(operation)
        if userIsInTheMiddleOfTypingANumber{
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation){
                displayValue = result
            }else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        //Here we are calling the pushOperand public API method of the CalculatorBrain to add the current value of the display
        //We get the result and then up the display value with the result of the evaluation
        if let result = brain.pushOperand(displayValue!)
        {
            displayValue = result
        } else{
            displayValue = 0
        }
    }
    
    @IBAction func clear() {
        //need to make this work in assignment two
        display.text = "0"
        history.text = ""
        //operandStack.removeAll(keepCapacity: false)
        historyStack.removeAll(keepCapacity: false)
        userIsInTheMiddleOfTypingANumber  = false
    }
    
    @IBAction func backspace() {
        if countElements(display.text!) > 0{
            display.text = dropLast(display.text!)
        }else if countElements(display.text!) == 0
        {
            display.text = "0"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    func updateHistory(historyElement:String)
    {
        history.hidden = false
        historyStack.append(historyElement)
        if let last = historyStack.last {
             history.text! += last
        }
    }
    
    @IBAction func sign() {
        if displayValue!.isSignMinus
        {
            displayValue! = abs(displayValue!)
        }else if displayValue! > 0
        {
            displayValue! = -displayValue!
        }
        if !userIsInTheMiddleOfTypingANumber {
             enter()
        }
    }
    
    //this is a computed property. The getter gets the value from the display text and the setter sets it. Inside the get we are computing the display.text to convert it into a double.
    var displayValue:Double?
        {
        get{
            //NSNumberFormatter().numberFromString is an objective-C function.
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set{
            //newValue gets the value that will go into displayValue, we then use String Interpolation
            if let value = newValue {
                display.text = "\(value)"
            } else {
                display.text = nil
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}


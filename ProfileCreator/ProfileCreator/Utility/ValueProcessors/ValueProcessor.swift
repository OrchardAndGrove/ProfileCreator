//
//  ValueProcessor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class ValueProcessor {
    
    // MARK: -
    // MARK: Variables
    
    let inputType: PayloadValueType
    let outputType: PayloadValueType
    
    // MARK: -
    // MARK: Initialization
    
    init(inputType: PayloadValueType, outputType: PayloadValueType) {
        self.inputType = inputType
        self.outputType = outputType
    }
    
    // MARK: -
    // MARK: Main Functions
    
    func process(value: Any) -> Any? {
        
        // Verify Input Type
        if !(PayloadUtility.valueType(value: value, type: self.inputType) == self.inputType) { return nil }

        // Process Item
        switch self.inputType {
        case .string:
            if let string = value as? String { return self.process(string: string) }
        default:
            Swift.print("Unhandeled input type: \(self.inputType)")
        }
        
        return nil
    }
    
    // MARK: -
    // MARK: Value Functions
    
    // MARK: -
    // MARK: Value Functions: String
    
    func process(string: String) -> Any? {
        switch self.outputType {
        case .data:
            return self.data(fromString: string)
        default:
            Swift.print("Unhandeled output type: \(self.outputType)")
        }
        return nil
    }
    
    func data(fromString string: String) -> Data? {
        return string.data(using: .utf8, allowLossyConversion: false)
    }
}

//
//  ValueProcessors.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class ValueProcessors {
    
    // MARK: -
    // MARK: Variables
    
    public static let shared = ValueProcessors()
    
    private init() {}
    
    public func processor(withIdentifier identifier: String?, inputType: PayloadValueType, outputType: PayloadValueType) -> ValueProcessor {
        switch identifier ?? "" {
        case ValueProcessorIdentifier.hex2data:
            return ValueProcessorHex2Data(inputType: inputType, outputType: outputType)
        default:
            return ValueProcessor(inputType: inputType, outputType: outputType)
        }
    }
}

//
//  ValueProcessorStringHex2Data.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

class ValueProcessorHex2Data: ValueProcessor {

    // From: https://stackoverflow.com/a/26503955
    func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
    override func data(fromString string: String) -> Data? {
        return dataWithHexString(hex: string)
    }
}

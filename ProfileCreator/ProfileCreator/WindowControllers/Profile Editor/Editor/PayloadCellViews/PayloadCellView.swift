//
//  PayloadCellViewProtocol.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

protocol PayloadCellView {
    var height: CGFloat { get set }
    var row: Int { get set }
    
    var textFieldTitle: NSTextField? { get set }
    var textFieldDescription: NSTextField? { get set }
    var leadingKeyView: NSView? { get set }
    var trailingKeyView: NSView? { get set }
    
    init(key: String, settings: Dictionary<String , Any>)
    
    func updateHeight(_ h: CGFloat)
    func addSubview(_ subview: NSView)
}

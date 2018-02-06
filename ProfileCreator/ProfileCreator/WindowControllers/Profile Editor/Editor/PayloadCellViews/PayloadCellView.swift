//
//  PayloadCellViewProtocol.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

protocol ProfileCreatorCellView {
    var height: CGFloat { get set }
    func addSubview(_ subview: NSView)
}

protocol PayloadCellView: class {
    var row: Int { get set }
    
    weak var subkey: PayloadSourceSubkey? { get }
    weak var editor: ProfileEditor? { get }
    
    var textFieldTitle: NSTextField? { get set }
    var textFieldDescription: NSTextField? { get set }
    var leadingKeyView: NSView? { get set }
    var trailingKeyView: NSView? { get set }
    
    init(subkey: PayloadSourceSubkey, editor: ProfileEditor, settings: Dictionary<String , Any>)
    
    func updateHeight(_ h: CGFloat)
    func addSubview(_ subview: NSView)
    func enable(_ enable: Bool)
}

@objc protocol CheckboxCellView {
    func clicked(_ checkbox: NSButton)
}

@objc protocol PopUpButtonCellView {
    func selected(_ popUpButton: NSPopUpButton)
}

@objc protocol DatePickerCellView {
    func selectDate(_ datePicker: NSDatePicker)
}

@objc protocol TableViewCellView: class, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
}

//
//  PayloadCellViewDatePicker.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-14.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewDatePicker: NSTableCellView, ProfileCreatorCellView, PayloadCellView, DatePickerCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    weak var editor: ProfileEditor?
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    var isEnabled: Bool { return self.datePicker?.isEnabled ?? false }
    
    // MARK: -
    // MARK: Instance Variables
    
    var datePicker: NSDatePicker?
    var textFieldInterval: NSTextField?
    
    var valueDefault: Date?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, editor: ProfileEditor, settings: Dictionary<String, Any>) {
        
        self.subkey = subkey
        self.editor = editor
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()

        
        // ---------------------------------------------------------------------
        //  Get Indent
        // ---------------------------------------------------------------------
        let indent = subkey.parentSubkeys?.filter({$0.type == PayloadValueType.dictionary}).count ?? 0
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let textFieldTitle = EditorTextField.title(subkey: subkey, fontWeight: nil, indent: indent, leadingItem: nil, constraints: &constraints, cellView: self) {
            self.textFieldTitle = textFieldTitle
        }
        
        if let textFieldDescription = EditorTextField.description(subkey: subkey, indent: indent, constraints: &constraints, cellView: self) {
            self.textFieldDescription = textFieldDescription
        }
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.datePicker = EditorDatePicker.picker(offsetDays: 0, offsetHours: 0, offsetMinutes: 0, showDate: true, showTime: true, constraints: &constraints, cellView: self)
        self.setupDatePicker(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? Date {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if
            let domainSettings = settings[subkey.domain] as? Dictionary<String, Any>,
            let value = domainSettings[subkey.keyPath] as? Date {
            self.datePicker?.dateValue = value
        } else if let valueDefault = self.valueDefault {
            self.datePicker?.dateValue = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.datePicker
        self.trailingKeyView = self.datePicker
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(3.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    func enable(_ enable: Bool) {
        self.datePicker?.isEnabled = enable
    }
    
    // MARK: -
    // MARK: DatePicker Actions
    
    internal func selectDate(_ datePicker: NSDatePicker) {
        guard let subkey = self.subkey else { return }
        self.editor?.updatePayloadSettings(value: datePicker.dateValue , subkey: subkey)
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupDatePicker(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let datePicker = self.datePicker else { return }
        self.addSubview(datePicker)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        addConstraintsFor(item: datePicker, orientation: .below, constraints: &constraints, cellView: self)
        
        // Width
        constraints.append(NSLayoutConstraint(item: datePicker,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: datePicker.intrinsicContentSize.width))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: datePicker,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
}

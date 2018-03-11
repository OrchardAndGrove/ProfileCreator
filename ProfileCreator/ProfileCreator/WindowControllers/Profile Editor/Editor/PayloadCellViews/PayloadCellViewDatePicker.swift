//
//  PayloadCellViewDatePicker.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-14.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewDatePicker: PayloadCellView, ProfileCreatorCellView, DatePickerCellView {
    
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
        super.init(subkey: subkey, editor: editor, settings: settings)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.datePicker = EditorDatePicker.picker(offsetDays: 0, offsetHours: 0, offsetMinutes: 0, showDate: true, showTime: true, cellView: self)
        self.setupDatePicker()
        
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
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(self.cellViewConstraints)
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    override func enable(_ enable: Bool) {
        self.isEnabled = enable
        self.datePicker?.isEnabled = enable
    }
    
    // MARK: -
    // MARK: DatePicker Actions
    
    internal func selectDate(_ datePicker: NSDatePicker) {
        guard let subkey = self.subkey else { return }
        self.editor?.updatePayloadSettings(value: datePicker.dateValue , subkey: subkey)
    }
}

// MARK: -
// MARK: Setup NSLayoutConstraints
    
extension PayloadCellViewDatePicker {
    
    private func setupDatePicker() {
        
        // ---------------------------------------------------------------------
        //  Add DatePicker to TableCellView
        // ---------------------------------------------------------------------
        guard let datePicker = self.datePicker else { return }
        self.addSubview(datePicker)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        self.addConstraints(forViewBelow: datePicker)
        
        // Leading
        self.addConstraints(forViewLeading: datePicker)
        
        // Width
        self.cellViewConstraints.append(NSLayoutConstraint(item: datePicker,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1.0,
                                                           constant: datePicker.intrinsicContentSize.width))
    }
}

//
//  PayloadCellViewDatePicker.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-14.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadCellViewDatePicker: NSTableCellView, ProfileCreatorCellView, PayloadCellView, DatePickerCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var datePicker: NSDatePicker?
    var textFieldInterval: NSTextField?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(key: String, settings: Dictionary<String , Any>) {
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()

        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        self.textFieldTitle = EditorTextField.title(string: key, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self)
        self.textFieldDescription = EditorTextField.description(string: key + "DESCRIPTION", constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.datePicker = EditorDatePicker.picker(offsetDays: 0, offsetHours: 0, offsetMinutes: 0, showDate: true, showTime: true, constraints: &constraints, cellView: self)
        setupDatePicker(constraints: &constraints)
        
        // FIXME: This should be read from settigns
        
        
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
    
    // MARK: -
    // MARK: DatePicker Actions
    
    internal func selectDate(_ datePicker: NSDatePicker) {
        Swift.print("selectDate: \(datePicker)")
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupDatePicker(constraints: inout [NSLayoutConstraint]) {
        
        guard let datePicker = self.datePicker else {
            // TODO: Proper Logging
            return
        }
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(datePicker)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        addConstraintsFor(item: datePicker, orientation: .below, constraints: &constraints, cellView: self)
        self.updateHeight(datePicker.intrinsicContentSize.height)
        
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

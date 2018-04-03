//
//  PayloadCellViewCheckbox.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-02.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewCheckbox: PayloadCellView, ProfileCreatorCellView, CheckboxCellView {
    
    // MARK: -
    // MARK: Instance Variables
    
    var checkbox: NSButton?
    var valueDefault: Bool = false
    var valueInverted: Bool = false
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, payloadIndex: Int, settings: Dictionary<String, Any>, editor: ProfileEditor) {
        super.init(subkey: subkey, payloadIndex: payloadIndex, settings: settings,  editor: editor)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.checkbox = EditorCheckbox.noTitle(cellView: self)
        self.setupCheckbox()
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? Bool {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Set Value Inverted
        // ---------------------------------------------------------------------
        self.valueInverted = subkey.valueInverted
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if let value = profile?.getPayloadSetting(key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, payloadIndex: payloadIndex) as? Bool {
            self.checkbox?.state = self.state(forValue: value)
        } else {
            self.checkbox?.state = self.state(forValue: self.valueDefault)
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.checkbox
        self.trailingKeyView = self.checkbox
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(self.cellViewConstraints)
    }
    
    // MARK: -
    // MARK: Value Inverted Functions
    
    func state(forValue value: Bool) -> NSControl.StateValue {
        if self.valueInverted {
            return value ? .off : .on
        } else {
            return value ? .on : .off
        }
    }
    
    func value(forState state: NSControl.StateValue) -> Bool {
        if self.valueInverted {
            return state == .on ? false : true
        } else {
            return state == .on ? true : false
        }
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    override func enable(_ enable: Bool) {
        self.isEnabled = enable
        self.checkbox?.isEnabled = enable
    }
    
    // MARK: -
    // MARK: CheckboxCellView Functions
    
    func clicked(_ checkbox: NSButton) {
        guard
            let subkey = self.subkey,
            let profile = self.profile else { return }
        
        profile.updatePayloadSettings(value: self.value(forState: checkbox.state), subkey: subkey, payloadIndex: self.payloadIndex)
    }
}

// MARK: -
// MARK: Setup NSLayoutConstraints

extension PayloadCellViewCheckbox {
    
    private func setupCheckbox() {
        
        // ---------------------------------------------------------------------
        //  Add Checkbox to TableCellView
        // ---------------------------------------------------------------------
        guard let checkbox = self.checkbox else { return }
        self.addSubview(checkbox)
        
        // ---------------------------------------------------------------------
        //  Update leading constraints for TextField Title
        // ---------------------------------------------------------------------
        self.updateConstraints(forViewLeadingTitle: checkbox)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Leading
        self.addConstraints(forViewLeading: checkbox)
        
        // Width
        self.cellViewConstraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: checkbox.intrinsicContentSize.width))
    }
}

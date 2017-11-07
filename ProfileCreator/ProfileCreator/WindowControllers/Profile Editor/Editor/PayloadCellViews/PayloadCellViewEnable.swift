//
//  PayloadCellViewEnable.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-10-27.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewEnable: NSTableCellView, CheckboxCellView {
    
    weak var subkey: PayloadSourceSubkey?
    weak var editor: ProfileEditor?
    
    // MARK: -
    // MARK: Instance Variables
    
    var checkbox: NSButton?
    
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
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.checkbox = EditorCheckbox.noTitle(constraints: &constraints, cellView: self)
        setupCheckbox(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    // MARK: CheckboxCellView Functions
    
    func clicked(_ checkbox: NSButton) {
        guard let subkey = self.subkey else { return }
        self.editor?.updateViewSettings(value: checkbox.state == .on ? false : true, key: SettingsKey.enabled, subkey: subkey)
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupCheckbox(constraints: inout [NSLayoutConstraint]) {
        
        guard
            let checkbox = self.checkbox,
            let subkey = self.subkey else { return }
        
        // ---------------------------------------------------------------------
        //  Add Checkbox to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(checkbox)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        var topConstant: CGFloat = 10.6
        
        if subkey.type == .bool {
            topConstant = 11.29
        }
        
        
        // Top
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: topConstant))
        
        // Center X
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
    }
}

//
//  PayloadCellViewPopUpButton.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewPopUpButton: NSTableCellView, ProfileCreatorCellView, PayloadCellView, PopUpButtonCellView {
    
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
    var isEnabled: Bool { return self.popUpButton?.isEnabled ?? false }
    
    // MARK: -
    // MARK: Instance Variables
    
    var popUpButton: NSPopUpButton?
    var valueDefault: Any?
    
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
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        var titles = [String]()
        if let rangeList = subkey.rangeList {
            for value in rangeList {
                titles.append(String(describing: value))
            }
        }
        self.popUpButton = EditorPopUpButton.withTitles(titles: titles, constraints: &constraints, cellView: self)
        setupPopUpButton(constraints: &constraints)
        
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
        //  Setup Constraints
        // ---------------------------------------------------------------------
        addConstraintsFor(item: self.popUpButton!, orientation: .below, constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if
            let domainSettings = settings[subkey.domain] as? Dictionary<String, Any>,
            let value = domainSettings[subkey.keyPath] as? String {
            if self.popUpButton!.itemTitles.contains(value) {
                self.popUpButton!.selectItem(withTitle: value)
            }
        } else if let valueDefault = self.valueDefault {
            let valueTitle = String(describing: valueDefault)
            if self.popUpButton!.itemTitles.contains(valueTitle) {
                self.popUpButton!.selectItem(withTitle: valueTitle)
            }
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.popUpButton
        self.trailingKeyView = self.popUpButton
        
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
        self.popUpButton?.isEnabled = enable
    }
    
    // MARK: -
    // MARK: PopUpButton Functions
    
    func selected(_ popUpButton: NSPopUpButton) {
        
        guard
            let subkey = self.subkey,
            let selectedTitle = popUpButton.titleOfSelectedItem  else { return }
        
        self.editor?.updatePayloadSettings(value: selectedTitle, subkey: subkey)
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupPopUpButton(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add PopUpButton to TableCellView
        // ---------------------------------------------------------------------
        guard let popUpButton = self.popUpButton else { return }
        self.addSubview(popUpButton)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: popUpButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: popUpButton,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8))
    }
}

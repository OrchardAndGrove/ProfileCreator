//
//  PayloadCellViewPopUpButton.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewPopUpButton: PayloadCellView, ProfileCreatorCellView, PopUpButtonCellView {
    
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
        super.init(subkey: subkey, editor: editor, settings: settings)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        var titles = [String]()
        if let rangeList = subkey.rangeList {
            for value in rangeList {
                titles.append(String(describing: value))
            }
        }
        self.popUpButton = EditorPopUpButton.withTitles(titles: titles, cellView: self)
        self.setupPopUpButton()

        
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
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(self.cellViewConstraints)
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    override func enable(_ enable: Bool) {
        self.isEnabled = enable
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
}
    
// MARK: -
// MARK: Setup NSLayoutConstraints
    
extension PayloadCellViewPopUpButton {
    
    private func setupPopUpButton() {
        
        // ---------------------------------------------------------------------
        //  Add PopUpButton to TableCellView
        // ---------------------------------------------------------------------
        guard let popUpButton = self.popUpButton else { return }
        self.addSubview(popUpButton)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        self.addConstraints(forViewBelow: popUpButton)
        
        // Leading
        self.addConstraints(forViewLeading: popUpButton)
    }
}

//
//  PayloadCellViewPopUpButton.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2018 Erik Berglund. All rights reserved.
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
    
    required init(subkey: PayloadSourceSubkey, payloadIndex: Int, settings: Dictionary<String, Any>, editor: ProfileEditor) {
        super.init(subkey: subkey, payloadIndex: payloadIndex, settings: settings,  editor: editor)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        var titles = [String]()
        if let rangeListTitles = subkey.rangeListTitles {
            titles = rangeListTitles
        } else if let rangeList = subkey.rangeList {
            for value in rangeList {
                titles.append(String(describing: value))
            }
        }
        self.popUpButton = EditorPopUpButton.withTitles(titles: titles, cellView: self)
        self.setupPopUpButton()

        // ---------------------------------------------------------------------
        //  Setup Message if it is set
        // ---------------------------------------------------------------------
        if let textFieldMessage = self.textFieldMessage {
            super.setup(textFieldMessage: textFieldMessage, belowView: self.popUpButton!)
        }
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if let value = profile?.getPayloadSetting(key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, payloadIndex: payloadIndex) as? String {
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
            let profile = self.profile,
            let subkey = self.subkey,
            let selectedTitle = popUpButton.titleOfSelectedItem  else { return }
        
        profile.updatePayloadSettings(value: selectedTitle, subkey: subkey, payloadIndex: self.payloadIndex)
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

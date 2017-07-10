//
//  Alert.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-10.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

struct ButtonTitle {
    static let ok = "OK"
    static let cancel = "Cancel"
}

class Alert: NSObject {
    
    var alert = NSAlert()
    var textFieldInput: NSTextField?
    var firstButton: NSButton?
    var secondButton: NSButton?
    var thirdButton: NSButton?
    
    public func showAlert(message: String,
                          informativeText: String?,
                          window: NSWindow,
                          defaultString: String?,
                          placeholderString: String?,
                          firstButtonTitle: String,
                          secondButtonTitle: String?,
                          thirdButtonTitle: String?,
                          firstButtonState: Bool,
                          sender: Any?,
                          returnValue: @escaping (String, Int) -> Void ) {
        
        // ---------------------------------------------------------------------
        //  Configure alert
        // ---------------------------------------------------------------------
        self.alert.alertStyle = .informational
        
        // ---------------------------------------------------------------------
        //  Add buttons
        // ---------------------------------------------------------------------
        self.alert.addButton(withTitle: firstButtonTitle)
        self.firstButton = self.alert.buttons.first
        self.firstButton!.isEnabled = firstButtonState
        
        if let title = secondButtonTitle {
            self.alert.addButton(withTitle: title)
            self.secondButton = self.alert.buttons[1]
        }
        
        if let title = thirdButtonTitle {
            self.alert.addButton(withTitle: title)
            self.thirdButton = self.alert.buttons[2]
        }
        
        // ---------------------------------------------------------------------
        //  Add message
        // ---------------------------------------------------------------------
        self.alert.messageText = message
        if let text = informativeText {
            self.alert.informativeText = text
        }
        
        // ---------------------------------------------------------------------
        //  Add accessory view TextField
        // ---------------------------------------------------------------------
        self.textFieldInput = NSTextField(frame: NSRect(x: 0, y: 0, width: 292, height: 22))
        if sender != nil, let delegate = sender as? NSTextFieldDelegate {
            self.textFieldInput!.delegate = delegate
        }
        
        if let string = defaultString {
            self.textFieldInput!.stringValue = string
        } else if self.textFieldInput?.delegate != nil {
            self.firstButton!.isEnabled = false
        }
        
        if let string = placeholderString {
            self.textFieldInput!.placeholderString = string
        }
        
        self.alert.accessoryView = self.textFieldInput
        
        // ---------------------------------------------------------------------
        //  Show modal alert in window
        // ---------------------------------------------------------------------
        self.alert.beginSheetModal(for: window) { (returnCode) in
            returnValue(self.textFieldInput!.stringValue, returnCode)
        }
    }
    
}

extension Alert: NSTextFieldDelegate {
    
}

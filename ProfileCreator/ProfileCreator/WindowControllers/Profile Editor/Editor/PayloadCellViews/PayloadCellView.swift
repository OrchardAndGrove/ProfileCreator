//
//  PayloadCellViewProtocol.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

protocol ProfileCreatorCellView {
    var height: CGFloat { get set }
    func addSubview(_ subview: NSView)
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

class PayloadCellView: NSTableCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    weak var editor: ProfileEditor?
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var textFieldMessage: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    var isEnabled = false
    var isEditing = false
    
    var cellViewConstraints = [NSLayoutConstraint]()
    var indent: Int = 0
    
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
        //  Get Indent
        // ---------------------------------------------------------------------
        self.indent = subkey.parentSubkeys?.filter({$0.type == PayloadValueType.dictionary}).count ?? 0
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let profile = editor.profile, let textFieldTitle = EditorTextField.title(profile: profile, subkey: subkey, indent: self.indent, constraints: &self.cellViewConstraints, cellView: self) {
            self.textFieldTitle = textFieldTitle
        }
        
        if let textFieldDescription = EditorTextField.description(subkey: subkey, indent: self.indent, constraints: &self.cellViewConstraints, cellView: self) {
            self.textFieldDescription = textFieldDescription
        }
        
        if let profile = editor.profile, let textFieldMessage = EditorTextField.message(profile: profile, subkey: subkey, indent: self.indent, constraints: &self.cellViewConstraints, cellView: self) {
            self.textFieldMessage = textFieldMessage
        }
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(3.0)
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    func enable(_ enable: Bool) {
        Swift.print("This should be overridden by the subclass, you should not see this message!")
    }
    
    func indentValue() -> CGFloat {
        return 8.0 + (16.0 * CGFloat(self.indent))
    }
}

// MARK: -
// MARK: Setup NSLayoytConstraints

extension PayloadCellView {
    func setup(textFieldMessage: NSTextField, belowView: NSView) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        self.cellViewConstraints.append(NSLayoutConstraint(item: textFieldMessage,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: belowView,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: 4.0))
        
        self.updateHeight(4.0 + textFieldMessage.intrinsicContentSize.height)
    }
}

// MARK: -
// MARK: Add NSLayoytConstraints

extension PayloadCellView {
    func addConstraints(forViewBelow viewBelow: NSView) {
        if let textFieldDescription = self.textFieldDescription {
            self.cellViewConstraints.append(NSLayoutConstraint(item: viewBelow,
                                                               attribute: .top,
                                                               relatedBy: .equal,
                                                               toItem: textFieldDescription,
                                                               attribute: .bottom,
                                                               multiplier: 1.0,
                                                               constant: 7.0))
            
            self.updateHeight(7.0 + viewBelow.intrinsicContentSize.height)
        } else if let textFieldTitle = self.textFieldTitle {
            self.cellViewConstraints.append(NSLayoutConstraint(item: viewBelow,
                                                               attribute: .top,
                                                               relatedBy: .equal,
                                                               toItem: textFieldTitle,
                                                               attribute: .bottom,
                                                               multiplier: 1.0,
                                                               constant: 7.0))
            
            self.updateHeight(7.0 + viewBelow.intrinsicContentSize.height)
        } else {
            self.cellViewConstraints.append(NSLayoutConstraint(item: viewBelow,
                                                               attribute: .top,
                                                               relatedBy: .equal,
                                                               toItem: self,
                                                               attribute: .top,
                                                               multiplier: 1.0,
                                                               constant: 8.0))
            
            self.updateHeight(8.0 + viewBelow.intrinsicContentSize.height)
        }
    }
    
    func addConstraints(forViewLeading viewLeading: NSView) {
        self.cellViewConstraints.append(NSLayoutConstraint(item: viewLeading,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: self,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: self.indentValue()))
    }
    
    func addConstraints(forViewTrailing viewTrailing: NSView) {
        self.cellViewConstraints.append(NSLayoutConstraint(item: self,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: viewTrailing,
                                                           attribute: .trailing,
                                                           multiplier: 1.0,
                                                           constant: 8.0))
    }
}

// MARK: -
// MARK: Update NSLayoytConstraints

extension PayloadCellView {
    func updateConstraints(forViewLeadingTitle viewLeading: NSView) {
        
        guard let textFieldTitle = self.textFieldTitle else { return }
        
        // ---------------------------------------------------------------------
        //  Remove current leading constraint from TextField Title
        // ---------------------------------------------------------------------
        self.cellViewConstraints = self.cellViewConstraints.filter({ if let firstItem = $0.firstItem as? NSTextField, firstItem == self.textFieldTitle, $0.firstAttribute == .leading { return false } else { return true }  })
        
        // ---------------------------------------------------------------------
        //  Calculate the leading constant
        // ---------------------------------------------------------------------
        let leadingConstant: CGFloat
        if viewLeading is NSPopUpButton, viewLeading is NSTextField {
            leadingConstant = 6.0
        } else {
            leadingConstant = 2.0
        }
        
        // Leading
        self.cellViewConstraints.append(NSLayoutConstraint(item: textFieldTitle,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: viewLeading,
                                                           attribute: .trailing,
                                                           multiplier: 1.0,
                                                           constant: leadingConstant))
        
        // Baseline
        self.cellViewConstraints.append(NSLayoutConstraint(item: textFieldTitle,
                                                           attribute: .firstBaseline,
                                                           relatedBy: .equal,
                                                           toItem: viewLeading,
                                                           attribute: .firstBaseline,
                                                           multiplier: 1.0,
                                                           constant: 0.0))
    }
}

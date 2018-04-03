//
//  ProfileEditorTabView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-04-01.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileEditorTab: NSView {
    
    let buttonClose = NSButton()
    let textFieldTitle = NSTextField()
    let textFieldErrorCount = NSTextField()
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup TabView
        // ---------------------------------------------------------------------
        self.setupButtonClose(constraints: &constraints)
        self.setupTextFieldTitle(constraints: &constraints)
        self.setupTextFieldErrorCount(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func clicked(button: NSButton) {
        Swift.print("clicked: \(button)")
    }
}

extension ProfileEditorTab {
    func setupButtonClose(constraints: inout [NSLayoutConstraint]) {
        self.buttonClose.translatesAutoresizingMaskIntoConstraints = false
        self.buttonClose.translatesAutoresizingMaskIntoConstraints = false
        self.buttonClose.bezelStyle = .roundRect
        self.buttonClose.setButtonType(.momentaryPushIn)
        self.buttonClose.isBordered = false
        self.buttonClose.isTransparent = false
        self.buttonClose.image = NSImage(named: .stopProgressTemplate)
        self.buttonClose.action = #selector(self.clicked(button:))
        self.buttonClose.target = self
        
        // ---------------------------------------------------------------------
        //  Add and to superview
        // ---------------------------------------------------------------------
        self.addSubview(self.buttonClose)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // CenterY
        constraints.append(NSLayoutConstraint(item: self.buttonClose,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.buttonClose,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 6.0))
        
        // Width
        constraints.append(NSLayoutConstraint(item: self.buttonClose,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 18.0))
        
        // Width == Height
        constraints.append(NSLayoutConstraint(item: self.buttonClose,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self.buttonClose,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    func setupTextFieldTitle(constraints: inout [NSLayoutConstraint]) {
        self.textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldTitle.lineBreakMode = .byTruncatingTail
        self.textFieldTitle.isBordered = false
        self.textFieldTitle.isBezeled = false
        self.textFieldTitle.drawsBackground = false
        self.textFieldTitle.isEditable = false
        self.textFieldTitle.isSelectable = false
        self.textFieldTitle.textColor = .labelColor
        self.textFieldTitle.alignment = .center
        self.textFieldTitle.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular)
        self.textFieldTitle.stringValue = "Title of the TAB"
        
        // ---------------------------------------------------------------------
        //  Add and to superview
        // ---------------------------------------------------------------------
        self.addSubview(self.textFieldTitle)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // CenterY
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.buttonClose,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 4.0))
    }
    
    func setupTextFieldErrorCount(constraints: inout [NSLayoutConstraint]) {
        self.textFieldErrorCount.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldErrorCount.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldErrorCount.lineBreakMode = .byTruncatingTail
        self.textFieldErrorCount.isBordered = false
        self.textFieldErrorCount.isBezeled = false
        self.textFieldErrorCount.drawsBackground = false
        self.textFieldErrorCount.isEditable = false
        self.textFieldErrorCount.isSelectable = false
        self.textFieldErrorCount.textColor = .labelColor
        self.textFieldErrorCount.alignment = .center
        self.textFieldErrorCount.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .regular)
        self.textFieldErrorCount.stringValue = "0"
        
        // ---------------------------------------------------------------------
        //  Add and to superview
        // ---------------------------------------------------------------------
        self.addSubview(self.textFieldErrorCount)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // CenterY
        constraints.append(NSLayoutConstraint(item: self.textFieldErrorCount,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldErrorCount,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 4.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldErrorCount,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 6.0))
    }
}

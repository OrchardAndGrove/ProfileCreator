//
//  PayloadCellViewHostPort.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadCellViewHostPort: NSTableCellView, ProfileCreatorCellView, PayloadCellView {
    
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
    
    var textFieldHost: PayloadTextField?
    var textFieldPort: PayloadTextField?
    var constraintPortTrailing: NSLayoutConstraint?
    @objc var valuePort: NSNumber?
    
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
        self.textFieldHost = EditorTextField.input(defaultString: "", placeholderString: "Host", constraints: &constraints, cellView: self)
        setupTextField(host: self.textFieldHost!, constraints: &constraints)
        self.textFieldPort = EditorTextField.input(defaultString: "", placeholderString: "Port", constraints: &constraints, cellView: self)
        setupTextField(port: self.textFieldPort!, constraints: &constraints)
        _ = EditorTextField.label(string: ":", fontWeight: NSFont.Weight.regular, leadingItem: self.textFieldHost!, trailingItem: self.textFieldPort!, constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup Constraints
        // ---------------------------------------------------------------------
        addConstraintsFor(item: self.textFieldHost!, orientation: .below, constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.textFieldHost
        self.trailingKeyView = self.textFieldPort
        
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
    // MARK: Setup Layout Constraints
    
    private func setupTextField(host: NSTextField, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(host)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: host,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
    
    private func setupTextField(port: NSTextField, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add Number Formatter to TextField
        // ---------------------------------------------------------------------
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.minimum = 1
        numberFormatter.maximum = 65535
        port.formatter = numberFormatter
        port.bind(.value, to: self, withKeyPath: "valuePort", options: [NSBindingOption.nullPlaceholder: "Port", NSBindingOption.continuouslyUpdatesValue: true])
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(port)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Width (fixed to fit 5 characters: 49)
        constraints.append(NSLayoutConstraint(item: port,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 49.0))
        
        // Trailing
        self.constraintPortTrailing = NSLayoutConstraint(item: self,
                                                         attribute: .trailing,
                                                         relatedBy: .equal,
                                                         toItem: port,
                                                         attribute: .trailing,
                                                         multiplier: 1.0,
                                                         constant: 8.0)
        
        constraints.append(self.constraintPortTrailing!)
    }
}

//
//  PayloadCellViewItems.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class EditorTableView {
    
    class func scrollView(string: String?,
                         constraints: inout [NSLayoutConstraint],
                         cellView: PayloadCellView & TableViewCellView) -> NSScrollView {
        
        // ---------------------------------------------------------------------
        //  Create and setup TextField
        // ---------------------------------------------------------------------
        let tableView = NSTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.gridStyleMask = .solidHorizontalGridLineMask
        tableView.focusRingType = .none
        tableView.rowSizeStyle = .default
        tableView.floatsGroupRows = false
        //tableView.headerView = nil
        tableView.allowsMultipleSelection = false
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.dataSource = cellView
        tableView.delegate = cellView
        tableView.target = cellView
        tableView.sizeLastColumnToFit()
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = tableView
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = false // FIXME: TRUE When added ios-style scrollers
        //scrollView.autoresizesSubviews = true
        cellView.addSubview(scrollView)
        
        // ---------------------------------------------------------------------
        //  Setup Layout Constraings for ScrollView
        // ---------------------------------------------------------------------
        
        // Height
        constraints.append(NSLayoutConstraint(item: scrollView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 100.0))
        
        cellView.updateHeight(100.0)
        
        return scrollView
    }
}

// NSTableCellViews

class EditorTableViewCellViewTextField: NSTableCellView {
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(cellView: TableViewCellView, keyPath: String, stringValue: String?, placeholderString: String?, row: Int) {
        
        super.init(frame: NSZeroRect)
        
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byClipping
        textField.isBordered = false
        textField.isBezeled = false
        textField.bezelStyle = .squareBezel
        textField.drawsBackground = false
        textField.isEditable = true
        textField.isSelectable = true
        textField.textColor = .controlTextColor
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        textField.stringValue = stringValue ?? ""
        textField.placeholderString = placeholderString ?? ""
        textField.delegate = cellView
        textField.tag = row
        textField.identifier = NSUserInterfaceItemIdentifier(rawValue: keyPath)
        self.addSubview(textField)
        self.textField = textField
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 2.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 2.0))

        // CenterY
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        /*
        // Top
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        
        // Bottom
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))
 */
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
}

class EditorTableViewCellViewTextFieldNumber: NSTableCellView {
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(cellView: TableViewCellView, key: String, value: NSNumber?, placeholderValue: NSNumber?, type: PayloadValueType, row: Int) {
        
        super.init(frame: NSZeroRect)
        
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byClipping
        textField.isBordered = false
        textField.isBezeled = false
        textField.bezelStyle = .squareBezel
        textField.drawsBackground = false
        textField.isEditable = true
        textField.isSelectable = true
        textField.textColor = .controlTextColor
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        textField.stringValue = value?.stringValue ?? ""
        textField.placeholderString = placeholderValue?.stringValue ?? ""
        textField.delegate = cellView
        textField.tag = row
        textField.identifier = NSUserInterfaceItemIdentifier(rawValue: key)
        self.addSubview(textField)
        self.textField = textField
        
        // ---------------------------------------------------------------------
        //  Setup Formatter
        // ---------------------------------------------------------------------
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        if type == .integer {
            numberFormatter.maximumFractionDigits = 0
        }
        textField.formatter = numberFormatter
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 2.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 2.0))
        
        // CenterY
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        /*
         // Top
         constraints.append(NSLayoutConstraint(item: textField,
         attribute: .top,
         relatedBy: .equal,
         toItem: self,
         attribute: .top,
         multiplier: 1.0,
         constant: 0.0))
         
         
         // Bottom
         constraints.append(NSLayoutConstraint(item: self,
         attribute: .bottom,
         relatedBy: .equal,
         toItem: textField,
         attribute: .bottom,
         multiplier: 1.0,
         constant: 0.0))
         */
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
}

class EditorTableViewCellViewCheckbox: NSTableCellView {
    
    // MARK: -
    // MARK: Variables
    
    let checkbox = NSButton()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(cellView: TableViewCellView, key: String, value: Bool, row: Int) {
        
        super.init(frame: NSZeroRect)
        
        self.checkbox.translatesAutoresizingMaskIntoConstraints = false
        self.checkbox.setButtonType(.switch)
        self.checkbox.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        self.checkbox.state = (value) ? .on : .off
        self.checkbox.title = ""
        self.addSubview(self.checkbox)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // CenterX
        constraints.append(NSLayoutConstraint(item: self.checkbox,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // CenterY
        constraints.append(NSLayoutConstraint(item: self.checkbox,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
}

class EditorTableViewCellViewPopUpButton: NSTableCellView {
    
    // MARK: -
    // MARK: Variables
    
    let popUpButton = NSPopUpButton()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(cellView: TableViewCellView, key: String, titles: [String], row: Int) {
        
        super.init(frame: NSZeroRect)
        
        self.popUpButton.translatesAutoresizingMaskIntoConstraints = false
        //self.popUpButton.action = #selector(cellView.selected(_:))
        self.popUpButton.target = cellView
        self.popUpButton.addItems(withTitles: titles)
        self.addSubview(self.popUpButton)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // CenterX
        constraints.append(NSLayoutConstraint(item: self.popUpButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.popUpButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 1.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.popUpButton,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 1.0))
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
}


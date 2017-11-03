//
//  ProfileEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-24.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class ProfileEditor: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    private let tableView = ProfileEditorTableView()
    private let headerView = ProfileEditorHeaderView()
    private let scrollView = NSScrollView()
    private let separator = NSBox(frame: NSZeroRect)
    public let editorView = NSView()
    
    private let payloadCellViews = PayloadCellViews()
    
    private var firstCellView: NSView?
    private var selectedCellView: NSView?
    
    fileprivate var cellViews = [NSTableCellView]()
    fileprivate var editorWindow: NSWindow?
    
    public weak var profile: Profile?
    private var selectedPayloadPlaceholder: PayloadPlaceholder?
    
    init(profile: Profile) {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        self.headerView.profileEditor = self
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup EditorView
        // ---------------------------------------------------------------------
        self.setupEditorView(constraints: &constraints)
        self.setupHeaderView(constraints: &constraints)
        self.setupSeparator(constraints: &constraints)
        self.setupTableView(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Reload the TableView
        // ---------------------------------------------------------------------
        self.reloadTableView(force: true)
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
    
    func reloadTableView(force: Bool = false) {
        /*
        guard let window = self.tableView.window else { return }
        
        Swift.print("window.firstResponder: \(window.firstResponder?.nextResponder)")
        
        var firstResponder = window.firstResponder

        Swift.print("Current First Responder")
        */
        self.tableView.reloadData()
    }
    
    func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey) {
        self.profile?.updateViewSettings(value: value, key: key, subkey: subkey, updateComplete: { (successful, error) in
            Swift.print("ViewSettings Changed with status: \(successful)")
        })
    }
    
    func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey) {
        self.profile?.updatePayloadSettings(value: value, subkey: subkey, updateComplete: { (successful, error) in
            Swift.print("PayloadSettings Changed with status: \(successful)")
        })
    }
    
    func select(payloadPlaceholder: PayloadPlaceholder) {
        if self.selectedPayloadPlaceholder != payloadPlaceholder {
            self.selectedPayloadPlaceholder = payloadPlaceholder
            Swift.print("Class: \(self.self), Function: \(#function), Selecting this placeholder in the editor: \(payloadPlaceholder.title)")
            
            self.headerView.select(payloadPlaceholder: payloadPlaceholder)
            
            // FIXME: Apply current settings here (like hidden)
            self.cellViews = self.payloadCellViews.cellViews(payloadPlaceholder: payloadPlaceholder, profileEditor: self)
            
            // FIXME: Why Force?
            self.reloadTableView(force: true)
        }
    }
    
    func updateKeyViewLoop(window: NSWindow) {
        var previousCellView: PayloadCellView? = nil
        var firstCellView: PayloadCellView? = nil
        
        for (index, cellView) in self.cellViews.enumerated() {
            guard let payloadCellView = cellView as? PayloadCellView else { continue }
            
            if payloadCellView.leadingKeyView != nil {
                if let previous = previousCellView {
                    previous.trailingKeyView!.nextKeyView = payloadCellView.leadingKeyView
                } else {
                    firstCellView = payloadCellView
                }
                previousCellView = payloadCellView
                
                if self.cellViews.count == index + 1  {
                    tableView.nextKeyView = firstCellView?.leadingKeyView
                    payloadCellView.trailingKeyView!.nextKeyView = tableView
                }
            }
        }
        
        if firstCellView != nil {
            window.initialFirstResponder = firstCellView as? NSView
            self.firstCellView = firstCellView as? NSView
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupEditorView(constraints: inout [NSLayoutConstraint]) {
        self.editorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupHeaderView(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add and setup Header View
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.headerView.headerView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: self.headerView.headerView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 30.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.headerView.headerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.editorView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.headerView.headerView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    private func setupSeparator(constraints: inout [NSLayoutConstraint]) {
        self.separator.translatesAutoresizingMaskIntoConstraints = false
        self.separator.boxType = .separator
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.separator)
        
        // ---------------------------------------------------------------------
        //  Add Constraints
        // ---------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.separator,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.headerView.headerView,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.separator,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 20.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.editorView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.separator,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 20.0))
        
    }
    
    private func setupTableView(constraints: inout [NSLayoutConstraint]) {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.floatsGroupRows = false
        self.tableView.rowSizeStyle = .default
        self.tableView.headerView = nil
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.target = self
        self.tableView.allowsMultipleSelection = true
        self.tableView.selectionHighlightStyle = .none
        self.tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        self.tableView.sizeLastColumnToFit()
        self.tableView.refusesFirstResponder = true
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Leading
        // ---------------------------------------------------------------------
        let tableColumnPaddingLeading = NSTableColumn(identifier: .tableColumnPaddingLeading)
        tableColumnPaddingLeading.isEditable = false
        tableColumnPaddingLeading.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingLeading.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingLeading)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Enable
        // ---------------------------------------------------------------------
        let tableColumnPayloadEnable = NSTableColumn(identifier: .tableColumnPayloadEnable)
        tableColumnPayloadEnable.isEditable = false
        tableColumnPayloadEnable.width = 20.0
        tableColumnPayloadEnable.minWidth = 20.0
        tableColumnPayloadEnable.maxWidth = 20.0
        self.tableView.addTableColumn(tableColumnPayloadEnable)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Payload
        // ---------------------------------------------------------------------
        let tableColumnPayload = NSTableColumn(identifier: .tableColumnPayload)
        tableColumnPayload.isEditable = false
        tableColumnPayload.width = editorTableViewColumnPayloadWidth
        tableColumnPayload.minWidth = editorTableViewColumnPayloadWidth
        tableColumnPayload.maxWidth = editorTableViewColumnPayloadWidth
        self.tableView.addTableColumn(tableColumnPayload)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Trailing
        // ---------------------------------------------------------------------
        let tableColumnPaddingTrailing = NSTableColumn(identifier: .tableColumnPaddingTrailing)
        tableColumnPaddingTrailing.isEditable = false
        tableColumnPaddingTrailing.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingTrailing.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingTrailing)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView and add TableView as Document View
        // ---------------------------------------------------------------------
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        //self.scrollView.hasVerticalScroller = true
        self.scrollView.documentView = self.tableView
        // self.scrollView.autoresizesSubviews = true
        
        // ---------------------------------------------------------------------
        //  Add and setup ScrollView
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.scrollView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: self.scrollView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.separator,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.scrollView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.editorView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.scrollView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Bottom
        constraints.append(NSLayoutConstraint(item: self.scrollView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
}

extension ProfileEditor: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.cellViews.count
    }
}

extension ProfileEditor: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cellView = self.cellViews[row] as? ProfileCreatorCellView {
            return cellView.height
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == .tableColumnPayload {
            // FIXME: Should only be needed once and NOT here
            self.updateKeyViewLoop(window: tableView.window!)
            return self.cellViews[row]
        } else if tableColumn?.identifier == .tableColumnPayloadEnable {
            if let cellView = self.cellViews[row] as? PayloadCellView, let subkey = cellView.subkey {
                return PayloadCellViewEnable(subkey: subkey, editor: self, settings: Dictionary<String, Any>())
            }
        }
        return nil
    }
}

// Sublcasses to enable FirstResponder and KeyView

class PayloadButton: NSButton {
    override var acceptsFirstResponder: Bool { return self.isEnabled }
    override var canBecomeKeyView: Bool { return self.isEnabled }
}

class PayloadCheckbox: NSButton {
    override var acceptsFirstResponder : Bool { return self.isEnabled }
    override var canBecomeKeyView: Bool { return self.isEnabled }
}

class PayloadPopUpButton: NSPopUpButton {
    override var acceptsFirstResponder : Bool { return self.isEnabled }
    override var canBecomeKeyView: Bool { return self.isEnabled }
}

class PayloadTextField: NSTextField {
    override var acceptsFirstResponder : Bool { return self.isEditable }
    override var canBecomeKeyView: Bool { return self.isEditable }
}

class PayloadTextView: NSTextView {
    override var acceptsFirstResponder : Bool { return self.isEditable }
    override var canBecomeKeyView: Bool { return self.isEditable }
    override func doCommand(by selector: Selector) {
        if selector == #selector(insertTab(_:)) {
            self.window?.selectNextKeyView(nil)
        } else if selector == #selector(insertBacktab(_:)) {
            self.window?.selectPreviousKeyView(nil)
        } else {
            super.doCommand(by: selector)
        }
    }
}

class ProfileEditorTableView: NSTableView {
    override var acceptsFirstResponder: Bool { return false }
    override var canBecomeKeyView: Bool { return false }
}


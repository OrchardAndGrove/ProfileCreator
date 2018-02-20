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
    
    let tableView = ProfileEditorTableView()
    let headerView = ProfileEditorHeaderView()
    let scrollView = NSScrollView()
    let separator = NSBox(frame: NSZeroRect)
    let settings: ProfileEditorSettings
    
    let editorColumnEnableSelector: String
    let editorShowDisabledSelector: String
    let editorShowHiddenSelector: String
    let editorShowSupervisedSelector: String
    
    public let editorView = NSView()
    
    private let payloadCellViews = PayloadCellViews()
    
    private var firstCellView: NSView?
    private var selectedCellView: NSView?
    
    fileprivate var cellViews = [NSTableCellView]()
    fileprivate var editorWindow: NSWindow?
    
    public weak var profile: Profile?
    private var selectedPayloadPlaceholder: PayloadPlaceholder?
    
    // MARK: -
    // MARK: Initialization
    
    init(profile: Profile) {
        
        self.editorColumnEnableSelector = NSStringFromSelector(#selector(getter: profile.editorColumnEnable))
        self.editorShowDisabledSelector = NSStringFromSelector(#selector(getter: profile.editorShowDisabled))
        self.editorShowHiddenSelector = NSStringFromSelector(#selector(getter: profile.editorShowHidden))
        self.editorShowSupervisedSelector = NSStringFromSelector(#selector(getter: profile.editorShowSupervised))
        
        self.settings = ProfileEditorSettings(profile: profile)
        
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
        self.setupTableView(profile: profile, constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        self.profile?.addObserver(self, forKeyPath: self.editorColumnEnableSelector, options: .new, context: nil)
        self.profile?.addObserver(self, forKeyPath: self.editorShowDisabledSelector, options: .new, context: nil)
        self.profile?.addObserver(self, forKeyPath: self.editorShowHiddenSelector, options: .new, context: nil)
        self.profile?.addObserver(self, forKeyPath: self.editorShowSupervisedSelector, options: .new, context: nil)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Reload the TableView
        // ---------------------------------------------------------------------
        self.reloadTableView(updateCellViews: true)
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        self.profile?.removeObserver(self, forKeyPath: self.editorColumnEnableSelector, context: nil)
        self.profile?.removeObserver(self, forKeyPath: self.editorShowDisabledSelector, context: nil)
        self.profile?.removeObserver(self, forKeyPath: self.editorShowHiddenSelector, context: nil)
        self.profile?.removeObserver(self, forKeyPath: self.editorShowSupervisedSelector, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath ?? "" {
        case self.editorShowDisabledSelector, self.editorShowHiddenSelector, self.editorShowSupervisedSelector:
            self.reloadTableView(updateCellViews: true)
        case self.editorColumnEnableSelector:
            if let tableColumn = self.tableView.tableColumn(withIdentifier: .tableColumnPayloadEnable), let show = change?[.newKey] as? Bool {
                tableColumn.isHidden = !show
            }
        default:
            Swift.print("Class: \(self.self), Function: \(#function), observeValueforKeyPath: \(String(describing: keyPath))")
        }
    }
    
    func reloadTableView(updateCellViews: Bool = false) {
        if updateCellViews, let selectedPayloadPlaceholder = self.selectedPayloadPlaceholder {
            self.cellViews = self.payloadCellViews.cellViews(payloadPlaceholder: selectedPayloadPlaceholder, profileEditor: self)
        }
        self.tableView.reloadData()
    }
    
    func updatePayloadSelection(selected: Bool, payloadSource: PayloadSource) {
        self.profile?.updatePayloadSelection(selected: selected, payloadSource: payloadSource, updateComplete: { (successful, error) in
            Swift.print("Class: \(self.self), Function: \(#function), SelectionSettings Changed with status: \(successful)")
        })
    }
    
    func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey) {
        self.profile?.updateViewSettings(value: value, key: key, subkey: subkey, updateComplete: { (successful, error) in
            if successful { self.reloadTableView(updateCellViews: true) }
            Swift.print("Class: \(self.self), Function: \(#function), ViewSettings Changed with status: \(successful)")
        })
    }
    
    func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey) {
        self.profile?.updatePayloadSettings(value: value, subkey: subkey, updateComplete: { (successful, error) in
            Swift.print("Class: \(self.self), Function: \(#function), PayloadSettings Changed with status: \(successful)")
        })
    }
    
    func select(payloadPlaceholder: PayloadPlaceholder) {
        Swift.print("select(payloadPlaceholder: \(payloadPlaceholder)")
        if self.selectedPayloadPlaceholder != payloadPlaceholder {
            self.selectedPayloadPlaceholder = payloadPlaceholder
            
            Swift.print("Class: \(self.self), Function: \(#function), Selecting this placeholder in the editor: \(payloadPlaceholder.title)")
            
            self.headerView.select(payloadPlaceholder: payloadPlaceholder)
            
            // FIXME: Why Force?
            self.reloadTableView(updateCellViews: true)
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
        
        // NOTE: This sometimes crashes, should investigate and check if object exists in the correct window, and why it doesnt sometimes.
        if firstCellView != nil {
            window.initialFirstResponder = firstCellView as? NSView
            self.firstCellView = firstCellView as? NSView
        }
    }
}

// MARK: -
// MARK: NSTableViewDataSource

extension ProfileEditor: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.cellViews.count
    }
}

// MARK: -
// MARK: NSTableViewDelegate

extension ProfileEditor: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cellView = self.cellViews[row] as? ProfileCreatorCellView {
            return cellView.height
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        // If the row is the first or last, get the view settings for the row below and abore respectively
        var rowNumber: Int
        if row == 0 {
            rowNumber = row + 1
        } else if row == (self.cellViews.count - 1) {
            rowNumber = row - 1
        } else {
            rowNumber = row
        }
        
        // Get the cell view and subkey for the row
        guard
            let profile = self.profile,
            let cellView = self.cellViews[rowNumber] as? PayloadCellView,
            let subkey = cellView.subkey else { return }
        
        let isEnabled = profile.subkeyIsEnabled(subkey: subkey)
        
        if !isEnabled {
            rowView.backgroundColor = NSColor.quaternaryLabelColor
        }
        
        cellView.enable(isEnabled)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == .tableColumnPayload {
            // FIXME: Should maybe not be done here?
            if
                self.cellViews.count == row + 1,
                let window = tableView.window {
                self.updateKeyViewLoop(window: window)
            }
            return self.cellViews[row]
        } else if tableColumn?.identifier == .tableColumnPayloadEnable {
            if let cellView = self.cellViews[row] as? PayloadCellView, let subkey = cellView.subkey, let viewSettings = self.profile?.payloadViewTypeSettings(type: subkey.payloadSourceType) {
                return PayloadCellViewEnable(subkey: subkey, editor: self, settings: viewSettings)
            }
        }
        return nil
    }
}

// MARK: -
// MARK: Subclasses to enable FirstResponder and KeyView

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


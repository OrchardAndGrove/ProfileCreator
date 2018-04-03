//
//  ProfileEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-24.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class ProfileEditor: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let headerView: ProfileEditorHeaderView
    let tabView = NSStackView()
    let tableView = ProfileEditorTableView()
    let textView = NSTextView()
    let scrollView = NSScrollView()
    let separator = NSBox(frame: NSZeroRect)
    let settings: ProfileEditorSettings
    
    var constraintsTabView = [NSLayoutConstraint]()
    var constraintScrollViewTopSeparator = NSLayoutConstraint()
    var constraintScrollViewTopTab = NSLayoutConstraint()
    
    public let editorView = NSView()
    
    private let payloadCellViews = PayloadCellViews()
    
    private var firstCellView: NSView?
    private var selectedCellView: NSView?
    
    fileprivate var cellViews = [NSTableCellView]()
    
    public weak var profile: Profile?
    private var selectedPayloadPlaceholder: PayloadPlaceholder?
    private var selectedPayloadIndex = 0
    private var selectedPayloadView: EditorViewTag = .profileCreator
    
    // MARK: -
    // MARK: Initialization
    
    init(profile: Profile) {
        
        self.settings = ProfileEditorSettings(profile: profile)
        self.headerView = ProfileEditorHeaderView(profile: profile)
        
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
        self.setupTabView(constraints: &constraints)
        self.setupSeparator(constraints: &constraints)
        self.setupTableView(profile: profile, constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup TextView
        // ---------------------------------------------------------------------
        self.setupTextView(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        profile.addObserver(self, forKeyPath: profile.editorSettingsRestoredSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorDisableOptionalKeysSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorColumnEnableSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorShowDisabledSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorShowHiddenSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorShowSupervisedSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorSelectedPlatformsUpdatedSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorSelectedScopeUpdatedSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorSelectedDistributionUpdatedSelector, options: .new, context: nil)
        
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
        
        if let profile = self.profile {
            profile.removeObserver(self, forKeyPath: profile.editorSettingsRestoredSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorDisableOptionalKeysSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorColumnEnableSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorShowDisabledSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorShowHiddenSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorShowSupervisedSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorSelectedPlatformsUpdatedSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorSelectedScopeUpdatedSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorSelectedDistributionUpdatedSelector, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let profile = self.profile else { return }
        switch keyPath ?? "" {
        case profile.editorSettingsRestoredSelector:
            if let window = self.tableView.window {
                for cellView in self.cellViews {
                    if cellView.allSubviews().contains(where: {$0 == window.firstResponder}), let payloadCellView = cellView as? PayloadCellView {
                        payloadCellView.isEditing = false
                        break
                    }
                }
            }
            
            self.reloadTableView(updateCellViews: true)
        case profile.editorShowDisabledSelector,
             profile.editorShowHiddenSelector,
             profile.editorShowSupervisedSelector,
             profile.editorDisableOptionalKeysSelector,
             profile.editorSelectedPlatformsUpdatedSelector,
             profile.editorSelectedScopeUpdatedSelector,
             profile.editorSelectedDistributionUpdatedSelector:
            
            self.reloadTableView(updateCellViews: true)
        case profile.editorColumnEnableSelector:
            if let tableColumnLeading = self.tableView.tableColumn(withIdentifier: .tableColumnPayloadEnableLeading), let show = change?[.newKey] as? Bool {
                tableColumnLeading.isHidden = !show
            }
            if let tableColumnTrailing = self.tableView.tableColumn(withIdentifier: .tableColumnPayloadEnableTrailing), let show = change?[.newKey] as? Bool {
                tableColumnTrailing.isHidden = !show
            }
            self.reloadTableView(updateCellViews: true)
        default:
            Swift.print("Class: \(self.self), Function: \(#function), observeValueforKeyPath: \(String(describing: keyPath))")
        }
    }
    
    func reloadTableView(updateCellViews: Bool = false) {
        if updateCellViews, let selectedPayloadPlaceholder = self.selectedPayloadPlaceholder {
            self.cellViews = self.payloadCellViews.cellViews(payloadPlaceholder: selectedPayloadPlaceholder, payloadIndex: self.selectedPayloadIndex, profileEditor: self)
        }
        self.tableView.reloadData()
    }
    
    func updatePayloadSelection(selected: Bool, payloadSource: PayloadSource) {
        if let profile = self.profile {
            profile.updatePayloadSelection(selected: selected, payloadSource: payloadSource)
            if let payloadPlaceholder = self.selectedPayloadPlaceholder {
                self.updateSourceView(payloadPlaceholder: payloadPlaceholder)
            }
        }
    }
    
    func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey) {
        if let profile = self.profile {
            profile.updateViewSettings(value: value, key: key, subkey: subkey, payloadIndex: self.selectedPayloadIndex)
            self.reloadTableView(updateCellViews: true)
        }
    }
    
    func select(view: Int) {
        switch view {
        case EditorViewTag.profileCreator.rawValue:
            self.selectedPayloadView = .profileCreator
            
            guard self.scrollView.documentView != self.tableView else { return }
            
            if let selectedPayloadPlaceholder = self.selectedPayloadPlaceholder {
                self.showTabView(payloadPlaceholder: selectedPayloadPlaceholder)
            }
            self.reloadTableView(updateCellViews: true)
            self.scrollView.documentView = self.tableView
        case EditorViewTag.source.rawValue:
            self.selectedPayloadView = .source
            
            guard
                self.scrollView.documentView != self.textView,
                let selectedPayloadPlaceholder = self.selectedPayloadPlaceholder else { return }
            
            // ---------------------------------------------------------------------
            //  Hide tab bar if it's showing
            // ---------------------------------------------------------------------
            self.showTabView(false)
            
            // ---------------------------------------------------------------------
            //  Update source view
            // ---------------------------------------------------------------------
            self.updateSourceView(payloadPlaceholder: selectedPayloadPlaceholder)
            self.scrollView.documentView = self.textView
        default:
            Swift.print("Unknown View Tag: \(view)")
        }
    }
    
    func updateSourceView(payloadPlaceholder: PayloadPlaceholder) {
        guard let profile = self.profile else { return }
        
        let profileExport = ProfileExport(profile: profile)
        profileExport.ignoreErrorInvalidValue = true
        profileExport.ignoreSave = true
        
        var payloadContent = Dictionary<String, Any>()
        do {
            try profileExport.export(profile: profile,
                                     domain: payloadPlaceholder.domain,
                                     type: payloadPlaceholder.payloadSourceType,
                                     payloadIndex: self.selectedPayloadIndex,
                                     domainSettings: profile.getPayloadDomainSettings(domain: payloadPlaceholder.domain,
                                                                                      type: payloadPlaceholder.payloadSourceType,
                                                                                      payloadIndex: self.selectedPayloadIndex),
                                     typeSettings: profile.getPayloadTypeSettings(type: payloadPlaceholder.payloadSourceType),
                                     payloadContent: &payloadContent)
        } catch let error {
            Swift.print("Export failed: \(error)")
        }
        
        if !payloadContent.isEmpty {
            self.getPlistString(dictionary: payloadContent, completionHandler: { (string, error) in
                if let payloadString = string {
                    self.textView.string = payloadString
                    // self.textView.deleteToBeginningOfLine(nil)
                } else {
                    Swift.print("Error: \(String(describing: error))")
                    self.textView.string = ""
                }
            })
        } else {
            self.textView.string = ""
        }
    }
    
    func getPlistString(dictionary: Dictionary<String, Any>, completionHandler: @escaping (String?, Error?) -> Void) {
        
        // ---------------------------------------------------------------------
        //  Generate a temporary unique URL to write the dictionary to
        // ---------------------------------------------------------------------
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        // ---------------------------------------------------------------------
        //  Write the dictionary to a file at the temporary URL
        // ---------------------------------------------------------------------
        if #available(OSX 10.13, *) {
            do {
                try NSDictionary(dictionary: dictionary).write(to: tmpURL)
            } catch let error {
                // FIXME: Correct Error
                Swift.print("Failed to write: \(error)")
            }
        } else {
            if !NSDictionary(dictionary: dictionary).write(to: tmpURL, atomically: true) {
                // FIXME: Correct Error
            }
        }
        
        // ---------------------------------------------------------------------
        //  Read the contents of the file at the temporary URL
        // ---------------------------------------------------------------------
        var plistString: String?
        var plistError: Error?
        do {
            plistString = try String(contentsOf: tmpURL, encoding: .utf8)
        } catch let error {
            plistError = error
        }
        
        // ---------------------------------------------------------------------
        //  Remove the file at the temporary URL
        // ---------------------------------------------------------------------
        try? FileManager.default.removeItem(at: tmpURL)
        
        // ---------------------------------------------------------------------
        //  If file contents wasn't empty, then remove the plist header and ending tag
        // ---------------------------------------------------------------------
        if let string = plistString {
            
            // Create a scanner from the file contents
            let scanner = Scanner(string: string)
            var scannerString: NSString? = ""
            
            // Move to the first line containing '<dict>'
            scanner.scanUpTo("<dict>", into: nil)
            
            // Add all lines until a line contains '</plist>' to scannerString
            scanner.scanUpTo("</plist>", into: &scannerString)
            
            // If the scannerString is not empty, replace the plistString
            if scannerString?.length != 0 {
                plistString = scannerString as String?
            }
        }
        
        completionHandler(plistString, plistError)
    }
    
    func select(payloadPlaceholder: PayloadPlaceholder) {
        
        // ---------------------------------------------------------------------
        //  Only update selection if it's not currently selected
        // ---------------------------------------------------------------------
        if self.selectedPayloadPlaceholder != payloadPlaceholder {
            self.selectedPayloadPlaceholder = payloadPlaceholder
            
            // ---------------------------------------------------------------------
            //  Update header view
            // ---------------------------------------------------------------------
            self.headerView.select(payloadPlaceholder: payloadPlaceholder)
            
            if self.selectedPayloadView == .source {
                
                // ---------------------------------------------------------------------
                //  Hide tab bar if it's showing
                // ---------------------------------------------------------------------
                self.showTabView(false)
                
                // ---------------------------------------------------------------------
                //  Update source view with a xml representation of the payload(s)
                // ---------------------------------------------------------------------
                self.updateSourceView(payloadPlaceholder: payloadPlaceholder)
            } else {
                
                // ---------------------------------------------------------------------
                //  Show/Hide tab bar if more than one payload is selected
                // ---------------------------------------------------------------------
                self.showTabView(payloadPlaceholder: payloadPlaceholder)
                
                // ---------------------------------------------------------------------
                //  Reload all payload keys with updateCellVies so the current selection keys are shown
                // ---------------------------------------------------------------------
                self.reloadTableView(updateCellViews: true)
            }
        }
    }
    
    func showTabView(payloadPlaceholder: PayloadPlaceholder) {
        if !payloadPlaceholder.payloadSource.unique {
            if !self.editorView.subviews.contains(self.tabView) {
                self.showTabView(true)
            }
        } else {
            self.showTabView(false)
        }
    }
    
    func showTabView(_ show: Bool) {
        if show {
            self.editorView.addSubview(self.tabView)
            
            // Reconnect tableview
            NSLayoutConstraint.deactivate([self.constraintScrollViewTopSeparator])
            NSLayoutConstraint.activate([self.constraintScrollViewTopTab])
            
            // Add TabView
            NSLayoutConstraint.activate(self.constraintsTabView)
        } else {
            self.tabView.removeFromSuperview()
            
            // Reconnect tableview to top
            NSLayoutConstraint.deactivate([self.constraintScrollViewTopTab])
            NSLayoutConstraint.activate([self.constraintScrollViewTopSeparator])
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
            window.initialFirstResponder = firstCellView
            self.firstCellView = firstCellView
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
        
        let isEnabled = profile.isEnabled(subkey: subkey, onlyByUser: false, payloadIndex: self.selectedPayloadIndex)
        
        if !isEnabled {
            rowView.backgroundColor = .quaternaryLabelColor
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
        } else if tableColumn?.identifier == .tableColumnPayloadEnableLeading {
            if let cellView = self.cellViews[row] as? PayloadCellView, let subkey = cellView.subkey, let viewSettings = self.profile?.getViewTypeSettings(type: subkey.payloadSourceType) {
                return PayloadCellViewEnable(subkey: subkey, payloadIndex: self.selectedPayloadIndex, settings: viewSettings, editor: self)
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


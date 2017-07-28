//
//  ProfileEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-24.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileEditor: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    private let tableView = ProfileEditorTableView()
    public let scrollView = NSScrollView()
    
    fileprivate var payloadCellViews = [NSTableCellView]()
    fileprivate var editorWindow: NSWindow?
    
    private weak var profile: Profile?
    
    init(profile: Profile) {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        
        // ---------------------------------------------------------------------
        //  Setup TableView
        // ---------------------------------------------------------------------
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
        let tableColumnPaddingLeading = NSTableColumn(identifier: TableColumnIdentifier.paddingLeading)
        tableColumnPaddingLeading.isEditable = false
        tableColumnPaddingLeading.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingLeading.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingLeading)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Payload
        // ---------------------------------------------------------------------
        let tableColumnPayload = NSTableColumn(identifier: TableColumnIdentifier.payload)
        tableColumnPayload.isEditable = false
        tableColumnPayload.width = editorTableViewColumnPayloadWidth
        tableColumnPayload.minWidth = editorTableViewColumnPayloadWidth
        tableColumnPayload.maxWidth = editorTableViewColumnPayloadWidth
        self.tableView.addTableColumn(tableColumnPayload)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Trailing
        // ---------------------------------------------------------------------
        let tableColumnPaddingTrailing = NSTableColumn(identifier: TableColumnIdentifier.paddingTrailing)
        tableColumnPaddingTrailing.isEditable = false
        tableColumnPaddingTrailing.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingTrailing.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingTrailing)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView and add TableView as Document View
        // ---------------------------------------------------------------------
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.hasVerticalScroller = true
        self.scrollView.documentView = self.tableView
        // self.scrollView.autoresizesSubviews = true
        
        // Only For Testing
        self.payloadCellViews.append(PayloadCellViewTextField.init(key: "Test1", settings: [String : Any]()))
        self.payloadCellViews.append(PayloadCellViewTextField.init(key: "Test2", settings: [String : Any]()))
        self.payloadCellViews.append(PayloadCellViewTextField.init(key: "Test3", settings: [String : Any]()))
        
        self.reloadTableView(force: true)
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
    
    func reloadTableView(force: Bool = false) {
        // TODO: Implement
        self.tableView.reloadData()
    }
    
    func updateKeyViewLoop(window: NSWindow) {
        
        var previousCellView: PayloadCellView? = nil
        var firstCellView: PayloadCellView? = nil
        
        for (index, cellView) in self.payloadCellViews.enumerated() {
            guard let payloadCellView = cellView as? PayloadCellView else { continue }
            
            if payloadCellView.leadingKeyView != nil {
                if let previous = previousCellView {
                    previous.trailingKeyView!.nextKeyView = payloadCellView.leadingKeyView
                    
                    Swift.print("nextKeyView: \(String(describing: previous.trailingKeyView!.nextKeyView))")
                } else {
                    firstCellView = payloadCellView
                }
                previousCellView = payloadCellView
                
                if self.payloadCellViews.count == index + 1  {
                    tableView.nextKeyView = firstCellView?.leadingKeyView
                    payloadCellView.trailingKeyView!.nextKeyView = tableView
                    Swift.print("previousCellView.trailingKeyView!.nextKeyView: \(String(describing: payloadCellView.trailingKeyView!.nextKeyView))")
                }
            }
        }
        
        if firstCellView != nil {
            window.initialFirstResponder = firstCellView as? NSView
        }
    }
}

extension ProfileEditor: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.payloadCellViews.count
    }
}

extension ProfileEditor: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cellView = self.payloadCellViews[row] as? PayloadCellView {
            return cellView.height
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == TableColumnIdentifier.payload {
            // FIXME: Should only be needed once and NOT here
            self.updateKeyViewLoop(window: tableView.window!)
            return self.payloadCellViews[row]
        }
        return nil
    }
}

class PayloadTextField: NSTextField {
    override var acceptsFirstResponder : Bool { return self.isEditable }
    override var canBecomeKeyView: Bool { return self.isEditable }
}

class ProfileEditorTableView: NSTableView {
    override var acceptsFirstResponder: Bool { return false }
    override var canBecomeKeyView: Bool { return false }
}

// UNUSED
class ProfileEditorSplitView: NSSplitView {
    override var acceptsFirstResponder: Bool { return false }
    override var canBecomeKeyView: Bool { return false }
}

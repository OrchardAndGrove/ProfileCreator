//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTableView: NSTableCellView, ProfileCreatorCellView, PayloadCellView, TableViewCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var scrollView: NSScrollView?
    var tableView: NSTableView?
    var tableViewContent = [Dictionary<String, Any>]()
    var tableViewColumns = [PayloadSourceSubkey]()
    var valueDefault: String?
    let buttonAddRemove = NSSegmentedControl()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, settings: Dictionary<String, Any>) {
        
        self.subkey = subkey
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = subkey.title {
            self.textFieldTitle = EditorTextField.title(string: title, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self)
        }
        
        if let description = subkey.description {
            self.textFieldDescription = EditorTextField.description(string: description, constraints: &constraints, cellView: self)
        }
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.scrollView = EditorTableView.scrollView(string: "", constraints: &constraints, cellView: self)
        if let tableView = self.scrollView?.documentView as? NSTableView { self.tableView = tableView }
        addConstraintsFor(item: self.scrollView!, orientation: .below, constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup Table View Content
        // ---------------------------------------------------------------------
        setupTableViewContent(subkey: subkey)
        
        // ---------------------------------------------------------------------
        //  Setup Button
        // ---------------------------------------------------------------------
        setupButtonAddRemove(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.buttonAddRemove
        self.trailingKeyView = self.buttonAddRemove
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(3.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        self.tableView?.reloadData()
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    // MARK: -
    // MARK: Button Actions
    
    @objc private func clicked(_ segmentedControl: NSSegmentedControl) {
        
        if segmentedControl.selectedSegment == 0 { // Add
            self.addRow()
        } else if segmentedControl.selectedSegment == 1 { // Remove
            if let selectedRow = self.tableView?.selectedRow {
                self.removeRow(index: selectedRow)
            }
        }
    }
    
    // MARK: -
    // MARK: CellView Actions
    
    
    
    // MARK: -
    // MARK: Private Functions
    
    private func addRow() {
        var newRow = [String: Any]()
        for tableViewColumn in self.tableViewColumns {
            if tableViewColumn.type == .string {
                newRow[tableViewColumn.key] = tableViewColumn.valueDefault ?? ""
            } else {
                Swift.print("Unknown tableViewColumn.type: \(tableViewColumn.type)")
            }
        }
        
        // Only allow one "default" row when adding rows
        if let index = self.tableViewContent.index(where: {$0 as [AnyHashable : Any] == newRow as [AnyHashable : Any]}) {
            self.tableView?.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else {
            self.tableViewContent.append(newRow)
            self.tableView?.reloadData()
        }
    }
    
    private func removeRow(index: Int) {
        self.tableViewContent.remove(at: index)
        self.tableView?.removeRows(at: IndexSet(integer: index), withAnimation: .slideDown)
        
        let rowCount = self.tableViewContent.count
        if 0 < rowCount {
            if index < rowCount {
                self.tableView?.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            } else {
                self.tableView?.selectRowIndexes(IndexSet(integer: (rowCount - 1)), byExtendingSelection: false)
            }
        }
    }
    
    private func setupTableViewContent(subkey: PayloadSourceSubkey) {
        
        // FIXME: Highly temporary implementation
        if subkey.subkeys.count == 1, let tableViewSubkey = subkey.subkeys.first {
            if tableViewSubkey.type == PayloadValueType.dictionary {
                guard let tableView = self.tableView else { return }
                for tableViewColumnSubkey in tableViewSubkey.subkeys {
                    
                    self.tableViewColumns.append(tableViewColumnSubkey)
                    
                    // ---------------------------------------------------------------------
                    //  Setup TableColumn
                    // ---------------------------------------------------------------------
                    let tableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(tableViewColumnSubkey.key))
                    tableColumn.isEditable = true
                    tableColumn.title = tableViewColumnSubkey.key
                    tableColumn.headerToolTip = tableViewColumnSubkey.description
                    tableView.addTableColumn(tableColumn)
                }
                
                if tableViewSubkey.subkeys.count < 2 {
                    self.tableView?.headerView = nil
                }
            } else {
                Swift.print("Type is: \(tableViewSubkey.type), need to implement this!")
            }
        } else {
            Swift.print("Subkey count is: \(subkey.subkeys.count)")
            Swift.print("Unsure how to handle this, please investigate")
        }
    }
    
    // MARK: -
    // MARK: NSTextFieldDelegate Functions
    
    override func controlTextDidEndEditing(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Get current text in the text field
        // ---------------------------------------------------------------------
        guard
            let textField = notification.object as? NSTextField,
            let userInfo = notification.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let string = fieldEditor.textStorage?.string else {
                return
        }
        
        Swift.print("controlTextDidChange: \(string)")
        Swift.print("textField: \(textField)")
        Swift.print("row: \(textField.tag)")
        Swift.print("key: \(String(describing: textField.identifier?.rawValue))")
    }
    
    // MARK: -
    // MARK: NSLayoutConstraints
    
    private func setupButtonAddRemove(constraints: inout [NSLayoutConstraint]) {
        
        guard let scrollView = self.scrollView else { return }
        
        self.buttonAddRemove.translatesAutoresizingMaskIntoConstraints = false
        self.buttonAddRemove.segmentStyle = .smallSquare
        self.buttonAddRemove.segmentCount = 2
        self.buttonAddRemove.trackingMode = .momentary
        self.buttonAddRemove.setImage(NSImage(named: .addTemplate), forSegment: 0)
        self.buttonAddRemove.setImage(NSImage(named: .removeTemplate), forSegment: 1)
        self.buttonAddRemove.setEnabled(false, forSegment: 1)
        self.buttonAddRemove.action = #selector(clicked(_:))
        self.buttonAddRemove.target = self
        
        self.addSubview(self.buttonAddRemove)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.buttonAddRemove,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -1.0))
        
        self.updateHeight((8 + self.buttonAddRemove.intrinsicContentSize.height))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.buttonAddRemove,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
}

// Extension to compare Dictionaries
public func ==(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

extension PayloadCellViewTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { return self.tableViewContent.count }
}

extension PayloadCellViewTableView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { return 21.0 }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let tableViewColumn = self.tableViewColumns.first(where: {$0.key == tableColumn?.title}) {
            Swift.print("tableViewColumnvalueDefault: \(String(describing: tableViewColumn.valueDefault))")
            if tableViewColumn.type == .string {
                return EditorTableViewCellViewTextField(cellView: self, key: tableViewColumn.key, stringValue: "Test", placeholderString: "Placeholder", row: row)
            } else {
                Swift.print("Unknown tableViewColumn.type: \(tableViewColumn.type)")
            }
        } else {
            Swift.print("Found no table view column matching title: \(String(describing: tableColumn?.title))")
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView {
            self.buttonAddRemove.setEnabled((tableView.selectedRowIndexes.count) == 0 ? false : true, forSegment: 1)
        }
    }
}

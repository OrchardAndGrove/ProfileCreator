//
//  PayloadLibraryTableViews.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadLibraryTableViews: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let profilePayloadsTableView = NSTableView()
    let profilePayloadsScrollView = NSScrollView()
    var profilePayloads = [PayloadPlaceholder]()
    
    let libraryPayloadsTableView = NSTableView()
    let libraryPayloadsScrollView = NSScrollView()
    var libraryPayloads = [PayloadPlaceholder]()
    
    private let sortDescriptorTitle = NSSortDescriptor(key: "title", ascending: true)
    
    private var selectedPayloadPlaceholder: PayloadPlaceholder?
    
    override init() {
        super.init()
        
        self.setupProfilePayloads()
        self.setupLibraryPayloads()
        
        // Only For Testing
        self.profilePayloads.append(PayloadPlaceholder.init(payload: "General"))
        self.profilePayloads.append(PayloadPlaceholder.init(payload: "Mail"))
        
        self.libraryPayloads.append(PayloadPlaceholder.init(payload: "Facebook"))
        self.libraryPayloads.append(PayloadPlaceholder.init(payload: "Twitter"))
        
        self.reloadTableviews()
    }
    
    deinit {
        // ---------------------------------------------------------------------
        //  Remove self as DataSource and Delegate
        // ---------------------------------------------------------------------
        self.libraryPayloadsTableView.dataSource = nil
        self.profilePayloadsTableView.dataSource = nil
        self.libraryPayloadsTableView.delegate = nil
        self.profilePayloadsTableView.delegate = nil
    }
    
    private func reloadTableviews() {
        
        // ---------------------------------------------------------------------
        //  Sort both library and profile arrays alphabetically
        // ---------------------------------------------------------------------
        self.libraryPayloads.sort(sortDescriptors: [sortDescriptorTitle])
        self.profilePayloads.sort(sortDescriptors: [sortDescriptorTitle])
        
        // ---------------------------------------------------------------------
        //  Reload both table views
        // ---------------------------------------------------------------------
        self.profilePayloadsTableView.reloadData()
        self.libraryPayloadsTableView.reloadData()
        
        // -------------------------------------------------------------------------
        //  Check which table view holds the current selection, and mark it selected
        //  This is different from - (void)selectPlaceholder which also updates editor etc.
        // -------------------------------------------------------------------------
        if self.profilePayloads.contains(where: {$0 == self.selectedPayloadPlaceholder }) {
            
        } else if self.libraryPayloads.contains(where: {$0 == self.selectedPayloadPlaceholder}) {
            
        }
    }
    
    fileprivate func move(payloadPlaceholders: [PayloadPlaceholder], from: [PayloadPlaceholder], to: [PayloadPlaceholder]) {
        
    }
    
    fileprivate func select(payloadPlaceholder: PayloadPlaceholder, in: NSTableView) {
        
        // ---------------------------------------------------------------------
        //  Update stored selection with payloadPlaceholder
        // ---------------------------------------------------------------------
        self.selectedPayloadPlaceholder = payloadPlaceholder
        
        // FIXME: Implement
        Swift.print("Select: \(payloadPlaceholder)")
    }
    
    private func setupProfilePayloads() {
        
        // ---------------------------------------------------------------------
        //  Setup TableView
        // ---------------------------------------------------------------------
        self.profilePayloadsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.profilePayloadsTableView.focusRingType = .none
        self.profilePayloadsTableView.rowSizeStyle = .default
        self.profilePayloadsTableView.floatsGroupRows = false
        self.profilePayloadsTableView.headerView = nil
        self.profilePayloadsTableView.allowsMultipleSelection = false
        self.profilePayloadsTableView.tag = TableViewTag.profilePayloads.rawValue
        self.profilePayloadsTableView.intercellSpacing = NSSize(width: 0, height: 0)
        self.profilePayloadsTableView.register(forDraggedTypes: [DraggingType.payload])
        self.profilePayloadsTableView.dataSource = self
        self.profilePayloadsTableView.delegate = self
        self.profilePayloadsTableView.target = self
        self.profilePayloadsTableView.sizeLastColumnToFit()
        
        // ---------------------------------------------------------------------
        //  Setup TableColumn
        // ---------------------------------------------------------------------
        let tableColumn = NSTableColumn.init(identifier: TableColumnIdentifier.profilePayloads)
        tableColumn.isEditable = false
        self.profilePayloadsTableView.addTableColumn(tableColumn)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        self.profilePayloadsScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.profilePayloadsScrollView.documentView = self.profilePayloadsTableView
        self.profilePayloadsScrollView.hasVerticalScroller = false // FIXME: TRUE When added ios-style scrollers
        // self.profilePayloadsScrollView.autoresizesSubviews = true
    }
    
    private func setupLibraryPayloads() {
        
        // ---------------------------------------------------------------------
        //  Setup TableView
        // ---------------------------------------------------------------------
        self.libraryPayloadsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.libraryPayloadsTableView.focusRingType = .none
        self.libraryPayloadsTableView.rowSizeStyle = .default
        self.libraryPayloadsTableView.floatsGroupRows = false
        self.libraryPayloadsTableView.headerView = nil
        self.libraryPayloadsTableView.allowsMultipleSelection = false
        self.libraryPayloadsTableView.tag = TableViewTag.libraryPayloads.rawValue
        self.libraryPayloadsTableView.intercellSpacing = NSSize(width: 0, height: 0)
        self.libraryPayloadsTableView.register(forDraggedTypes: [DraggingType.payload])
        self.libraryPayloadsTableView.dataSource = self
        self.libraryPayloadsTableView.delegate = self
        self.libraryPayloadsTableView.target = self
        self.libraryPayloadsTableView.sizeLastColumnToFit()
        
        // ---------------------------------------------------------------------
        //  Setup TableColumn
        // ---------------------------------------------------------------------
        let tableColumn = NSTableColumn.init(identifier: TableColumnIdentifier.libraryPayloads)
        tableColumn.isEditable = false
        self.libraryPayloadsTableView.addTableColumn(tableColumn)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        self.libraryPayloadsScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.libraryPayloadsScrollView.documentView = self.libraryPayloadsTableView
        self.libraryPayloadsScrollView.hasVerticalScroller = false // FIXME: TRUE When added ios-style scrollers
        // self.profilePayloadsScrollView.autoresizesSubviews = true
    }
    
}

extension PayloadLibraryTableViews: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.tag == TableViewTag.profilePayloads.rawValue {
            return self.profilePayloads.count
        } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
            return self.libraryPayloads.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        
        if tableView.tag == TableViewTag.profilePayloads.rawValue && rowIndexes.contains(0) {
            
            // ---------------------------------------------------------------------
            //  Do not allow drag drop with General settings (at index 0)
            // ---------------------------------------------------------------------
            return false
        }
        
        var selectedPayloadPlaceholders = [PayloadPlaceholder]()
        if tableView.tag == TableViewTag.profilePayloads.rawValue {
            selectedPayloadPlaceholders = self.profilePayloads.objectsAtIndexes(indexes: rowIndexes)
        } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
            selectedPayloadPlaceholders = self.libraryPayloads.objectsAtIndexes(indexes: rowIndexes)
        }
        
        pboard.clearContents()
        pboard.declareTypes([DraggingType.payload], owner: nil)
        pboard.setData(NSKeyedArchiver.archivedData(withRootObject: selectedPayloadPlaceholders), forType: DraggingType.payload)
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if let infoSource = info.draggingSource() as? NSTableView, tableView == infoSource || dropOperation == NSTableViewDropOperation.on {
            return NSDragOperation(rawValue: 0)
        } else {
            tableView.setDropRow(-1, dropOperation: NSTableViewDropOperation.on)
            return NSDragOperation.copy
        }
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if let data = info.draggingPasteboard().data(forType: DraggingType.payload),
            let payloadPlaceholders = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PayloadPlaceholder] {
            if tableView.tag == TableViewTag.profilePayloads.rawValue {
                self.move(payloadPlaceholders: payloadPlaceholders, from: self.libraryPayloads, to: self.profilePayloads)
            } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
                self.move(payloadPlaceholders: payloadPlaceholders, from: self.profilePayloads, to: self.libraryPayloads)
            }
            return true
        }
        return false
    }
}

extension PayloadLibraryTableViews: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView.tag == TableViewTag.profilePayloads.rawValue {
            return 40
        } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
            return 32
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.tag == TableViewTag.profilePayloads.rawValue {
            return PayloadLibraryCellViewProfile(payloadPlaceholder: self.profilePayloads[row])
        } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
            return PayloadLibraryCellViewLibrary(payloadPlaceholder: self.libraryPayloads[row])
        }
        return nil
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        if 0 <= tableView.clickedRow {
            return true
        } else {
            if tableView.tag == TableViewTag.profilePayloads.rawValue {
                return 0 <= self.libraryPayloadsTableView.selectedRow
            } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
                return 0 <= self.profilePayloadsTableView.selectedRow
            }
            return true
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView,
            tableView.selectedRowIndexes.count != 0 {
            if tableView.tag == TableViewTag.profilePayloads.rawValue {
                self.libraryPayloadsTableView.deselectAll(self)
                self.select(payloadPlaceholder: self.profilePayloads[tableView.selectedRow], in: tableView)
            } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
                self.profilePayloadsTableView.deselectAll(self)
                self.select(payloadPlaceholder: self.libraryPayloads[tableView.selectedRow], in: tableView)
            }
        }
    }
}

extension PayloadLibraryTableViews: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.copy
    }
}

extension PayloadLibraryTableViews: NSDraggingDestination {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        // FIXME - Here forcing a focus ring would fit, haven't looked into how to yet.
        return NSDragOperation.copy
    }
    
    // Is this neccessary?
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    // Why is this only from profile to library?
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        Swift.print("performDragOperation: \(sender)")
        if let data = sender.draggingPasteboard().data(forType: DraggingType.payload),
            let payloadPlaceholders = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PayloadPlaceholder] {
            self.move(payloadPlaceholders: payloadPlaceholders, from: self.profilePayloads, to: self.libraryPayloads)
        }
        return false
    }
}

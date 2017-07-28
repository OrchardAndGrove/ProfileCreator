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
    var profilePayloads = [String]()
    
    let libraryPayloadsTableView = NSTableView()
    let libraryPayloadsScrollView = NSScrollView()
    var libraryPayloads = [String]()
    
    override init() {
        super.init()
        
        self.setupProfilePayloads()
        self.setupLibraryPayloads()
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
        self.profilePayloadsScrollView.hasVerticalScroller = true
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
        self.libraryPayloadsScrollView.hasVerticalScroller = true
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
}

extension PayloadLibraryTableViews: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
}

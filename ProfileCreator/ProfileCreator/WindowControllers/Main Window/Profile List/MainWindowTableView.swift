//
//  MainWindowTableView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-08.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowTableViewController: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let tableView = MainWindowTableView()
    let scrollView = NSScrollView()
    
    // MARK: -
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Table Column
        // ---------------------------------------------------------------------
        let tableColumn = NSTableColumn(identifier: "MainWindowTableViewTableColumn")
        tableColumn.isEditable = false
        
        // ---------------------------------------------------------------------
        //  Setup TableView
        // ---------------------------------------------------------------------
        self.tableView.addTableColumn(tableColumn)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.sizeLastColumnToFit()
        self.tableView.floatsGroupRows = false
        self.tableView.rowSizeStyle = .default
        self.tableView.headerView = nil
        // self.tableView.dataSource = self
        // self.tableView.delegate = self
        self.tableView.target = self
        self.tableView.doubleAction = #selector(editProfile(tableView:))
        self.tableView.allowsMultipleSelection = true
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        self.scrollView.documentView = self.tableView
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.autoresizesSubviews = true
    }
    
    // MARK: -
    // MARK: TableView Actions
    
    func editProfile(tableView: NSTableView) {
        print("editProfile")
    }
}

extension MainWindowTableViewController: NSTableViewDelegate {
    
}

extension MainWindowTableViewController: NSTableViewDataSource {
    
}

class MainWindowTableView: NSTableView {
    
    // -------------------------------------------------------------------------
    //  Override keyDown to catch backspace to delete item in table view
    // -------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            Swift.print("DELETE!")
            if 0 < self.selectedRowIndexes.count && self.delegate != nil  { // , let delegateMethod = shouldRemoveItemsAtIndexes
                // TODO: Call Delegate
            }
        }
        super.keyDown(with: event)
    }
}

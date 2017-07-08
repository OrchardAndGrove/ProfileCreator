//
//  MainWindowOutlineView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-08.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

struct DraggingType {
    static let profile = "Profile"
}

class MainWindowOutlineViewController: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let outlineView = MainWindowOutlineView()
    let scrollView = NSScrollView()

    // MARK: -
    // MARK: Initialization
    
    override init() {
        super.init()
        
        let tableColumn = NSTableColumn(identifier: "MainWindowOutlineViewTableColumn")
        tableColumn.isEditable = true
        
        self.outlineView.addTableColumn(tableColumn)
        self.outlineView.translatesAutoresizingMaskIntoConstraints = false
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.sizeLastColumnToFit()
        self.outlineView.floatsGroupRows = false
        self.outlineView.rowSizeStyle = .default
        self.outlineView.headerView = nil
        //self.outlineView.dataSource = self
        //self.outlineView.delegate = self
        self.outlineView.register(forDraggedTypes: [DraggingType.profile])
        
        self.scrollView.documentView = self.outlineView
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.autoresizesSubviews = true
    }
}


extension MainWindowOutlineViewController: NSOutlineViewDelegate {
    
}

extension MainWindowOutlineViewController: NSOutlineViewDataSource {
    
}

class MainWindowOutlineView: NSOutlineView {
    
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

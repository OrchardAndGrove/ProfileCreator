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
    var parents = [OutlineViewParentItem]()
    var allProfilesGroup: MainWindowAllProfilesGroup?

    // MARK: -
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(didAddGroup(_:)), name: .didAddGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddProfile(_:)), name: .didAddProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSaveProfile(_:)), name: .didSaveProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveProfile(_:)), name: .didRemoveProfile, object: nil)
        
        // ---------------------------------------------------------------------
        //  Setup Table Column
        // ---------------------------------------------------------------------
        let tableColumn = NSTableColumn(identifier: "MainWindowOutlineViewTableColumn")
        tableColumn.isEditable = true
        
        // ---------------------------------------------------------------------
        //  Setup OutlineView
        // ---------------------------------------------------------------------
        self.outlineView.addTableColumn(tableColumn)
        self.outlineView.translatesAutoresizingMaskIntoConstraints = false
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.sizeLastColumnToFit()
        self.outlineView.floatsGroupRows = false
        self.outlineView.rowSizeStyle = .default
        self.outlineView.headerView = nil
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.register(forDraggedTypes: [DraggingType.profile])
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        self.scrollView.documentView = self.outlineView
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.autoresizesSubviews = true
        
        // ---------------------------------------------------------------------
        //  Add all parent views to outline view
        // ---------------------------------------------------------------------
        addParents()
        
        // ---------------------------------------------------------------------
        //  Expand the first two parents (All Profiles & Library which can't show/hide later)
        // ---------------------------------------------------------------------
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current().duration = 0
        self.outlineView.expandItem(self.parents[0], expandChildren: false)
        NSAnimationContext.endGrouping()
        
        // ---------------------------------------------------------------------
        //  Select "All Profiles"
        // ---------------------------------------------------------------------
        self.outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didAddGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didAddProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSaveProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didRemoveProfile, object: nil)
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func addParents() {
        
        // ---------------------------------------------------------------------
        //  Add parent item: "All Profiles"
        // ---------------------------------------------------------------------
        let allProfiles = MainWindowAllProfiles()
        self.parents.append(allProfiles)
        
        // ---------------------------------------------------------------------
        //  Store the "All Profiles" group in it's own instance variable for future use
        // ---------------------------------------------------------------------
        if let allProfilesGroup = allProfiles.children.first as? MainWindowAllProfilesGroup {
            self.allProfilesGroup = allProfilesGroup
        }
        
        // ---------------------------------------------------------------------
        //  Add parent item: "Library"
        // ---------------------------------------------------------------------
        let library = MainWindowLibrary()
        self.parents.append(library)
        
        // TODO: - Add more parent groups here like:
        //         JSS/MDM Profiles
        //         Local Profiles
        
        // ---------------------------------------------------------------------
        //  Reload the outline view after adding items
        // ---------------------------------------------------------------------
        reloadOutlineView()
    }
    
    
    // -------------------------------------------------------------------------
    //  Convenience method to reaload data in outline view and keep current selection
    // -------------------------------------------------------------------------
    private func reloadOutlineView() {
        let selectedRowIndexes = self.outlineView.selectedRowIndexes
        self.outlineView.reloadData()
        self.outlineView.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    func didAddGroup(_ notification: NSNotification?) {
        
        // ---------------------------------------------------------------------
        //  Reload outline view if sender was any of the outline view parents
        // ---------------------------------------------------------------------
        guard let sender = notification?.object as? OutlineViewParentItem else {
            return
        }
        
        // Only checking titles is weak, but as the protocol doesn't support equatable, this will do
        if self.parents.contains(where: { $0.title == sender.title }) {
            reloadOutlineView()
            
            // -----------------------------------------------------------------
            //  If the parent the group was added to isn't expanded, expand it
            // -----------------------------------------------------------------
            if !self.outlineView.isItemExpanded(sender) {
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current().duration = 0
                self.outlineView.expandItem(sender)
                NSAnimationContext.endGrouping()
            }
            
            // -----------------------------------------------------------------
            //  Selecte the user added group
            // -----------------------------------------------------------------
            guard let userInfo = notification?.userInfo,
                  let group = userInfo[SidebarGroupKey.group] as? OutlineViewChildItem else {
                    return
            }
            
            let row = self.outlineView.row(forItem: group)
            if 0 <= row {
                self.outlineView.selectRowIndexes(IndexSet.init(integer: row), byExtendingSelection: false)
            }
        }
    }
    
    func didAddProfile(_ notification: NSNotification?) {
        print("didAddProfile")
    }
    
    func didSaveProfile(_ notification: NSNotification?) {
        
        // ---------------------------------------------------------------------
        //  Reload outline view when a profile was saved
        // ---------------------------------------------------------------------
        print("didSaveProfile")
        reloadOutlineView()
    }
    
    func didRemoveProfile(_ notification: NSNotification?) {
        
        // ---------------------------------------------------------------------
        //  Reload outline view when a profile was removed
        // ---------------------------------------------------------------------
        print("didRemoveProfile")
        reloadOutlineView()
    }
}

extension MainWindowOutlineViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return (item == nil) ? self.parents.count : (item as! OutlineViewItem).children.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return (item == nil) ? self.parents[index] : (item as! OutlineViewItem).children[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is OutlineViewParentItem ? true : (item as! OutlineViewItem).children.count != 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if tableColumn?.identifier == "MainWindowOutlineViewTableColumn", let outlineViewItem = item as? OutlineViewItem {
            return outlineViewItem.title
        }
        return "-"
    }
    
    // -------------------------------------------------------------------------
    //  Drag/Drop Support
    // -------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        if (item as! OutlineViewItem).isEditable {
            return (info.draggingSourceOperationMask() == NSDragOperation.copy ? NSDragOperation.copy : NSDragOperation.move)
        }
        return NSDragOperation()
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard let draggingData = info.draggingPasteboard().data(forType: DraggingType.profile) else {
            return false
        }
        
        guard let profileIdentifiers = NSKeyedUnarchiver.unarchiveObject(with: draggingData) as? [UUID] else {
            return false
        }
        
        if let outlineViewChildItem = item as? OutlineViewChildItem {
            outlineViewChildItem.addProfiles(identifiers: profileIdentifiers)
            return true
        }
        
        return false
    }
}

extension MainWindowOutlineViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        
        // ---------------------------------------------------------------------
        //  Returns true for all OutlineViewParentItems
        // ---------------------------------------------------------------------
        return item is OutlineViewParentItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        // ---------------------------------------------------------------------
        //  Returns true for all OutlineViewParentItems
        // ---------------------------------------------------------------------
        return item is OutlineViewChildItem
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        // TODO: Implement
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        // TODO: Implement
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        // TODO: Implement
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let parent = item as? OutlineViewParentItem {
            return parent.cellView
        } else if let child = item as? OutlineViewChildItem {
            return child.cellView
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is MainWindowAllProfiles {
            
            // ------------------------------------------------------------------
            //  Ugly fix to hide the AllProfiles parent view, setting it's height to 0
            // -----------------------------------------------------------------
            return 0
        } else if item is OutlineViewParentItem {
            return 18
        }
        return 22
    }
}

class MainWindowOutlineView: NSOutlineView {
    
    // -------------------------------------------------------------------------
    //  Override keyDown to catch backspace to delete item in outline view
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

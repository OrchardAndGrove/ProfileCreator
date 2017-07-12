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

protocol MainWindowOutlineViewSelectionDelegate: class {
    func selected(item: OutlineViewChildItem, sender: Any?)
}

class MainWindowOutlineViewController: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let outlineView = MainWindowOutlineView()
    let scrollView = NSScrollView()
    
    var alert: Alert?
    var selectedItem: MainWindowLibraryGroup?
    var parents = [OutlineViewParentItem]()
    var allProfilesGroup: MainWindowAllProfilesGroup?
    
    weak var selectionDelegate: MainWindowOutlineViewSelectionDelegate?
    
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
        self.outlineView.expandItem(self.parents[1], expandChildren: false)
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
    
    func removeItems(atIndexes: IndexSet) {
        
        var firstItemParent: OutlineViewParentItem?
        var itemsToRemove = [OutlineViewChildItem]()
        
        // ---------------------------------------------------------------------
        //  Get all group instances to remove
        // ---------------------------------------------------------------------
        for row in atIndexes {
            if let group = self.outlineView.item(atRow: row) as? OutlineViewChildItem {
                if firstItemParent == nil, let parent = self.outlineView.parent(forItem: group) as? OutlineViewParentItem {
                    firstItemParent = parent
                }
                itemsToRemove.append(group)
            }
        }
        
        // ---------------------------------------------------------------------
        //  Verify a valid parent was found, else there will be inconsistencies after delete
        // ---------------------------------------------------------------------
        if let parent = firstItemParent {
            
            // -----------------------------------------------------------------
            //  Try to remove each group
            // -----------------------------------------------------------------
            for group in itemsToRemove {
                let (removed, error) = group.removeFromDisk()
                if removed {
                    if let selectedItem = self.selectedItem, group.title == selectedItem.title {
                        self.selectedItem = nil
                    }
                    
                    if let index = parent.children.index(where: {$0.title == group.title}) {
                        parent.children.remove(at: index)
                    }
                } else {
                    // TODO: Proper logging
                    Swift.print("error: \(String(describing: error))")
                }
            }
            
            self.reloadOutlineView()
        }
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
            //  Select the user added group
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
        //  Returns true for all OutlineViewChildItems
        // ---------------------------------------------------------------------
        return item is OutlineViewChildItem
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Updates internal selection state and notifies delegate of the new selection
        // ---------------------------------------------------------------------
        let selectedRowIndexes = self.outlineView.selectedRowIndexes
        if 0 < selectedRowIndexes.count {
            
            // -----------------------------------------------------------------
            //  Assumes MainWindowLibraryGroup and that only one selection is possible.
            //  This might change in a future release and need update
            // -----------------------------------------------------------------
            if let selectedItem = self.outlineView.item(atRow: selectedRowIndexes.first!) as? MainWindowLibraryGroup  {
                self.selectedItem = selectedItem
                
                // -------------------------------------------------------------
                //  Pass the selected item to the selectionDelegate (if it's set)
                // -------------------------------------------------------------
                if let delegateMethod = self.selectionDelegate?.selected {
                    delegateMethod(selectedItem, self)
                }
            }
        }
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        // TODO: Implement
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        if item is MainWindowLibrary {
            return false
        }
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

extension MainWindowOutlineViewController: MainWindowOutlineViewDelegate {
    
    func shouldRemoveItems(atIndexes: IndexSet) {
        
        // ---------------------------------------------------------------------
        //  Verify there is a mainWindow present
        // ---------------------------------------------------------------------
        guard let mainWindow = NSApplication.shared().mainWindow  else {
            return
        }
        
        // ---------------------------------------------------------------------
        //  Create the alert message depending on how may groups were selected
        //  Currently only one is allowed to be selected, that might change in a future release.
        // ---------------------------------------------------------------------
        var alertMessage: String?
        
        if atIndexes.count == 1 {
            guard let row = atIndexes.first,
                let item = self.outlineView.item(atRow: row) as? OutlineViewChildItem,
                !item.isEditing else {
                    return
            }
            
            alertMessage = NSLocalizedString("Are you sure you want to delete the group: \"\(item.title)\"", comment: "")
        } else {
            alertMessage = NSLocalizedString("Are you sure you want to delete the following groups:\n", comment: "")
            for row in atIndexes {
                guard let item = self.outlineView.item(atRow: row) as? OutlineViewChildItem,
                    !item.isEditing else {
                        return
                }
                
                alertMessage = alertMessage! + "\t\(item.title)\n"
            }
        }
        
        let alertInformativeText = NSLocalizedString("No profile will be removed.", comment: "")
        
        // ---------------------------------------------------------------------
        //  Show remove group alert to user
        // ---------------------------------------------------------------------
        self.alert = Alert()
        self.alert?.showAlertDelete(message: alertMessage!, informativeText: alertInformativeText, window: mainWindow, shouldDelete: { (delete) in
            if delete {
                self.removeItems(atIndexes: atIndexes)
            }
        })
        
    }
    
}

protocol MainWindowOutlineViewDelegate {
    func shouldRemoveItems(atIndexes: IndexSet)
}

class MainWindowOutlineView: NSOutlineView {
    
    // MARK: -
    // MARK: Variables
    
    var clickedItem: MainWindowLibraryGroup?
    var clickedItemRow: Int = -1
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: NSZeroRect)
    }
    
    // -------------------------------------------------------------------------
    //  Override keyDown to catch backspace to delete group in outline view
    // -------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            self.removeSelectedGroups(self)
        }
        super.keyDown(with: event)
    }
    
    // -------------------------------------------------------------------------
    //  Override menu(for event:) to show a contextual menu
    // -------------------------------------------------------------------------
    override func menu(for event: NSEvent) -> NSMenu? {
        
        // ---------------------------------------------------------------------
        //  Get row that was clicked
        // ---------------------------------------------------------------------
        let point = self.convert(event.locationInWindow, from: nil)
        self.clickedItemRow = self.row(at: point)
        if ( self.clickedItemRow == -1 || self.level(forRow: self.clickedItemRow) != 1 ) {
            return nil
        }
        
        // ---------------------------------------------------------------------
        //  Verify a MainWindowLibraryGroup was clicked, else don't return a menu
        // ---------------------------------------------------------------------
        guard let item = self.item(atRow: self.clickedItemRow) as? MainWindowLibraryGroup else {
            return nil
        }
        
        self.clickedItem = item
        
        // ---------------------------------------------------------------------
        //  Create menu
        // ---------------------------------------------------------------------
        let menu = NSMenu()
        
        // ---------------------------------------------------------------------
        //  Add item: "Rename"
        // ---------------------------------------------------------------------
        let menuItemRename = NSMenuItem()
        menuItemRename.title = NSLocalizedString("Rename \"\(item.title)\"", comment: "")
        menuItemRename.isEnabled = true
        menuItemRename.target = self
        menuItemRename.action = #selector(editGroup)
        menu.addItem(menuItemRename)
        
        // ---------------------------------------------------------------------
        //  Add item: "Delete"
        // ---------------------------------------------------------------------
        let menuItemDelete = NSMenuItem()
        menuItemDelete.title = NSLocalizedString("Delete", comment: "")
        menuItemDelete.isEnabled = true
        menuItemDelete.target = self
        menuItemDelete.action = #selector(removeSelectedGroups(_:))
        menu.addItem(menuItemDelete)
        
        // ---------------------------------------------------------------------
        //  Return menu
        // ---------------------------------------------------------------------
        return menu
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        // ---------------------------------------------------------------------
        //  Only enable "Rename" for editable items
        //  This is currently not neccessary, but might be needed in a future release
        // ---------------------------------------------------------------------
        if let item = self.clickedItem {
            return item.isEditable
        }
        return false
    }
    
    func editGroup() {
        
        // ---------------------------------------------------------------------
        //  Set the group in editing mode
        // ---------------------------------------------------------------------
        if self.clickedItemRow != -1 {
            self.selectRowIndexes(IndexSet.init(integer: self.clickedItemRow), byExtendingSelection: false)
            self.editColumn(0, row: self.clickedItemRow, with: nil, select: true)
        }
    }
    
    func removeSelectedGroups(_ sender: Any?) {
        
        // ---------------------------------------------------------------------
        //  Verify the delegate is set and is a MainWindowOutlineViewDelegate
        //  Depending on who is calling the function, get the selected items separately
        // ---------------------------------------------------------------------
        if let delegate = self.delegate as? MainWindowOutlineViewDelegate {
            if sender is NSMenuItem, self.clickedItem != nil, self.clickedItemRow != -1 {
                delegate.shouldRemoveItems(atIndexes: IndexSet(integer: self.clickedItemRow))
            } else if sender is MainWindowOutlineView, 0 < self.selectedRowIndexes.count {
                delegate.shouldRemoveItems(atIndexes: self.selectedRowIndexes)
            }
        }
    }
}

extension MainWindowOutlineView: NSMenuDelegate {
    
    func menuDidClose(_ menu: NSMenu) {
        
        // ---------------------------------------------------------------------
        //  Reset variables set when menu was created
        // ---------------------------------------------------------------------
        self.clickedItem = nil
        self.clickedItemRow = -1
    }
    
}

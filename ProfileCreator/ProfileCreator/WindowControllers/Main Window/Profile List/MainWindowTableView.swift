//
//  MainWindowTableView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-08.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

// MARK: -
// MARK: Protocols
// MAKR: -

protocol MainWindowTableViewDelegate: class {
    func shouldRemoveItems(atIndexes: IndexSet)
    func profileIdentifier(atRow: Int) -> UUID?
}

// MARK: -
// MARK: Classes
// MAKR: -

class MainWindowTableViewController: NSObject, MainWindowOutlineViewSelectionDelegate, MainWindowTableViewDelegate {
    
    // MARK: -
    // MARK: Variables
    
    let tableView = MainWindowTableView()
    let cellView = MainWindowTableViewCellView()
    let scrollView = NSScrollView()
    
    var selectedProfileGroup: OutlineViewChildItem?
    var selectedProfileIdentitifers: [UUID]?
    
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
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.floatsGroupRows = false
        self.tableView.rowSizeStyle = .default
        self.tableView.headerView = nil
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.target = self
        self.tableView.doubleAction = #selector(editProfile(tableView:))
        self.tableView.allowsMultipleSelection = true
        
        // Things I've tried to remove the separator between the views in the outline view
        /*
         self.tableView.gridColor = NSColor.clear
         self.tableView.gridStyleMask = NSTableViewGridLineStyle.init(rawValue: 0)
         self.tableView.intercellSpacing = NSZeroSize
         */
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        self.scrollView.documentView = self.tableView
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.autoresizesSubviews = true
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveProfile(_:)), name: .didRemoveProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSaveProfile(_:)), name: .didSaveProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exportProfile(_:)), name: .exportProfile, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didRemoveProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSaveProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .exportProfile, object: nil)
    }
    
    // MARK: -
    // MARK: MainWindowOutlineViewDelegate Functions
    
    func selected(item: OutlineViewChildItem, sender: Any?) {
        Swift.print("selectedItem: \(item)")
        self.selectedProfileGroup = item
        reloadTableView()
    }
    
    func updated(item: OutlineViewChildItem, sender: Any?) {
        Swift.print("updatedItem: \(item)")
        // TODO: Another weak check using the title because it isn't equatable
        if let selectedProfileGroup = self.selectedProfileGroup, selectedProfileGroup.title == item.title {
            reloadTableView()
        }
    }

    
    // MARK: -
    // MARK: TableView Actions
    
    func editProfile(tableView: NSTableView) {
        print("editProfile")
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    func didRemoveProfile(_ notification: NSNotification) {
        Swift.print("didRemoveProfiles")
    }
    
    func exportProfile(_ notification: NSNotification) {
        Swift.print("exportProfile")
    }
    
    func didSaveProfile(_ notification: NSNotification) {
        reloadTableView()
    }
    
    // -------------------------------------------------------------------------
    //  Convenience method to reaload data in table view and keep current selection
    // -------------------------------------------------------------------------
    func reloadTableView() {
        let selectedRowIndexes = self.tableView.selectedRowIndexes
        self.tableView.reloadData()
        self.tableView.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
    
    func removeItems(atIndexes: IndexSet) {
        if let selectedProfileGroup = self.selectedProfileGroup {
            selectedProfileGroup.removeProfiles(atIndexes: atIndexes)
        }
    }
    
    func shouldRemoveItems(atIndexes: IndexSet) {
        Swift.print("shouldRemoveItems: \(atIndexes)")
    }
    
    func profileIdentifier(atRow: Int) -> UUID? {
        if let selectedProfileGroup = self.selectedProfileGroup, atRow < selectedProfileGroup.profileIdentifiers.count {
            return selectedProfileGroup.profileIdentifiers[atRow]
        }
        return nil
    }
}

extension MainWindowTableViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let selectedProfileGroup = self.selectedProfileGroup {
            return selectedProfileGroup.profileIdentifiers.count
        }
        return 0
    }
    
    // -------------------------------------------------------------------------
    //  Drag/Drop Support
    // -------------------------------------------------------------------------
    
    func tableView(_ tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        if let draggingData = draggingInfo.draggingPasteboard().data(forType: DraggingType.profile),
           let profileIdentifiers = NSKeyedUnarchiver.unarchiveObject(with: draggingData) as? [UUID] {
            draggingInfo.numberOfValidItemsForDrop = profileIdentifiers.count
        }
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        guard let profileIdentifiers = self.selectedProfileGroup?.profileIdentifiers as NSArray? else {
            return false
        }
        
        pboard.clearContents()
        pboard.declareTypes([DraggingType.profile], owner: nil)
        pboard.setData(NSKeyedArchiver.archivedData(withRootObject: profileIdentifiers.objects(at: rowIndexes)), forType: DraggingType.profile)
        return true
    }
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        if operation == .move {
            
            // -----------------------------------------------------------------
            //  Verify a group is selected and editable (as we are remove items from this group)
            // -----------------------------------------------------------------
            guard let selectedProfileGroup = self.selectedProfileGroup, selectedProfileGroup.isEditable else {
                return
            }
            
            // -----------------------------------------------------------------
            //  Verify a valid profile identifier array is passed
            // -----------------------------------------------------------------
            guard let draggingData = session.draggingPasteboard.data(forType: DraggingType.profile),
                let profileIdentifiers = NSKeyedUnarchiver.unarchiveObject(with: draggingData) as? [UUID] else {
                    return
            }
            
            // -----------------------------------------------------------------
            //  Get the index of the last profile in the passed array
            // -----------------------------------------------------------------
            guard let lastProfileUUID = profileIdentifiers.last, let lastProfileIndex = selectedProfileGroup.profileIdentifiers.index(of: lastProfileUUID) else {
                return
            }
            
            // -----------------------------------------------------------------
            //  Remove the passed profile identifiers from the current group
            // -----------------------------------------------------------------
            selectedProfileGroup.removeProfiles(identifiers: profileIdentifiers)
            
            // -----------------------------------------------------------------
            //  !! Do not call the custom method reloadTableView() here !!
            //  Use the default method to be able to make a nice selection transition
            // -----------------------------------------------------------------
            self.tableView.reloadData()
            
            // -----------------------------------------------------------------
            //  Select a new profile after passed profiles were deleted
            // -----------------------------------------------------------------
            let newIndex = (lastProfileIndex - profileIdentifiers.count)
            if 0 < newIndex {
                self.tableView.selectRowIndexes(IndexSet(integer: newIndex), byExtendingSelection: false)
            } else {
                self.tableViewSelectionDidChange(Notification(name: .emptyNotification))
            }
        }
    }
}

extension MainWindowTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let selectedProfileGroup = self.selectedProfileGroup, row < selectedProfileGroup.profileIdentifiers.count else {
            return nil
        }
        
        // TODO: Implement when profile controller exists
        // let identifier = selectedProfileGroup.profileIdentifiers[row]
        // let profile = ...
        let profile = "Profile"
        
        // TODO: Implement when profile export exists
        let payloadSettings = 1
        
        let profileName = !profile.isEmpty ? profile : StringConstant.defaultProfileName
        let profileUUID = UUID()
        
        return self.cellView.cellView(title: profileName, identifier: profileUUID, payloadCount: payloadSettings, errorCount: 0)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let profileIdentifiers = self.selectedProfileGroup?.profileIdentifiers as NSArray?,
            let selectedProfileIdentifiers = profileIdentifiers.objects(at: self.tableView.selectedRowIndexes) as? [UUID] else {
            return
        }
        
        self.selectedProfileIdentitifers = selectedProfileIdentifiers
        NotificationCenter.default.post(name: .didChangeProfileSelection, object: self, userInfo: ["ProfileIdentifiers" : selectedProfileIdentifiers, "IndexSet" : self.tableView.selectedRowIndexes])
    }
}

class MainWindowTableView: NSTableView {
    
    // MARK: -
    // MARK: Variables
    
    var clickedProfile: UUID?
    var clickedProfileRow: Int = -1
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: NSZeroRect)
    }
    
    // -------------------------------------------------------------------------
    //  Override menu(for event:) to show a contextual menu
    // -------------------------------------------------------------------------
    override func menu(for event: NSEvent) -> NSMenu? {
        
        // ---------------------------------------------------------------------
        //  Get row that was clicked
        // ---------------------------------------------------------------------
        let point = self.convert(event.locationInWindow, from: nil)
        self.clickedProfileRow = self.row(at: point)
        if self.clickedProfileRow == -1 {
            return nil
        }
        
        // ---------------------------------------------------------------------
        //  Verify a MainWindowLibraryGroup was clicked, else don't return a menu
        // ---------------------------------------------------------------------
        guard let delegate = self.delegate as? MainWindowTableViewDelegate,
            let clickedProfileIdentifier = delegate.profileIdentifier(atRow: self.clickedProfileRow) else {
            return nil
        }
        
        self.clickedProfile = clickedProfileIdentifier
        let selectedRowIndexes = self.selectedRowIndexes
        
        /*
         TODO: Here I wanted to draw the blue focus ring around the views affected by the right click action.
               It should do that by defaut (?) but doesn't. I haven't found a good way to force that either.
         
        if let clickedView = self.rowView(atRow: self.clickedProfileRow, makeIfNecessary: false) {
            clickedView.focusRingType = .exterior
            Swift.print("clickedView: \(clickedView)")
        }
        */
        
        // ---------------------------------------------------------------------
        //  Create menu
        // ---------------------------------------------------------------------
        let menu = NSMenu()
        
        // ---------------------------------------------------------------------
        //  Add item: "Edit"
        // ---------------------------------------------------------------------
        let menuItemRename = NSMenuItem()
        menuItemRename.title = NSLocalizedString("Edit \"\(clickedProfileIdentifier.uuidString)\"", comment: "")
        menuItemRename.isEnabled = true
        menuItemRename.target = self
        menuItemRename.action = #selector(editProfile(_:))
        menu.addItem(menuItemRename)
        
        // ---------------------------------------------------------------------
        //  Add item: "Delete"
        // ---------------------------------------------------------------------
        var deleteString: String
        if 1 < selectedRowIndexes.count, selectedRowIndexes.contains(self.clickedProfileRow) {
            deleteString = NSLocalizedString("Delete \(selectedRowIndexes.count) Profiles", comment: "")
        } else {
            deleteString = NSLocalizedString("Delete", comment: "")
        }
        
        let menuItemDelete = NSMenuItem()
        menuItemDelete.title = deleteString
        menuItemDelete.isEnabled = true
        menuItemDelete.target = self
        menuItemDelete.action = #selector(removeSelectedProfiles(_:))
        menu.addItem(menuItemDelete)
        
        // ---------------------------------------------------------------------
        //  Return menu
        // ---------------------------------------------------------------------
        return menu
    }
    
    // -------------------------------------------------------------------------
    //  Override keyDown to catch backspace to delete item in table view
    // -------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            if let delegate = self.delegate as? MainWindowTableViewDelegate, 0 < self.selectedRowIndexes.count {
                delegate.shouldRemoveItems(atIndexes: self.selectedRowIndexes)
            }
        }
        super.keyDown(with: event)
    }
    
    func editProfile(_ sender: NSTableView?) {
        Swift.print("editProfiles")
    }
    
    func removeSelectedProfiles(_ sender: Any?) {

        // ---------------------------------------------------------------------
        //  Verify the delegate is set and is a MainWindowTableViewDelegate
        //  Depending on who is calling the function, get the selected items separately
        // ---------------------------------------------------------------------
        if let delegate = self.delegate as? MainWindowTableViewDelegate {
            if self.clickedProfile != nil, self.clickedProfileRow != -1 {
                delegate.shouldRemoveItems(atIndexes: IndexSet(integer: self.clickedProfileRow))
            }
        }
    }
}

extension MainWindowTableView: NSMenuDelegate {
    
    func menuDidClose(_ menu: NSMenu) {
        
        // ---------------------------------------------------------------------
        //  Reset variables set when menu was created
        // ---------------------------------------------------------------------
        self.clickedProfile = nil
        self.clickedProfileRow = -1
    }
    
}

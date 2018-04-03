//
//  PayloadLibraryTableViews.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadLibraryTableViews: NSObject, PayloadLibrarySelectionDelegate {
    
    // MARK: -
    // MARK: Variables
    
    let profilePayloadsTableView = NSTableView()
    let profilePayloadsScrollView = NSScrollView()
    var profilePayloads = [PayloadPlaceholder]()
    
    let libraryPayloadsTableView = NSTableView()
    let libraryPayloadsScrollView = NSScrollView()
    var libraryPayloads = [PayloadPlaceholder]()
    
    private let sortDescriptorTitle = NSSortDescriptor(key: "title", ascending: true)
    
    private var selectedLibraryTag: LibraryTag?
    private var selectedPayloadPlaceholder: PayloadPlaceholder?
    private var generalPayloadPlaceholder: PayloadPlaceholder?
    
    private weak var profile: Profile?
    private weak var editor: ProfileEditor?
    private weak var librarySplitView: PayloadLibrarySplitView?
    
    init(profile: Profile, editor: ProfileEditor, splitView: PayloadLibrarySplitView) {
        super.init()
        
        self.profile = profile
        self.editor = editor
        self.librarySplitView = splitView
        
        // ---------------------------------------------------------------------
        //  Add and enable the general settings
        // ---------------------------------------------------------------------
        if
            let payloadManifestGeneral = ProfilePayloads.shared.manifest(domain: ManifestDomain.general),
            let payloadPlaceholderGeneral = payloadManifestGeneral.placeholder {
            self.generalPayloadPlaceholder = payloadPlaceholderGeneral
            
            // Add the "Selected" state to the general settings
            editor.updatePayloadSelection(selected: true, payloadSource: payloadManifestGeneral)
        }
        
        self.setupProfilePayloads()
        self.setupLibraryPayloads()
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(changePayloadSelected(_:)), name: .changePayloadSelected, object: nil)
        profile.addObserver(self, forKeyPath: profile.editorSettingsRestoredSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorSelectedDistributionUpdatedSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorSelectedPlatformsUpdatedSelector, options: .new, context: nil)
        profile.addObserver(self, forKeyPath: profile.editorSelectedScopeUpdatedSelector, options: .new, context: nil)
        
        self.reloadTableviews()
        
        // ---------------------------------------------------------------------
        //  Select the general settings in the editor
        // ---------------------------------------------------------------------
        if let payloadPlaceholderGeneral = self.generalPayloadPlaceholder {
            self.select(payloadPlaceholder: payloadPlaceholderGeneral, in: self.profilePayloadsTableView)
        }
    }
    
    deinit {
        // ---------------------------------------------------------------------
        //  Remove self as DataSource and Delegate
        // ---------------------------------------------------------------------
        self.libraryPayloadsTableView.dataSource = nil
        self.profilePayloadsTableView.dataSource = nil
        self.libraryPayloadsTableView.delegate = nil
        self.profilePayloadsTableView.delegate = nil
        
        NotificationCenter.default.removeObserver(self, name: .changePayloadSelected, object: nil)
        
        if let profile = self.profile {
            profile.removeObserver(self, forKeyPath: profile.editorSettingsRestoredSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorSelectedDistributionUpdatedSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorSelectedPlatformsUpdatedSelector, context: nil)
            profile.removeObserver(self, forKeyPath: profile.editorSelectedScopeUpdatedSelector, context: nil)
        }
    }
    
    func updateLibraryPayloads(tag: LibraryTag) {
        self.libraryPayloads = self.placeholders(tag: tag) ?? [PayloadPlaceholder]()
        if let librarySplitView = self.librarySplitView {
            librarySplitView.noPayloads(show: self.libraryPayloads.isEmpty)
            librarySplitView.noProfilePayloads(show: self.profilePayloads.count == 1)
        }
        self.reloadTableviews()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let profile = self.profile else { return }
        switch keyPath ?? "" {
        case profile.editorSettingsRestoredSelector:
            self.addProfilePayloads()
            if let selectedLibraryTag = self.selectedLibraryTag {
                self.updateLibraryPayloads(tag: selectedLibraryTag)
            }
        case profile.editorSelectedDistributionUpdatedSelector,
             profile.editorSelectedPlatformsUpdatedSelector,
             profile.editorSelectedScopeUpdatedSelector:
            if let selectedLibraryTag = self.selectedLibraryTag {
                self.updateLibraryPayloads(tag: selectedLibraryTag)
            }
        default:
            Swift.print("Class: \(self.self), Function: \(#function), observeValueforKeyPath: \(String(describing: keyPath))")
        }
    }
    
    @objc func changePayloadSelected(_ notification: NSNotification?) {
        guard
            let userInfo = notification?.userInfo,
            let payloadPlaceholder = userInfo[NotificationKey.payloadPlaceholder] as? PayloadPlaceholder else { return }
        
        if self.profilePayloads.contains(payloadPlaceholder) {
            self.move(payloadPlaceholders: [payloadPlaceholder], from: .profilePayloads, to: .libraryPayloads)
        } else {
            self.move(payloadPlaceholders: [payloadPlaceholder], from: .libraryPayloads, to: .profilePayloads)
        }
    }
    
    private func reloadTableviews() {
        
        // ---------------------------------------------------------------------
        //  Sort both library and profile arrays alphabetically
        // ---------------------------------------------------------------------
        self.libraryPayloads.sort(by: { $0.title < $1.title })
        self.profilePayloads.sort(by: { $0.title < $1.title })
        
        // ---------------------------------------------------------------------
        //  Verify that the "General" payload always is at the top of the profile payloads list
        // ---------------------------------------------------------------------
        if let generalPayloadPlaceholder = self.generalPayloadPlaceholder {
            if let generalIndex = self.profilePayloads.index(of: generalPayloadPlaceholder) {
                self.profilePayloads.remove(at: generalIndex)
            }
            self.profilePayloads.insert(generalPayloadPlaceholder, at: 0)
        }
        
        // ---------------------------------------------------------------------
        //  Reload both table views
        // ---------------------------------------------------------------------
        self.profilePayloadsTableView.reloadData()
        self.libraryPayloadsTableView.reloadData()
        
        // ---------------------------------------------------------------------
        //  Check which table view holds the current selection, and mark it selected
        //  This is different from - (void)selectPlaceholder which also updates editor etc.
        // ---------------------------------------------------------------------
        if let selectedPayloadPlaceholder = self.selectedPayloadPlaceholder {
            if let index = self.profilePayloads.index(of: selectedPayloadPlaceholder) {
                self.profilePayloadsTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            } else if let index = self.libraryPayloads.index(of: selectedPayloadPlaceholder) {
                self.libraryPayloadsTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            }
        }
    }
    
    func selectLibrary(tag: LibraryTag, sender: Any?) {
        if self.selectedLibraryTag != tag {
            self.selectedLibraryTag = tag
            self.updateLibraryPayloads(tag: tag)
        }
    }
    
    private func placeholders(tag: LibraryTag) -> [PayloadPlaceholder]? {
        switch tag {
        case .appleDomains:
            guard let profile = self.profile else { return nil }
            if var manifestPlaceholders = ProfilePayloads.shared.manifestPlaceholders() {
                manifestPlaceholders = manifestPlaceholders.filter({ !$0.payloadSource.distribution.isDisjoint(with: profile.selectedDistribution) })
                manifestPlaceholders = manifestPlaceholders.filter({ !$0.payloadSource.platforms.isDisjoint(with: profile.selectedPlatforms) })
                manifestPlaceholders = manifestPlaceholders.filter({ !$0.payloadSource.targets.isDisjoint(with: profile.selectedScope) })
                return Array(Set(manifestPlaceholders).subtracting(self.profilePayloads))
            } else { return nil }
        case .appleCollections:
            return ProfilePayloads.shared.collectionPlaceholders()
        case .applications:
            return ProfilePayloads.shared.applicationPlaceholders()
        case .developer:
            return ProfilePayloads.shared.developerPlaceholders()
        }
    }
    
    fileprivate func move(payloadPlaceholders: [PayloadPlaceholder], from: TableViewTag, to:TableViewTag) {
        
        // ---------------------------------------------------------------------
        //  Set whether to enable or disable the payload
        // ---------------------------------------------------------------------
        var selected: Bool = false
        if to == .libraryPayloads {
            selected = false
        } else if to == .profilePayloads {
            selected = true
        }
        
        // ---------------------------------------------------------------------
        //  Loop through all placeholders and move them between the arrays
        // ---------------------------------------------------------------------
        for payloadPlaceholder in payloadPlaceholders {
            if from == TableViewTag.libraryPayloads {
                self.libraryPayloads = self.libraryPayloads.filter { $0 != payloadPlaceholder }
                self.profilePayloads.append(payloadPlaceholder)
            } else if from == TableViewTag.profilePayloads {
                self.profilePayloads = self.profilePayloads.filter { $0 != payloadPlaceholder }
                self.libraryPayloads.append(payloadPlaceholder)
            }
            
            // ---------------------------------------------------------------------
            //  Post a notification that the payload has changed enabled state
            // ---------------------------------------------------------------------
            NotificationCenter.default.post(name: .didChangePayloadSelected, object: self, userInfo: [NotificationKey.payloadPlaceholder : payloadPlaceholder,
                                                                                                      NotificationKey.payloadSelected : selected ])
        }
        
        // ---------------------------------------------------------------------
        //  Update the Enabled state for the payload domain
        // ---------------------------------------------------------------------
        for placeholder in payloadPlaceholders {
            self.editor?.updatePayloadSelection(selected: selected, payloadSource: placeholder.payloadSource)
        }
        
        // ---------------------------------------------------------------------
        //  Check if library payloads is empty, then show "No Payloads" view
        // ---------------------------------------------------------------------
        if let librarySplitView = self.librarySplitView {
            librarySplitView.noPayloads(show: self.libraryPayloads.isEmpty)
            librarySplitView.noProfilePayloads(show: self.profilePayloads.count == 1)
        }
        
        // ---------------------------------------------------------------------
        //  Reload both TableViews
        // ---------------------------------------------------------------------
        self.reloadTableviews()
    }
    
    fileprivate func select(payloadPlaceholder: PayloadPlaceholder, in: NSTableView) {
        
        // ---------------------------------------------------------------------
        //  Update stored selection with payloadPlaceholder
        // ---------------------------------------------------------------------
        self.selectedPayloadPlaceholder = payloadPlaceholder
        
        // ---------------------------------------------------------------------
        //  Tell editor to show the selected payload
        // ---------------------------------------------------------------------
        if let editor = self.editor {
            editor.select(payloadPlaceholder: payloadPlaceholder)
        }
    }
    
    private func addProfilePayloads() {
        
        // ---------------------------------------------------------------------
        //  Add all selected placeholders to the profile placeholders array
        // ---------------------------------------------------------------------
        if let profile = self.editor?.profile {
            
            // Reset
            self.profilePayloads = [PayloadPlaceholder]()
            
            for (typeRawValue, typeSettings) in profile.payloadSettings {
                
                // ---------------------------------------------------------------------
                //  Verify we got a valid type and a non empty settings dict
                // ---------------------------------------------------------------------
                guard
                    let typeInt = Int(typeRawValue),
                    let type = PayloadSourceType(rawValue: typeInt) else {
                        continue
                }
                
                // ---------------------------------------------------------------------
                //  Loop through all domains and settings for the current type, add all enabled
                // ---------------------------------------------------------------------
                for domain in typeSettings.keys {
                    
                    if
                        profile.isEnabled(domain: domain, type: type),
                        let payload = ProfilePayloads.shared.payloadSource(domain: domain, type: type),
                        let payloadPlaceholder = payload.placeholder {
                            self.profilePayloads.append(payloadPlaceholder)
                    }
                }
            }
            
            if
                !self.profilePayloads.contains(where: {$0.domain == ManifestDomain.general}),
                let generalPayloadPlaceholder = self.generalPayloadPlaceholder {
                self.profilePayloads.append(generalPayloadPlaceholder)
            }
        }
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
        self.profilePayloadsTableView.registerForDraggedTypes([.payload])
        self.profilePayloadsTableView.dataSource = self
        self.profilePayloadsTableView.delegate = self
        self.profilePayloadsTableView.target = self
        self.profilePayloadsTableView.sizeLastColumnToFit()
        
        // ---------------------------------------------------------------------
        //  Setup TableColumn
        // ---------------------------------------------------------------------
        let tableColumn = NSTableColumn(identifier: .tableColumnProfilePayloads)
        tableColumn.isEditable = false
        self.profilePayloadsTableView.addTableColumn(tableColumn)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView
        // ---------------------------------------------------------------------
        self.profilePayloadsScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.profilePayloadsScrollView.documentView = self.profilePayloadsTableView
        self.profilePayloadsScrollView.hasVerticalScroller = false // FIXME: TRUE When added ios-style scrollers
        
        // ---------------------------------------------------------------------
        //  Add all payloads selected in the profile
        // ---------------------------------------------------------------------
        self.addProfilePayloads()
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
        self.libraryPayloadsTableView.registerForDraggedTypes([.payload])
        self.libraryPayloadsTableView.dataSource = self
        self.libraryPayloadsTableView.delegate = self
        self.libraryPayloadsTableView.target = self
        self.libraryPayloadsTableView.sizeLastColumnToFit()
        
        // ---------------------------------------------------------------------
        //  Setup TableColumn
        // ---------------------------------------------------------------------
        let tableColumn = NSTableColumn(identifier: .tableColumnLibraryPayloads)
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
            
            // -----------------------------------------------------------------
            //  Do not allow drag drop with General settings (at index 0)
            // -----------------------------------------------------------------
            return false
        }
        
        var selectedPayloadPlaceholders = [PayloadPlaceholder]()
        if tableView.tag == TableViewTag.profilePayloads.rawValue {
            selectedPayloadPlaceholders = self.profilePayloads.objectsAtIndexes(indexes: rowIndexes)
        } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
            selectedPayloadPlaceholders = self.libraryPayloads.objectsAtIndexes(indexes: rowIndexes)
        }
        
        if let encodedData = try? JSONEncoder().encode(selectedPayloadPlaceholders) {
            pboard.clearContents()
            pboard.declareTypes([.payload], owner: nil)
            pboard.setData(encodedData, forType: .payload)
        }
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if let infoSource = info.draggingSource() as? NSTableView, tableView == infoSource || dropOperation == .on {
            return NSDragOperation(rawValue: 0)
        } else {
            tableView.setDropRow(-1, dropOperation: .on)
            return .copy
        }
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if let data = info.draggingPasteboard().data(forType: .payload) {
            do {
                let payloadPlaceholders = try JSONDecoder().decode([PayloadPlaceholder].self, from: data)
                if tableView.tag == TableViewTag.profilePayloads.rawValue {
                    self.move(payloadPlaceholders: payloadPlaceholders, from: TableViewTag.libraryPayloads, to: TableViewTag.profilePayloads)
                } else if tableView.tag == TableViewTag.libraryPayloads.rawValue {
                    self.move(payloadPlaceholders: payloadPlaceholders, from: TableViewTag.profilePayloads, to: TableViewTag.libraryPayloads)
                }
                return true
            } catch {
                // TODO: Proper Logging
                Swift.print("Class: \(self.self), Function: \(#function), Could not decode dropped items")
            }
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

// -----------------------------------------------------------------------------
//  Used by the "No Payloads" view
// -----------------------------------------------------------------------------
extension PayloadLibraryTableViews: NSDraggingDestination {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        Swift.print("Class: \(self.self), Function: \(#function), draggingEntered")
        // FIXME - Here forcing a focus ring would fit, haven't looked into how to yet.
        return NSDragOperation.copy
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        Swift.print("Class: \(self.self), Function: \(#function), prepareForDragOperation")
        return true
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if
            let data = sender.draggingPasteboard().data(forType: .payload),
            let sourceTableView = sender.draggingSource() as? NSTableView {
            do {
                let payloadPlaceholders = try JSONDecoder().decode([PayloadPlaceholder].self, from: data)
                if sourceTableView.tag == TableViewTag.profilePayloads.rawValue {
                    self.move(payloadPlaceholders: payloadPlaceholders, from: .profilePayloads, to: .libraryPayloads)
                } else if sourceTableView.tag == TableViewTag.libraryPayloads.rawValue {
                    self.move(payloadPlaceholders: payloadPlaceholders, from: .libraryPayloads, to: .profilePayloads)
                }
            } catch {
                // TODO: Proper Logging
                Swift.print("Class: \(self.self), Function: \(#function), Could not decode dropped items")
            }
        }
        return false
    }
}

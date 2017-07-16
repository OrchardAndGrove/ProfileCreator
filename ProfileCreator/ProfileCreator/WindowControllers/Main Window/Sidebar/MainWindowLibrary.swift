//
//  MainWindowLibrary.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-10.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowLibrary: NSObject, OutlineViewParentItem, NSTextFieldDelegate {
    
    // MARK: -
    // MARK: Variables
    
    var alert: Alert?
    var isEditable = true
    var title = SidebarGroupTitle.library
    var children = [OutlineViewChildItem]()
    var cellView: OutlineViewParentCellView?
    
    // MARK: -
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        self.cellView = OutlineViewParentCellView(parent: self)
        
        // ---------------------------------------------------------------------
        //  Load all saved groups from disk
        // ---------------------------------------------------------------------
        loadSavedGroups()
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(addGroup(_:)), name: .addGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveProfile(_:)), name: .didRemoveProfile, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didAddGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didRemoveProfile, object: nil)
    }
    
    // MARK: -
    // MARK: Instance Functions
    
    private func loadSavedGroups() {
        
        guard let groupFolderURL = applicationFolder(Folder.groupLibrary) else {
            // TODO: Error
            return
        }
        
        var groupURLs = [URL]()
        
        // ---------------------------------------------------------------------
        //  Put all items from group folder into array
        // ---------------------------------------------------------------------
        do {
            groupURLs = try FileManager.default.contentsOfDirectory(at: groupFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            print("Function: \(#function), Error: \(error)")
            return
        }
        
        // ---------------------------------------------------------------------
        //  Remove all items that doesn't have the FileExtension.group extension
        // ---------------------------------------------------------------------
        groupURLs = groupURLs.filter { $0.pathExtension == FileExtension.group }
        
        // ---------------------------------------------------------------------
        //  Loop through all group files and add them to the group
        // ---------------------------------------------------------------------
        for groupURL in groupURLs {
            do {
                let groupData = try Data.init(contentsOf: groupURL)
                let groupDict = try PropertyListSerialization.propertyList(from: groupData, options: [], format: nil) as! [String : Any]
                if !groupDict.isEmpty {
                    if let title = groupDict[SettingsKey.title] as? String {
                        var uuid: UUID? = nil
                        if let uuidString = groupDict[SettingsKey.identifier] as? String,
                            let theUUID = UUID(uuidString: uuidString) {
                            uuid = theUUID
                        }
                        
                        var uuids = [UUID]()
                        if let uuidStrings = groupDict[SettingsKey.identifiers] as? [String] {
                            for uuidString in uuidStrings {
                                if let theUUID = UUID(uuidString: uuidString) {
                                    uuids.append(theUUID)
                                }
                            }
                        }
                        addGroup(title: title, identifier: uuid, profileIdentifiers: uuids)
                    }
                }
            } catch {
                print("Function: \(#function), Error: \(error)")
            }
        }
    }
    
    func addGroup(title: String, identifier: UUID?, profileIdentifiers: [UUID]?) {
        
        let group = MainWindowLibraryGroup(title: title, identifier: identifier, parent: self)
        
        if let identifiers = profileIdentifiers {
            group.addProfiles(identifiers: identifiers)
        }
        
        let (result, error) = group.writeToDisk(title: title)
        if result {
            self.children.append(group)
            NotificationCenter.default.post(name: .didAddGroup, object: self, userInfo: [SettingsKey.group : group])
        } else {
            Swift.print("error: \(String(describing: error))")
        }
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    func addGroup(_ notification: NSNotification?) {
        
        // ---------------------------------------------------------------------
        //  Verify that addGroup was called for this group
        // ---------------------------------------------------------------------
        guard let parentTitle = notification?.userInfo?[NotificationKey.parentTitle] as? String,
            parentTitle == self.title else {
                return
        }
        
        // ---------------------------------------------------------------------
        //  Verify there is a mainWindow present
        // ---------------------------------------------------------------------
        guard let mainWindow = NSApplication.shared().mainWindow  else {
            return
        }
        
        // ---------------------------------------------------------------------
        //  Show add group alert with text field to user
        // ---------------------------------------------------------------------
        self.alert = Alert()
        self.alert!.showAlert(message: NSLocalizedString("New Library Group", comment: ""),
                              informativeText: NSLocalizedString("Enter a name for new library group to be created.", comment: ""),
                              window: mainWindow,
                              defaultString: nil,
                              placeholderString: nil,
                              firstButtonTitle: ButtonTitle.ok,
                              secondButtonTitle: ButtonTitle.cancel,
                              thirdButtonTitle: nil,
                              firstButtonState: true,
                              sender: self,
                              returnValue: { (title, returnCode) in
                                if returnCode == NSAlertFirstButtonReturn {
                                    self.addGroup(title: title, identifier: nil, profileIdentifiers: [UUID(), UUID(), UUID()])
                                }
        })
        
        // ---------------------------------------------------------------------
        //  Select the text field in the alert sheet
        // ---------------------------------------------------------------------
        self.alert!.textFieldInput!.selectText(self)
    }
    
    func didRemoveProfile(_ notification: NSNotification?) {
        print("didRemoveProfile")
    }
    
    // MARK: -
    // MARK: NSTextFieldDelegate Functions
    
    // -------------------------------------------------------------------------
    //  Used when selecting a new group name to not allow duplicates
    // -------------------------------------------------------------------------
    override func controlTextDidChange(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Get current text in the text field
        // ---------------------------------------------------------------------
        guard let userInfo = notification.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let string = fieldEditor.textStorage?.string else {
                return
        }
        
        // ---------------------------------------------------------------------
        //  Get names of all current groups
        // ---------------------------------------------------------------------
        let currentTitles = self.children.map({ $0.title })
        
        // ---------------------------------------------------------------------
        //  If current text in the text field is either:
        //   * Empty
        //   * Matches an existing group
        //  Disable the OK button.
        // ---------------------------------------------------------------------
        if let alert = self.alert {
            if alert.firstButton!.isEnabled && (string.isEmpty || currentTitles.contains(string)) {
                alert.firstButton!.isEnabled = false
            } else {
                alert.firstButton!.isEnabled = true
            }
        }
        // TODO: Implement
    }
}

class MainWindowLibraryGroup: NSObject, OutlineViewChildItem {
    
    // MARK: -
    // MARK: Variables
    
    var isEditable = true
    var isEditing = false
    var icon = NSImage(named: "SidebarFolder")
    var identifier: UUID
    var title: String
    var profileIdentifiers = [UUID]()
    var cellView: OutlineViewChildCellView?
    
    // MARK: -
    // MARK: Initialization
    
    init(title: String, identifier: UUID?, parent: OutlineViewParentItem) {
        
        self.title = title
        self.identifier = (identifier != nil) ? identifier! : UUID()
        
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        self.cellView = OutlineViewChildCellView(child: self)
    }
    
    // MARK: -
    // MARK: Instance Functions
    func writeToDisk(title: String) -> (Bool, Error?) {
        
        // ---------------------------------------------------------------------
        //  Get url to save at
        // ---------------------------------------------------------------------
        let (url, urlError) = self.url()
        if url == nil { return (false, urlError) }
        
        // ---------------------------------------------------------------------
        //  Get all profile identifiers in group that have been saved to disk
        // ---------------------------------------------------------------------
        var profileIdentifierStrings = [String]()
        for identifier in self.profileIdentifiers {
            
            // ---------------------------------------------------------------------
            //  Get url to save at
            // ---------------------------------------------------------------------
            if let profile = ProfileController.shared.profile(withIdentifier: identifier) {
                
                // -------------------------------------------------------------
                //  Check if profile has been saved to disk at least once (If it has a URL assigned).
                //  If not, don't include it in the group on disk
                // -------------------------------------------------------------
                if profile.url != nil {
                    profileIdentifierStrings.append(identifier.uuidString)
                }
            } else {
                Swift.print("No profile found with identifier: \(identifier)")
            }
        }

        // ---------------------------------------------------------------------
        //  Create dict to save
        // ---------------------------------------------------------------------
        let groupDict: [String : Any] = [SettingsKey.title : self.title,
                                         SettingsKey.identifier : self.identifier.uuidString,
                                         SettingsKey.identifiers : profileIdentifierStrings]
        
        // ---------------------------------------------------------------------
        //  Try to write the group dict to disk
        // ---------------------------------------------------------------------
        do {
            let groupData = try PropertyListSerialization.data(fromPropertyList: groupDict, format: .xml, options: 0)
            try groupData.write(to: url!)
            return (true, nil)
        } catch {
            return (false, error)
        }
    }
    
    private func url() -> (URL?, Error?) {
        
        if let groupFolderURL = applicationFolder(Folder.groupLibrary) {
            do {
                try FileManager.default.createDirectory(at: groupFolderURL, withIntermediateDirectories: true, attributes: nil)
                return (groupFolderURL.appendingPathComponent(self.identifier.uuidString).appendingPathExtension(FileExtension.group), nil)
            } catch {
                return (nil, error)
            }
        }
        
        return (nil, nil)
    }
    
    // MARK: -
    // MARK: OutlineViewChildItem Functions
    
    func addProfiles(identifiers: [UUID]) {
        
        // ---------------------------------------------------------------------
        //  Add the passed identifiers
        // ---------------------------------------------------------------------
        self.profileIdentifiers = Array(Set(self.profileIdentifiers + identifiers))
        
        // ---------------------------------------------------------------------
        //  Save the new group contents to disk
        // ---------------------------------------------------------------------
        writeToDisk(title: self.title)
    }
    
    func removeProfiles(identifiers: [UUID]) {
        
        // ---------------------------------------------------------------------
        //  Remove the passed identifiers
        // ---------------------------------------------------------------------
        self.profileIdentifiers = Array(Set(self.profileIdentifiers).subtracting(identifiers))
        
        // ---------------------------------------------------------------------
        //  Save the new group contents to disk
        // ---------------------------------------------------------------------
        writeToDisk(title: self.title)
        
        // ---------------------------------------------------------------------
        //  Post notification that a grop removed profiles
        // ---------------------------------------------------------------------
        NotificationCenter.default.post(name: .didRemoveProfile, object: self)
    }
    
    func removeProfiles(atIndexes: IndexSet) {
        
        // ---------------------------------------------------------------------
        //  Remove from the passed indexes
        // ---------------------------------------------------------------------
        // TODO: Implement
        
        // ---------------------------------------------------------------------
        //  Save the new group contents to disk
        // ---------------------------------------------------------------------
        writeToDisk(title: self.title)
        
        // ---------------------------------------------------------------------
        //  Post notification that a grop removed profiles
        // ---------------------------------------------------------------------
        NotificationCenter.default.post(name: .didRemoveProfile, object: self)
    }
    
    func removeFromDisk() -> (Bool, Error?) {
        
        var error: Error?
        
        // ---------------------------------------------------------------------
        //  Get path to remove
        // ---------------------------------------------------------------------
        let (url, urlError) = self.url()
        if url == nil { return (false, urlError) }
        
        // ---------------------------------------------------------------------
        //  Try to remove item at url
        // ---------------------------------------------------------------------
        if FileManager.default.fileExists(atPath: url!.path) {
            do {
                try FileManager.default.removeItem(at: url!)
                return (true, nil)
            } catch let removeError as NSError {
                error = removeError
            }
        }
        return (false, error)
    }
    
    // MARK: -
    // MARK: NSTextFieldDelegate Functions
    
    override func controlTextDidBeginEditing(_ notification: Notification) {
        self.isEditing = true
    }
    
    override func controlTextDidEndEditing(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Get current text in the text field
        // ---------------------------------------------------------------------
        if let userInfo = notification.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let string = fieldEditor.textStorage?.string,
            !string.isEmpty {
            let (result, error) = writeToDisk(title: string)
            if result {
                self.title = string
            } else {
                Swift.print("error: \(String(describing: error))")
            }
        }
        self.isEditing = false
    }
}

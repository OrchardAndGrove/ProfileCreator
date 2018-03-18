//
//  ProfileController.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-15.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileController: NSDocumentController {
    
    // MARK: -
    // MARK: Static Variables
    
    public static let sharedInstance = ProfileController()
    
    // MARK: -
    // MARK: Variables
    
    var profiles = Set<Profile>()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Load all saved profiles from disk
        // ---------------------------------------------------------------------
        self.loadSavedProfiles()
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.willCloseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newDocument(_:)), name: .newProfile, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .newProfile, object: nil)
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    @objc func windowWillClose(_ notification: Notification?) {
        
        // ---------------------------------------------------------------------
        //  If window was a ProfileEditor window, update the associated profile
        // ---------------------------------------------------------------------
        if
            let window = notification?.object as? NSWindow,
            let windowController = window.windowController as? ProfileEditorWindowController {
            
            // -----------------------------------------------------------------
            //  Get profile associated with the editor
            // -----------------------------------------------------------------
            guard let profile = windowController.document as? Profile else {
                Log.shared.error(message: "Failed to get the profile associated with the window being closed")
                return
            }
            
            // -----------------------------------------------------------------
            //  Reset all unsaved changes
            // -----------------------------------------------------------------
            profile.restoreSavedSettings(identifier: profile.identifier, savedSettings: nil)
            
            // -----------------------------------------------------------------
            //  Remove the window controller from the profile
            // -----------------------------------------------------------------
            profile.removeWindowController(windowController)
            
            // -----------------------------------------------------------------
            //  If no URL is associated, it has never been saved
            // -----------------------------------------------------------------
            if profile.fileURL == nil {
                let identifier = profile.identifier
                do {
                    if try self.removeProfile(withIdentifier: identifier) {
                        
                        // ---------------------------------------------------------
                        //  If removed successfully, post a didRemoveProfiles notification
                        // ---------------------------------------------------------
                        NotificationCenter.default.post(name: .didRemoveProfiles, object: self, userInfo: [NotificationKey.identifiers: [ identifier ],
                                                                                                           NotificationKey.indexSet : IndexSet()])
                    }
                } catch let error {
                    Log.shared.error(message: "Failed to remove unsaved profile with identifier: \(identifier) with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: -
    // MARK: NSDocumentController Functions
    
    override func newDocument(_ sender: Any?) {
        Log.shared.log(message: "Creating new empty profile")
        
        do {
            
            // -------------------------------------------------------------
            //  Try to create a new empty Profile document
            // -------------------------------------------------------------
            if let profile = try self.openUntitledDocumentAndDisplay(true) as? Profile {
                
                self.profiles.insert(profile)
                
                // -------------------------------------------------------------
                //  Post notification that a profile was added
                // -------------------------------------------------------------
                NotificationCenter.default.post(name: .didAddProfile, object: self, userInfo: [NotificationKey.identifier : profile.identifier])
            }
        } catch let error {
            Log.shared.error(message: "Failed to create a new empty profile with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: -
    // MARK: Load Profiles
    
    private func loadSavedProfiles() {
        #if DEBUG
            Log.shared.debug(message: "Loading saved profiles")
        #endif
        
        // ---------------------------------------------------------------------
        //  Get path to default profile save folder
        // ---------------------------------------------------------------------
        guard let profileFolderURL = applicationFolder(Folder.profiles) else {
            Log.shared.error(message: "No default profile save folder was found")
            return
        }
        
        var profileURLs = [URL]()
        
        // ---------------------------------------------------------------------
        //  Put all items from default profile save folder into an array
        // ---------------------------------------------------------------------
        do {
            profileURLs = try FileManager.default.contentsOfDirectory(at: profileFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            Log.shared.error(message: "Failed to get the contents of the default profile save folder with error: \(error.localizedDescription)")
            return
        }
        
        // ---------------------------------------------------------------------
        //  Remove all items that doesn't have the FileExtension.profile extension
        // ---------------------------------------------------------------------
        profileURLs = profileURLs.filter { $0.pathExtension == FileExtension.profile }
        
        // ---------------------------------------------------------------------
        //  Loop through all profile files, try to create a Profile instance and add them to the profiles set
        // ---------------------------------------------------------------------
        for profileURL in profileURLs {
            do {
                
                // -------------------------------------------------------------
                //  Create the profile from the file at profileURL
                // -------------------------------------------------------------
                let document = try self.makeDocument(withContentsOf: profileURL, ofType: TypeName.profile)
                
                // -------------------------------------------------------------
                //  Check that no other profile exist with the same identifier
                //  This means that only the first profile created with that identifier will exist
                // -------------------------------------------------------------
                guard let profile = document as? Profile, !self.profiles.contains(where: { $0.identifier == profile.identifier }) else {
                    Log.shared.error(message: "A profile with identifier: \(String(describing: (document as? Profile)?.identifier)) was already imported. This and subsequent profiles with the same identifier will be ignored.")
                    return
                }
                self.profiles.insert(profile)
                
                // -------------------------------------------------------------
                //  Post notification that a profile was added
                // -------------------------------------------------------------
                NotificationCenter.default.post(name: .didAddProfile, object: self, userInfo: [NotificationKey.identifier : profile.identifier])
            } catch {
                Log.shared.error(message: "Failed to load a profile from the file at: \(profileURL.path) with error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: -
    // MARK: Get Profiles
    
    public func profile(withIdentifier identifier: UUID) -> Profile? {
        return self.profiles.first(where: { $0.identifier == identifier })
    }
    
    public func profiles(withIdentifiers identifiers: [UUID]) -> [Profile]? {
        return self.profiles.filter({ identifiers.contains($0.identifier) })
    }
    
    public func profileIdentifiers() -> [UUID]? {
        return self.profiles.map({ $0.identifier })
    }
    
    public func titleOfProfile(withIdentifier identifier: UUID) -> String? {
        if let profile = self.profile(withIdentifier: identifier) {
            return profile.title
        } else { Log.shared.error(message: "Found no profile with identifier: \(identifier)") }
        return nil
    }
    
    // MARK: -
    // MARK: Edit Profiles
    
    public func editProfile(withIdentifier identifier: UUID) {
        #if DEBUG
            Log.shared.debug(message: "Edit profile with identifier: \(identifier)")
        #endif
        
        if let profile = self.profile(withIdentifier: identifier) {
            profile.edit()
        } else { Log.shared.error(message: "Found no profile with identifier: \(identifier)") }
    }
    
    // MARK: -
    // MARK: Export Profiles
    
    public func export(profile: Profile) {
        #if DEBUG
            Log.shared.debug(message: "Export profile with identifier: \(profile.identifier)")
        #endif
        
        // ---------------------------------------------------------------------
        //  Get a reference to the main window to attach dialogs to
        // ---------------------------------------------------------------------
        guard
            let appDelegate = NSApplication.shared.delegate as? AppDelegate,
            let mainWindow = appDelegate.mainWindowController.window else { return }
        
        // ---------------------------------------------------------------------
        //  Verify atleast one payload is enabled
        // ---------------------------------------------------------------------
        if profile.enabledPayloadsCount == 0 {
            Log.shared.error(message: "No payloads were selected in profile with identifier: \(profile.identifier)")
            self.showAlertNoPayloadSelected(inProfile: profile, window: mainWindow)
            return
        }
        
        // ---------------------------------------------------------------------
        //  Show save panel to let user select save path
        // ---------------------------------------------------------------------
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["mobileconfig"]
        savePanel.nameFieldStringValue = profile.title
        savePanel.beginSheetModal(for: mainWindow) { (response) in
            if response != .OK { return }
            
            if let profileURL = savePanel.url {
                do {
                    try ProfileExport().export(profile: profile, profileURL: profileURL)
                } catch {
                    Log.shared.error(message: "Failed to export profile with identifier: \(profile.identifier) to path: \(profileURL.path) with error: \(error.localizedDescription)")
                    self.showAlertExport(error: error, window: mainWindow)
                }
            } else { Log.shared.error(message: "Failed to get the selected save path from the save panel for profile with identifier: \(profile.identifier)") }
        }
    }
    
    public func exportProfile(withIdentifier identifier: UUID) {
        if let profile = self.profile(withIdentifier: identifier) {
            self.export(profile: profile)
        } else { Log.shared.error(message: "Found no profile with identifier: \(identifier)") }
    }
    
    public func exportProfiles(withIdentifiers identifiers: [UUID]) {
        if let profiles = self.profiles(withIdentifiers: identifiers) {
            for profile in profiles {
                self.export(profile: profile)
            }
        } else { Log.shared.error(message: "Found no profiles with identifiers: \(identifiers)") }
    }
    
    public func showAlertNoPayloadSelected(inProfile profile: Profile, window: NSWindow) {
        let alert = Alert()
        let alertMessage = NSLocalizedString("No Payloads are included in \"\(profile.title)\".", comment: "")
        let alertInformativeText = NSLocalizedString("Please include at least one (1) payload in the profile.", comment: "")
        
        alert.showAlert(message: alertMessage,
                        informativeText: alertInformativeText,
                        window: window,
                        firstButtonTitle: ButtonTitle.ok,
                        secondButtonTitle: nil,
                        thirdButtonTitle: nil,
                        firstButtonState: true,
                        sender: nil) { _ in }
    }
    
    public func showAlertExport(error: Error, window: NSWindow) {
        guard let exportError = error as? ProfileExportError else { return }
        let alert = Alert()
        
        alert.showAlert(message: exportError.localizedDescription,
                        informativeText: nil,
                        window: window,
                        firstButtonTitle: ButtonTitle.ok,
                        secondButtonTitle: nil,
                        thirdButtonTitle: nil,
                        firstButtonState: true,
                        sender: nil) { _ in }
    }
    
    // MARK: -
    // MARK: Remove Profiles
    
    private func removeProfile(withIdentifier identifier: UUID) throws -> Bool {
        Log.shared.log(message: "Removing profile with identifier: \(identifier)")
        
        if let profile = self.profile(withIdentifier: identifier) {
            
            // -----------------------------------------------------------------
            //  Try to get the URL, if it doesn't have a URL, it should not be saved on disk
            // -----------------------------------------------------------------
            guard let url = profile.fileURL, FileManager.default.fileExists(atPath: url.path) else {
                self.profiles.remove(profile)
                return true
            }
            
            // -----------------------------------------------------------------
            //  Try to remove item at url
            // -----------------------------------------------------------------
            try FileManager.default.removeItem(at: url)
            self.profiles.remove(profile)
            return true
        } else { Log.shared.error(message: "Found no profile with identifier: \(identifier)") }
        return false
    }
    
    public func removeProfiles(atIndexes indexes: IndexSet, withIdentifiers identifiers: [UUID]) {
        #if DEBUG
            Log.shared.debug(message: "Removing profiles at indexes: \(indexes) with identifiers: \(identifiers)")
        #endif
        
        var removedIdentifiers = [UUID]()
        
        // ---------------------------------------------------------------------
        //  Loop through all passed identifiers and try to remove them individually
        // ---------------------------------------------------------------------
        for identifier in identifiers {
            do {
                if try self.removeProfile(withIdentifier: identifier) {
                    
                    // -------------------------------------------------------------
                    //  If removed successfully, add to removedIdentifiers
                    // -------------------------------------------------------------
                    removedIdentifiers.append(identifier)
                }
            } catch {
                Log.shared.error(message: "Removing profile with identifier: \(identifier) failed with error: \(error.localizedDescription)")
            }
        }
        
        // ---------------------------------------------------------------------
        //  Post all successfully removed profile identifiers as a didRemoveProfile notification
        // ---------------------------------------------------------------------
        if !removedIdentifiers.isEmpty {
            NotificationCenter.default.post(name: .didRemoveProfiles, object: self, userInfo: [NotificationKey.identifiers: removedIdentifiers,
                                                                                               NotificationKey.indexSet : indexes])
        }
    }
}

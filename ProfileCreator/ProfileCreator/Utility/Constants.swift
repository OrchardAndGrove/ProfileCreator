//
//  Constants.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation

let preferencesWindowWidth: CGFloat = 450.0
let preferencesIndent: CGFloat = 40.0

let editorTableViewColumnPaddingWidth: CGFloat = 24.0
let editorTableViewColumnPayloadWidth: CGFloat = 500.0

enum TableViewTag: Int {
    case profilePayloads, libraryPayloads
}

extension Notification.Name {
    static let addGroup = Notification.Name("addGroup")
    static let newProfile = Notification.Name("newProfile")
    static let didAddGroup = Notification.Name("didAddGroup")
    static let didAddProfile = Notification.Name("didAddProfile")
    static let didChangeProfileSelection = Notification.Name("didChangeProfileSelection")
    static let didRemoveProfiles = Notification.Name("didRemoveProfiles")
    static let didRemoveProfilesFromGroup = Notification.Name("didRemoveProfilesFromGroup")
    static let didSaveProfile = Notification.Name("didSaveProfile")
    static let emptyNotification = Notification.Name("emptyNotification")
    static let exportProfile = Notification.Name("exportProfile")
    static let noProfileConfigured = Notification.Name("noProfileConfigured")
    static let removeProfile = Notification.Name("removeProfile")
}

struct ToolbarIdentifier {
    static let profileEditorTitle = "profileEditorTitle"
    static let mainWindowAdd = NSLocalizedString("Add", comment: "")
    static let mainWindowExport = NSLocalizedString("Export", comment: "")
    static let preferencesWindowGeneral = NSLocalizedString("General", comment: "")
    static let preferencesWindowProfileDefaults = NSLocalizedString("ProfileDefaults", comment: "")
}

struct TableColumnIdentifier {
    static let padding = "padding"
    static let paddingLeading = "paddingLeading"
    static let paddingTrailing = "paddingTrailing"
    static let payload = "payload"
    static let profilePayloads = "profilePayloads"
    static let libraryPayloads = "libraryPayloads"
}

struct TypeName {
    static let profile = "Profile"
}

struct FileExtension {
    static let group = "pfcgrp"
    static let profile = "pfcconf"
}

// This needs to be renamed after more items are added, to make it easier to understand and use.
struct StringConstant {
    static let defaultProfileName = "Untitled"
}

struct DraggingType {
    static let profile = "Profile"
    static let payload = "Payload"
}

struct NotificationKey {
    static let identifier = "Identifier"
    static let identifiers = "Identifiers"
    static let indexSet = "IndexSet"
    static let parentTitle = "ParentTitle"
}

struct PreferenceKey {
    static let organization = ""
    static let showProfileCount = "ShowProfileCount"
    static let showGroupIcons = "ShowGroupIcons"
}

struct SidebarGroupTitle {
    static let allProfiles = "All Profiles"
    static let library = "Library"
}

struct SettingsKey {
    static let group = "Group"
    static let identifier = "Identifier"
    static let identifiers = "Identifiers"
    static let payloadSettings = "PayloadSettings"
    static let title = "Title"
    static let viewSettings = "ViewSettings"
}

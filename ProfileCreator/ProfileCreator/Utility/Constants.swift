//
//  Constants.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let addGroup = Notification.Name("addGroup")
    static let addProfile = Notification.Name("addProfile")
    static let didAddGroup = Notification.Name("didAddGroup")
    static let didAddProfile = Notification.Name("didAddProfile")
    static let didChangeProfileSelection = Notification.Name("didChangeProfileSelection")
    static let didRemoveProfile = Notification.Name("didRemoveProfile")
    static let didSaveProfile = Notification.Name("didSaveProfile")
    static let emptyNotification = Notification.Name("emptyNotification")
    static let exportProfile = Notification.Name("exportProfile")
    static let noProfileConfigured = Notification.Name("noProfileConfigured")
    static let removeProfile = Notification.Name("removeProfile")
}

struct ToolbarIdentifier {
    static let mainWindowAdd = NSLocalizedString("Add", comment: "")
    static let mainWindowExport = NSLocalizedString("Export", comment: "")
    static let preferencesWindowGeneral = NSLocalizedString("General", comment: "")
    static let preferencesWindowProfileDefaults = NSLocalizedString("ProfileDefaults", comment: "")
}

struct FileExtension {
    static let group = "pfcgrp"
    static let profile = "pfcconf"
}

// This needs to be renamed after more items are added, to make it easier to understand and use.
struct StringConstant {
    static let defaultProfileName = "Untitle"
}

struct DraggingType {
    static let profile = "Profile"
}

struct NotificationKey {
    static let identifier = "Identifier"
    static let parentTitle = "ParentTitle"
}

struct Defaults {
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

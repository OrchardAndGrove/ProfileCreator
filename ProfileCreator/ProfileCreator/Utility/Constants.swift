//
//  Constants.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

let preferencesWindowWidth: CGFloat = 450.0
let preferencesIndent: CGFloat = 40.0

let editorTableViewColumnPaddingWidth: CGFloat = 24.0
let editorTableViewColumnPayloadWidth: CGFloat = 500.0

enum TableViewTag: Int {
    case profilePayloads, libraryPayloads
}

enum LibraryTag: Int {
    case appleCollections, appleDomains, developer
}

extension NSToolbarItem.Identifier {
    static let editorTitle = NSToolbarItem.Identifier("editorTitle")
    static let mainWindowAdd = NSToolbarItem.Identifier("mainWindowAdd")
    static let mainWindowExport = NSToolbarItem.Identifier("mainWindowExport")
    static let preferencesGeneral = NSToolbarItem.Identifier("preferencesGeneral")
    static let preferencesEditor = NSToolbarItem.Identifier("preferencesEditor")
    static let preferencesProfileDefaults = NSToolbarItem.Identifier("preferencesProfileDefaults")
}

extension NSUserInterfaceItemIdentifier {
    static let paddingPayload = NSUserInterfaceItemIdentifier("paddingPayload")
    static let tableColumnPaddingLeading = NSUserInterfaceItemIdentifier("tableColumnPaddingLeading")
    static let tableColumnPaddingTrailing = NSUserInterfaceItemIdentifier("tableColumnPaddingTrailing")
    static let tableColumnProfilePayloads = NSUserInterfaceItemIdentifier("tableColumnProfilePayloads")
    static let tableColumnLibraryPayloads = NSUserInterfaceItemIdentifier("tableColumnLibraryPayloads")
    static let tableColumnMainWindowOutlineView = NSUserInterfaceItemIdentifier("tableColumnMainWindowOutlineView")
    static let tableColumnPayload = NSUserInterfaceItemIdentifier("tableColumnPayload")
}

extension Notification.Name {
    static let addGroup = Notification.Name("addGroup")
    static let newProfile = Notification.Name("newProfile")
    static let didAddGroup = Notification.Name("didAddGroup")
    static let didAddProfile = Notification.Name("didAddProfile")
    static let didChangeProfileSelection = Notification.Name("didChangeProfileSelection")
    static let didChangePayloadSelection = Notification.Name("didChangePayloadSelection")
    static let didRemoveProfiles = Notification.Name("didRemoveProfiles")
    static let didRemoveProfilesFromGroup = Notification.Name("didRemoveProfilesFromGroup")
    static let didSaveProfile = Notification.Name("didSaveProfile")
    static let emptyNotification = Notification.Name("emptyNotification")
    static let exportProfile = Notification.Name("exportProfile")
    static let noProfileConfigured = Notification.Name("noProfileConfigured")
    static let removeProfile = Notification.Name("removeProfile")
}

extension NSPasteboard.PasteboardType {
    static let profile = NSPasteboard.PasteboardType(rawValue: "Profile")
    static let payload = NSPasteboard.PasteboardType(rawValue: "Payload")
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

struct NotificationKey {
    static let identifier = "Identifier"
    static let identifiers = "Identifiers"
    static let indexSet = "IndexSet"
    static let parentTitle = "ParentTitle"
    static let payloadPlaceholder = "PayloadPlaceholder"
}

struct PreferenceKey {
    static let organization = ""
    static let showProfileCount = "ShowProfileCount"
    static let showGroupIcons = "ShowGroupIcons"
    static let showPayloadLibraryAppleCollections = "ShowPayloadLibraryAppleCollections"
    static let showPayloadLibraryAppleDomains = "ShowPayloadLibraryAppleDomains"
    static let showPayloadLibraryDeveloper = "ShowPayloadLibraryDeveloper"
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
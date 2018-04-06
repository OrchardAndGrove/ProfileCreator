//
//  Constants.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

let preferencesWindowWidth: CGFloat = 450.0
let preferencesIndent: CGFloat = 40.0

let editorPreferencesWindowWidth: CGFloat = 300.0
let editorPreferencesIndent: CGFloat = 22.0

let editorTableViewColumnPaddingWidth: CGFloat = 24.0
let editorTableViewColumnPayloadWidth: CGFloat = 500.0

let manifestSubkeysIgnored = ["PayloadDescription",
                              "PayloadDisplayName",
                              "PayloadIdentifier",
                              "PayloadType",
                              "PayloadUUID",
                              "PayloadVersion",
                              "PayloadOrganization"]

struct ManifestDomain {
    static let general = "com.apple.general"
}

enum TableViewTag: Int {
    case profilePayloads
    case libraryPayloads
}

enum LibraryTag: Int {
    case appleDomains
    case applicationDomains
    case localApplicationDomains
    case developer
}

enum EditorViewTag: Int {
    case profileCreator
    case source
}

extension NSToolbarItem.Identifier {
    static let editorAdd = NSToolbarItem.Identifier("editorAdd")
    static let editorTitle = NSToolbarItem.Identifier("editorTitle")
    static let editorSettings = NSToolbarItem.Identifier("editorSettings")
    static let editorView = NSToolbarItem.Identifier("editorView")
    static let mainWindowAdd = NSToolbarItem.Identifier("mainWindowAdd")
    static let mainWindowExport = NSToolbarItem.Identifier("mainWindowExport")
    static let preferencesGeneral = NSToolbarItem.Identifier("preferencesGeneral")
    static let preferencesEditor = NSToolbarItem.Identifier("preferencesEditor")
    static let preferencesLibrary = NSToolbarItem.Identifier("preferencesLibrary")
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
    static let tableColumnPayloadEnableLeading = NSUserInterfaceItemIdentifier("tableColumnPayloadEnableLeading")
    static let tableColumnPayloadEnableTrailing = NSUserInterfaceItemIdentifier("tableColumnPayloadEnableTrailing")
}

extension Notification.Name {
    static let addGroup = Notification.Name("addGroup")
    static let newProfile = Notification.Name("newProfile")
    static let didAddGroup = Notification.Name("didAddGroup")
    static let didAddProfile = Notification.Name("didAddProfile")
    static let didChangeProfileSelection = Notification.Name("didChangeProfileSelection")
    static let didChangePayloadSelection = Notification.Name("didChangePayloadSelection")
    static let changePayloadSelected = Notification.Name("changePayloadSelected")
    static let didChangePayloadSelected = Notification.Name("didChangePayloadSelected")
    static let didRemoveProfiles = Notification.Name("didRemoveProfiles")
    static let didRemoveProfilesFromGroup = Notification.Name("didRemoveProfilesFromGroup")
    static let didSaveProfile = Notification.Name("didSaveProfile")
    static let emptyNotification = Notification.Name("emptyNotification")
    static let exportProfile = Notification.Name("exportProfile")
    static let noProfileConfigured = Notification.Name("noProfileConfigured")
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
    static let domain = "com.github.erikberglund.ProfileCreator"
    static let defaultProfileName = "Untitled"
}

struct FileInfoViewKey {
    static let title = "Title"
    static let topLabel = "TopLabel"
    static let topContent = "TopContent"
    static let topError = "TopError"
    static let centerLabel = "CenterLabel"
    static let centerContent = "CenterContent"
    static let centerError = "CenterError"
    static let bottomLabel = "BottomLabel"
    static let bottomContent = "BottomContent"
    static let bottomError = "BottomError"
    static let message = "Message"
    static let iconPath = "IconPath"
}

struct FileInfoKey {
    static let fileAttributes = "FileAttributes"
    static let fileInfoView = "FileInfoView"
    static let fileURL = "FileURL"
    static let fileUTI = "FileUTI"
}

struct NotificationKey {
    static let group = "Group"
    static let identifier = "Identifier"
    static let identifiers = "Identifiers"
    static let indexSet = "IndexSet"
    static let parentTitle = "ParentTitle"
    static let payloadSelected = "payloadSelected"
    static let payloadPlaceholder = "PayloadPlaceholder"
}

struct PreferenceKey {
    static let defaultOrganization = "DefaultOrganization"
    static let defaultOrganizationIdentifier = "DefaultOrganizationIdentifier"
    static let showProfileCount = "ShowProfileCount"
    static let showGroupIcons = "ShowGroupIcons"
    static let showPayloadLibraryAppleDomains = "ShowPayloadLibraryAppleDomains"
    static let showPayloadLibraryApplicationDomains = "ShowPayloadLibraryApplicationDomains"
    static let showPayloadLibraryLocalApplicationDomains = "ShowPayloadLibraryLocalApplicationDomains"
    static let showPayloadLibraryDeveloper = "ShowPayloadLibraryDeveloper"
    static let editorDisableOptionalKeys = "EditorDisableOptionalKeys"
    static let editorDistributionMethod = "EditorDistributionMethod"
    static let editorColumnEnable = "EditorColumnEnable"
    static let editorShowDisabledKeys = "EditorShowDisabledKeys"
    static let editorShowSupervisedKeys = "EditorShowSupervisedKeys"
    static let editorShowHiddenKeys = "EditorShowHiddenKeys"
    static let editorShowMacOS = "EditorShowMacOS"
    static let editorShowIOS = "EditorShowIOS"
    static let editorShowTvOS = "EditorShowTvOS"
    static let editorShowScopeUser = "EditorShowScopeUser"
    static let editorShowScopeSystem = "EditorShowScopeSystem"
}

enum SidebarGroup {
    case allProfiles
    case library
    case jss
}

struct SidebarGroupTitle {
    static let allProfiles = "All Profiles"
    static let library = "Library"
    static let jss = "JAMF JSS"
}

public struct SettingsKey {
    static let enabled = "Enabled"
    static let fileInfo = "FileInfo"
    static let hash = "Hash"
    static let identifier = "Identifier"
    static let identifiers = "Identifiers"
    static let jssUsername = "JSSUsername"
    static let jssURL = "JSSURL"
    static let payloadSettings = "PayloadSettings"
    static let selected = "Selected"
    static let sign = "Sign"
    static let title = "Title"
    static let viewSettings = "ViewSettings"
    static let value = "Value"
    static let settings = "Settings"
}

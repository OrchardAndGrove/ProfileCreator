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
    static let didAddGroup = Notification.Name("didAddGroup")
    static let didAddProfile = Notification.Name("didAddProfile")
    static let didSaveProfile = Notification.Name("didSaveProfile")
    static let didRemoveProfile = Notification.Name("didRemoveProfile")
    static let noProfileConfigured = Notification.Name("noProfileConfigured")
}

struct NotificationKey {
    static let parentTitle = "ParentTitle"
}

struct Defaults {
    static let showProfileCount = "ShowProfileCount"
    static let showGroupIcons = "ShowGroupIcons"
}

struct SidebarGroupTitle {
    static let allProfiles = "All Profiles"
    static let library = "Library"
}

struct SidebarGroupKey {
    static let group = "Group"
    static let title = "Title"
    static let identifier = "Identifier"
    static let identifiers = "Identifiers"
}

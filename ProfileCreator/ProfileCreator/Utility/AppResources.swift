//
//  AppResources.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-10.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation

enum Folder {
    case applicationSupport, profiles, groups, groupLibrary, groupSmartGroups
}

func applicationFolder(_ folder: Folder) -> URL? {
    switch folder {
    case Folder.applicationSupport:
        do {
            let userApplicationSupport = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return userApplicationSupport.appendingPathComponent("ProfileCreator", isDirectory: true)
        } catch {
            print("Function: \(#function), Error: \(error)")
        }
        break
    case Folder.profiles:
        if let userApplicationSupport = applicationFolder(Folder.applicationSupport) {
            return userApplicationSupport.appendingPathComponent("Profiles", isDirectory: true)
        }
        break
    case Folder.groups:
        if let userApplicationSupport = applicationFolder(Folder.applicationSupport) {
            return userApplicationSupport.appendingPathComponent("Groups", isDirectory: true)
        }
        break
    case Folder.groupLibrary:
        if let groups = applicationFolder(Folder.groups) {
            return groups.appendingPathComponent("Library", isDirectory: true)
        }
        break
    case Folder.groupSmartGroups:
        if let groups = applicationFolder(Folder.groups) {
            return groups.appendingPathComponent("SmartGroups", isDirectory: true)
        }
        break
    }
    return nil
}

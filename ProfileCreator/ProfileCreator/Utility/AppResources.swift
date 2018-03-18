//
//  AppResources.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-10.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

enum Folder {
    case applicationSupport, profiles, groups, groupLibrary, groupSmartGroups
}

func applicationFolder(_ folder: Folder) -> URL? {
    switch folder {
    case .applicationSupport:
        do {
            let userApplicationSupport = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return userApplicationSupport.appendingPathComponent("ProfileCreator", isDirectory: true)
        } catch {
            Swift.print("Function: \(#function), Error: \(error)")
        }
        break
    case .profiles:
        if let userApplicationSupport = applicationFolder(Folder.applicationSupport) {
            let profileFolder = userApplicationSupport.appendingPathComponent("Profiles", isDirectory: true)
            if !FileManager.default.fileExists(atPath: profileFolder.path) {
                do {
                    try FileManager.default.createDirectory(at: profileFolder, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return nil
                }
            }
            return profileFolder
        }
        break
    case .groups:
        if let userApplicationSupport = applicationFolder(Folder.applicationSupport) {
            return userApplicationSupport.appendingPathComponent("Groups", isDirectory: true)
        }
        break
    case .groupLibrary:
        if let groups = applicationFolder(Folder.groups) {
            return groups.appendingPathComponent("Library", isDirectory: true)
        }
        break
    case .groupSmartGroups:
        if let groups = applicationFolder(Folder.groups) {
            return groups.appendingPathComponent("SmartGroups", isDirectory: true)
        }
        break
    }
    return nil
}

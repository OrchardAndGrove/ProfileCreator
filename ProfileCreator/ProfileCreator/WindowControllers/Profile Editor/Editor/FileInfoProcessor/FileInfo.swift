//
//  FileInfo.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-03.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

struct FileInfo {
    let title: String
    
    let topLabel: String
    let topContent: String
    
    let centerLabel: String?
    let centerContent: String?
    
    let bottomLabel: String?
    let bottomContent: String?
    
    let icon: NSImage?
    
    init(title: String,
         topLabel: String,
         topContent: String,
         centerLabel: String? = nil,
         centerContent: String? = nil,
         bottomLabel: String? = nil,
         bottomContent: String? = nil,
         icon: NSImage? = nil) {
        self.title = title
        self.topLabel = topLabel
        self.topContent = topContent
        self.centerLabel = centerLabel
        self.centerContent = centerContent
        self.bottomLabel = bottomLabel
        self.bottomContent = bottomContent
        self.icon = icon
    }
    
    init?(infoDict: Dictionary<String, Any>, backupIcon: NSImage) {
        
        // Title
        if let title = infoDict[FileInfoViewKey.title] as? String {
            self.title = title
        } else { return nil }
        
        // Top Label
        if let topLabel = infoDict[FileInfoViewKey.topLabel] as? String {
            self.topLabel = topLabel
        } else { return nil }
        
        // Top Description
        if let topContent = infoDict[FileInfoViewKey.topContent] as? String {
            self.topContent = topContent
        } else { return nil }
        
        // Center Label
        if let centerLabel = infoDict[FileInfoViewKey.centerLabel] as? String {
            self.centerLabel = centerLabel
        } else { self.centerLabel = nil }
        
        // Center Description
        if let centerContent = infoDict[FileInfoViewKey.centerContent] as? String {
            self.centerContent = centerContent
        } else { self.centerContent = nil }
        
        // Bottom Label
        if let bottomLabel = infoDict[FileInfoViewKey.bottomLabel] as? String {
            self.bottomLabel = bottomLabel
        } else { self.bottomLabel = nil }
        
        // Bottom Description
        if let bottomContent = infoDict[FileInfoViewKey.bottomContent] as? String {
            self.bottomContent = bottomContent
        } else { self.bottomContent = nil }
        
        // Icon
        if let iconPath = infoDict[FileInfoViewKey.iconPath] as? String {
            if FileManager.default.fileExists(atPath: iconPath) {
                let iconURL = URL(fileURLWithPath: iconPath)
                if let icon = NSImage(contentsOf: iconURL) {
                    self.icon = icon
                } else { self.icon = backupIcon }
            } else { self.icon = backupIcon }
        } else { self.icon = backupIcon }
    }
    
    func infoDict() -> Dictionary<String, Any> {
        var infoDict = [FileInfoViewKey.title: self.title,
                        FileInfoViewKey.topLabel: self.topLabel,
                        FileInfoViewKey.topContent: self.topContent]
        
        // Center Label
        if let centerLabel = self.centerLabel { infoDict[FileInfoViewKey.centerLabel] = centerLabel }
        
        // Center Description
        if let centerContent = self.centerContent { infoDict[FileInfoViewKey.centerContent] = centerContent }
        
        // Bottom Label
        if let bottomLabel = self.bottomLabel { infoDict[FileInfoViewKey.bottomLabel] = bottomLabel }
        
        // Bottom Description
        if let bottomContent = self.bottomContent { infoDict[FileInfoViewKey.bottomContent] = bottomContent }
        
        return infoDict
    }
}

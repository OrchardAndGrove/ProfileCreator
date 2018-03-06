//
//  FileInfoProcessor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-02-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class FileInfoProcessors {
    
    // MARK: -
    // MARK: Variables
    
    public static let shared = ProfileController()
    
    private init() {}
    
    public func processorFor(fileAtURL url: URL) -> FileInfoProcessor? {
        return FileInfoProcessor(fileURL: url)
    }
    
    public func processorFor(data: Data, fileInfo: Dictionary<String, Any>) -> FileInfoProcessor? {
        return FileInfoProcessor(data: data, fileInfo: fileInfo)
    }
}

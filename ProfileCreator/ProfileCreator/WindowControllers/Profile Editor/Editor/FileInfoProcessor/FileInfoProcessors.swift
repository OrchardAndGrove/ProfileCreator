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
    
    public static let shared = FileInfoProcessors()
    
    private init() {}
    
    public func processorFor(fileAtURL url: URL) -> FileInfoProcessor {
        if
            let fileUTIs = try? url.resourceValues(forKeys: Set([.typeIdentifierKey])),
            let fileUTI = fileUTIs.typeIdentifier {
            
            if NSWorkspace.shared.type(fileUTI, conformsToType: "public.x509-certificate") {
                return FileInfoProcessorCertificate(fileURL: url)
            } else if NSWorkspace.shared.type(fileUTI, conformsToType: "public.font") {
                return FileInfoProcessorFont(fileURL: url)
            }
        }
        return FileInfoProcessor(fileURL: url)
    }
    
    public func processorFor(data: Data, fileInfo: Dictionary<String, Any>) -> FileInfoProcessor? {
        if let fileUTI = fileInfo[FileInfoKey.fileUTI] as? String {
            
            if NSWorkspace.shared.type(fileUTI, conformsToType: "public.x509-certificate") {
                return FileInfoProcessorCertificate(data: data, fileInfo: fileInfo)
            } else if NSWorkspace.shared.type(fileUTI, conformsToType: "public.font") {
                return FileInfoProcessorFont(data: data, fileInfo: fileInfo)
            }
            
        }
        return FileInfoProcessor(data: data, fileInfo: fileInfo)
    }
}

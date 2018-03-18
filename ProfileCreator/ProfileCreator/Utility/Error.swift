//
//  Error.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-23.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

let ProfileCreatorErrorDomain = Bundle.main.bundleIdentifier ?? StringConstant.domain

enum ProfileExportError: Error {
    case unknownError
    case noPayloadSource(forDomain: String, ofType: PayloadSourceType)
    case invalid(value: Any?, forKey: String, inDomain: String, ofType: PayloadSourceType)
}

public enum ProfileCreatorError: Int {
    
    case unknown = 1
    case notAuthenticated = 2
    
    func userInfo() -> [String : String] {
        var localizedDescription: String = ""
        let localizedFailureReasonError: String = "" // Unused
        let localizedRecoverySuggestionError: String = "" // Unused
        
        switch self {
        case .unknown:
            localizedDescription = NSLocalizedString("Error.Unknown", comment: "Unknown error")
        case .notAuthenticated:
            localizedDescription = NSLocalizedString("Error.NotAuthenticated", comment: "User not authenticated")
        }
        
        return [
            NSLocalizedDescriptionKey: localizedDescription,
            NSLocalizedFailureReasonErrorKey: localizedFailureReasonError,
            NSLocalizedRecoverySuggestionErrorKey: localizedRecoverySuggestionError
        ]
    }
}

extension NSError {
    convenience init(type: ProfileCreatorError) {
        self.init(domain: ProfileCreatorErrorDomain, code: type.rawValue, userInfo: type.userInfo())
    }
}

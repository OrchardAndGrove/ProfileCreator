//
//  Error.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-23.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation

let ProfileCreatorErrorDomain = Bundle.main.bundleIdentifier ?? "com.github.erikberglund.ProfileCreator"

public enum ProfileCreatorError: Int {
    
    case unknown = 1
    case notAuthenticated = 2
    
    func userInfo() -> [String : String] {
        var localizedDescription: String = ""
        var localizedFailureReasonError: String = ""
        var localizedRecoverySuggestionError: String = ""
        
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

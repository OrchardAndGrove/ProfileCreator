//
//  PayloadPlaceholder.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-30.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation

class PayloadPlaceholder: NSObject, Codable {
    
    let title: String
    let identifier: UUID
    
    init(payload: String) {
        
        self.title = payload
        self.identifier = UUID()
        
        super.init()
    }
    
}

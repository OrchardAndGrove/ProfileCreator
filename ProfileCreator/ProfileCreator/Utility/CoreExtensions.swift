//
//  CoreExtensions.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-30.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func indexes(ofItems items: [Element]) -> IndexSet?  {
        return IndexSet(self.enumerated().flatMap { items.contains($0.element) ? $0.offset : nil })
    }
}

// https://stackoverflow.com/a/33948261
extension Array {
    func objectsAtIndexes(indexes: IndexSet) -> [Element] {
        let elements: [Element] = indexes.map{ (idx) in
            if idx < self.count {
                return self[idx]
            }
            return nil
            }.flatMap{ $0 }
        return elements
    }
}

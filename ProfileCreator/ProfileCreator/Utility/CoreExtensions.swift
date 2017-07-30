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

// Found here: https://stackoverflow.com/a/42313342
extension MutableCollection where Self : RandomAccessCollection {
    /// Sort `self` in-place using criteria stored in a NSSortDescriptors array
    public mutating func sort(sortDescriptors theSortDescs: [NSSortDescriptor]) {
        sort { by:
            for sortDesc in theSortDescs {
                switch sortDesc.compare($0, to: $1) {
                case .orderedAscending: return true
                case .orderedDescending: return false
                case .orderedSame: continue
                }
            }
            return false
        }
        
    }
}

// Found here: https://stackoverflow.com/a/42313342
extension Sequence where Iterator.Element : AnyObject {
    /// Return an `Array` containing the sorted elements of `source`
    /// using criteria stored in a NSSortDescriptors array.
    
    public func sorted(sortDescriptors theSortDescs: [NSSortDescriptor]) -> [Self.Iterator.Element] {
        return sorted {
            for sortDesc in theSortDescs {
                switch sortDesc.compare($0, to: $1) {
                case .orderedAscending: return true
                case .orderedDescending: return false
                case .orderedSame: continue
                }
            }
            return false
        }
    }
}

//
//  CoreExtensions.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-30.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

// MARK: -
// MARK: Array

extension Array where Element: Equatable {
    func indexes(ofItems items: [Element]) -> IndexSet?  {
        return IndexSet(self.enumerated().compactMap { items.contains($0.element) ? $0.offset : nil })
    }
}

// From: https://stackoverflow.com/a/33948261
extension Array {
    func objectsAtIndexes(indexes: IndexSet) -> [Element] {
        let elements: [Element] = indexes.map{ (idx) in
            if idx < self.count {
                return self[idx]
            }
            return nil
            }.compactMap{ $0 }
        return elements
    }
}

// MARK: -
// MARK: Date

extension Date {
    func midnight() -> Date? {
        if
            let sourceTimeZone = NSTimeZone(abbreviation: "GMT") {
            let destinationTimeZone = NSTimeZone.system
            let interval = TimeInterval(destinationTimeZone.secondsFromGMT(for: self) - sourceTimeZone.secondsFromGMT(for: self))
            let dateInSystemTimeZone = Date(timeInterval: interval, since: self)
            var components = Calendar.current.dateComponents([.year, .month, .day], from: dateInSystemTimeZone)
            components.hour = 0
            components.minute = 0
            components.second = 0
            return Calendar.current.date(from: components)
        }
        return self
    }
}

// MARK: -
// MARK: ==

// Compare Dictionaries
public func ==(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

// Compare Dictionaries - This SHOULD be covered by the above AnyHashable but apparently not
public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func !=(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return !NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

// MARK: -
// MARK: String

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

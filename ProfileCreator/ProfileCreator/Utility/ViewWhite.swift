//
//  ViewWhite.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ViewWhite: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        self.bounds.fill()
    }
}

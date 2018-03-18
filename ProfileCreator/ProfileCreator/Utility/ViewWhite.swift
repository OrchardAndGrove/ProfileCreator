//
//  ViewWhite.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class ViewWhite: NSView {
    
    let acceptFirstResponder: Bool
    
    private weak var draggingDestination: NSDraggingDestination?
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(acceptsFirstResponder: Bool = true) {
        self.acceptFirstResponder = acceptsFirstResponder
        super.init(frame: NSZeroRect)
    }
    
    init(draggingDestination: NSDraggingDestination, draggingTypes: [NSPasteboard.PasteboardType], acceptsFirstResponder: Bool = true) {
        self.acceptFirstResponder = acceptsFirstResponder
        super.init(frame: NSZeroRect)
        self.draggingDestination = draggingDestination
        self.registerForDraggedTypes(draggingTypes)
        self.focusRingType = .default
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        self.bounds.fill()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let draggingEntered = self.draggingDestination?.draggingEntered {
            return draggingEntered(sender)
        }
        return NSDragOperation(rawValue: 0)
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        if let draggingExited = self.draggingDestination?.draggingExited{
            draggingExited(sender)
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let prepareForDragOperation = self.draggingDestination?.prepareForDragOperation {
            return prepareForDragOperation(sender)
        }
        return false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let performDragOperation = self.draggingDestination?.performDragOperation {
            return performDragOperation(sender)
        }
        return false
    }
}

// FIXME: Test to draw a focus ring orund the view. Haven't really tried much yet, should fix.
extension ViewWhite {
    
    override var acceptsFirstResponder: Bool {
        Swift.print("Class: \(self.self), Function: \(#function), acceptsFirstResponder")
        return self.acceptFirstResponder
    }
    
    override func drawFocusRingMask() {
        Swift.print("Class: \(self.self), Function: \(#function), drawFocusRingMask")
        // return __NSRectFill( self.bounds )
    }
    
    override var focusRingMaskBounds: NSRect {
        return self.bounds
    }
    
}

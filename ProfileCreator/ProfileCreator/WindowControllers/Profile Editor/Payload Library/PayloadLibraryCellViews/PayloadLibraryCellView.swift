//
//  PayloadLibraryCellView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

protocol PayloadLibraryCellView {
    
    var row: Int { get set }
    var isMovable: Bool { get set }
    
    var textFieldTitle: NSTextField? { get set }
    var textFieldDescription: NSTextField? { get set }
    var imageViewIcon: NSImageView? { get set }
    var constraintImageViewLeading: NSLayoutConstraint? { get set }
    var buttonToggle: NSButton? { get set }
    var buttonToggleIndent: CGFloat { get }
    
    func togglePayload(_ button: NSButton?)
    func addSubview(_ subview: NSView)
}

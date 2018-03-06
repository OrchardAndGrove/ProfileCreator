//
//  PayloadCellViewItemFileView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class  EditorFileView {
    
    class func view(acceptedFileUTIs: [String],
                    constraints: inout [NSLayoutConstraint],
                    cellView: PayloadCellView) -> FileView {
        
        let fileView = FileView(delegate: cellView, acceptedTypes: ["Test"], constraints: &constraints)
        cellView.addSubview(fileView)
        
        // ---------------------------------------------------------------------
        //  Setup Layout Constraings for FileView
        // ---------------------------------------------------------------------
        // Leading
        constraints.append(NSLayoutConstraint(item: fileView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: cellView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: fileView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Height
        constraints.append(NSLayoutConstraint(item: fileView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 100.0))
        
        cellView.updateHeight(100.0)

        return fileView
    }
}

class FileView: NSView {
    
    // MARK: -
    // MARK: Instance Variables
    
    var delegate: PayloadCellView?
    var acceptedTypes: [String]?
    
    let imageViewIcon = NSImageView()
    let textFieldTitle = NSTextField()
    
    // Top
    let textFieldTopContent = NSTextField()
    let textFieldTopLabel = NSTextField()
    
    // Center
    let textFieldCenterContent = NSTextField()
    let textFieldCenterLabel = NSTextField()
    
    // Bottom
    let textFieldBottomContent = NSTextField()
    let textFieldBottomLabel = NSTextField()
    
    
    let textFieldPropmpt = NSTextField()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(delegate: PayloadCellView, acceptedTypes: [String], constraints: inout [NSLayoutConstraint]) {
        super.init(frame: NSZeroRect)
        
        self.delegate = delegate
        self.acceptedTypes = acceptedTypes
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.borderWidth = 0.5
        self.layer?.borderColor = NSColor.gray.cgColor
        self.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeURL as String)])
        
        // Prompt
        setupPrompt(constraints: &constraints)
        
        // ImageView
        setupImageView(constraints: &constraints)
        
        // Title
        setupTitle(constraints: &constraints)
        
        // Description Top
        setupLabel(textField: self.textFieldTopLabel, previousLabel: nil, constraints: &constraints)
        setupContent(textField: self.textFieldTopContent, label: self.textFieldTopLabel, constraints: &constraints)
        
        // Description Center
        setupLabel(textField: self.textFieldCenterLabel, previousLabel: self.textFieldTopLabel, constraints: &constraints)
        setupContent(textField: self.textFieldCenterContent, label: self.textFieldCenterLabel, constraints: &constraints)
        
        // Description Bottom
        setupLabel(textField: self.textFieldBottomLabel, previousLabel: self.textFieldCenterLabel, constraints: &constraints)
        setupContent(textField: self.textFieldBottomContent, label: self.textFieldBottomLabel, constraints: &constraints)

        self.textFieldPropmpt.stringValue = NSLocalizedString("Add File", comment: "")
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func containsAcceptedURL(pasteboard: NSPasteboard) -> Bool {
        return pasteboard.canReadObject(forClasses: [NSURL.self], options: pasteboardReadingOptions())
    }
    
    private func pasteboardReadingOptions() -> [NSPasteboard.ReadingOptionKey: Any]? {
        return [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly : true,
                NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes : self.acceptedTypes ?? [String]()]
    }

    private func setupPrompt(constraints: inout [NSLayoutConstraint]) {
        setup(textField: self.textFieldPropmpt, fontWeight: NSFont.Weight.regular, fontSize: 15, fontColor: NSColor.tertiaryLabelColor)
        
        self.addSubview(self.textFieldPropmpt)
        
        // Center X
        constraints.append(NSLayoutConstraint(item: self.textFieldPropmpt,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Center Y
        constraints.append(NSLayoutConstraint(item: self.textFieldPropmpt,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    private func setupImageView(constraints: inout [NSLayoutConstraint]) {
        
        self.imageViewIcon.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewIcon.imageScaling = .scaleProportionallyUpOrDown
        self.imageViewIcon.setContentHuggingPriority(.required, for: .horizontal)
        
        self.addSubview(self.imageViewIcon)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.imageViewIcon,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 14.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.imageViewIcon,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 14.0))
        
        // Bottom
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.imageViewIcon,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 14.0))
        
        // Width == Height
        constraints.append(NSLayoutConstraint(item: self.imageViewIcon,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self.imageViewIcon,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    private func setupTitle(constraints: inout [NSLayoutConstraint]) {
        setup(textField: self.textFieldTitle, fontWeight: NSFont.Weight.bold, fontSize: 15, fontColor: NSColor.labelColor)
        
        self.addSubview(self.textFieldTitle)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 11.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.imageViewIcon,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 14.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
    }
    
    private func setupContent(textField: NSTextField, label: NSTextField, constraints: inout [NSLayoutConstraint]) {
        setup(textField: textField, fontWeight: NSFont.Weight.regular, fontSize: (NSFont.systemFontSize(for: .small) + 1), fontColor: NSColor.controlShadowColor)
        
        self.addSubview(textField)
        
        // Baseline
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .firstBaseline,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .firstBaseline,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
    }
    
    private func setupLabel(textField: NSTextField, previousLabel: NSTextField?, constraints: inout [NSLayoutConstraint]) {
        setup(textField: textField, fontWeight: NSFont.Weight.regular, fontSize: (NSFont.systemFontSize(for: .small) + 1), fontColor: NSColor.secondaryLabelColor)
        textField.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: (NSLayoutConstraint.Priority.defaultLow.rawValue + 1)), for: .horizontal)
        
        self.addSubview(textField)
        
        let topConstraint: CGFloat
        if previousLabel != nil {
            topConstraint = 2
            
            // Trailing
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: previousLabel,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            topConstraint = 3
        }
        
        // Top
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: previousLabel ?? self.textFieldTitle,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: topConstraint))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.imageViewIcon,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 14.0))
    }
    
    private func setup(textField: NSTextField, fontWeight: NSFont.Weight, fontSize: CGFloat, fontColor: NSColor) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byTruncatingMiddle
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
        textField.textColor = fontColor
    }
    
    // MARK: -
    // MARK: NSDraggingDestination Functions
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard().pasteboardItems?.count == 1 && self .containsAcceptedURL(pasteboard: sender.draggingPasteboard()) {
            return NSDragOperation.copy
        }
        return NSDragOperation(rawValue: 0)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.draggingPasteboard().pasteboardItems?.count == 1 && self .containsAcceptedURL(pasteboard: sender.draggingPasteboard()) {
            if let urls = sender.draggingPasteboard().readObjects(forClasses: [NSURL.self], options: nil) {
                Swift.print("Class: \(self.self), Function: \(#function), URLS: \(urls)")
            }
            return true
        }
        return false
    }
}

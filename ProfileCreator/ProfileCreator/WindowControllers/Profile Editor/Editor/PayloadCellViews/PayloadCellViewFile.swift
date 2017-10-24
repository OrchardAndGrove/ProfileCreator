//
//  PayloadCellViewFile.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewFile: NSTableCellView, ProfileCreatorCellView, PayloadCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var textFieldHost: PayloadTextField?
    var fileView: FileView?
    let buttonAdd = PayloadButton()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, settings: Dictionary<String, Any>) {
        
        self.subkey = subkey
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = subkey.title {
            self.textFieldTitle = EditorTextField.title(string: title, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self)
        }
        
        if let description = subkey.description {
            self.textFieldDescription = EditorTextField.description(string: description, constraints: &constraints, cellView: self)
        }
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.fileView = EditorFileView.view(acceptedFileUTIs: ["Test"], constraints: &constraints, cellView: self)
        addConstraintsFor(item: self.fileView!, orientation: .below, constraints: &constraints, cellView: self)
        setupButtonAdd(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.buttonAdd
        self.trailingKeyView = self.buttonAdd
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(3.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Show Prompt
        // ---------------------------------------------------------------------
        self.showPrompt(true)
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    // MARK: -
    // MARK: Private Functions
    private func showPrompt(_ show: Bool) {
        guard let fileView = self.fileView else { return }
        fileView.imageViewIcon.isHidden = show
        fileView.textFieldTitle.isHidden = show
        fileView.textFieldDescriptionTopLabel.isHidden = show
        fileView.textFieldDescriptionTop.isHidden = show
        fileView.textFieldDescriptionCenterLabel.isHidden = show
        fileView.textFieldDescriptionCenter.isHidden = show
        fileView.textFieldDescriptionBottomLabel.isHidden = show
        fileView.textFieldDescriptionBottom.isHidden = show
        fileView.textFieldPropmpt.isHidden = !show
    }
    
    // MARK: -
    // MARK: Button Actions
    
    @objc private func selectFile(_ button: NSButton) {
        Swift.print("Class: \(self.self), Function: \(#function), selectFile: \(button)")
        
        // ---------------------------------------------------------------------
        //  Get open dialog allowed file types
        // ---------------------------------------------------------------------
        // FIXME: Read these from the current settings
        var allowedFileTypes = [String]()
        
        // ---------------------------------------------------------------------
        //  Setup open dialog
        // ---------------------------------------------------------------------
        let openPanel = NSOpenPanel()
        openPanel.prompt = !self.buttonAdd.title.isEmpty ? self.buttonAdd.title : "Select File"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        
        if 0 < allowedFileTypes.count {
            openPanel.allowedFileTypes = allowedFileTypes
        }
        
        if let window = button.window {
            openPanel.beginSheetModal(for: window) { (response) in
                if response == .OK {
                    Swift.print("Class: \(self.self), Function: \(#function), Add Files To Settings: \(String(describing: openPanel.urls.first))")
                }
            }
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupButtonAdd(constraints: inout [NSLayoutConstraint]) {
        
        guard let fileView = self.fileView else { return }
        
        self.buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        self.buttonAdd.bezelStyle = .rounded
        self.buttonAdd.setButtonType(.momentaryPushIn)
        self.buttonAdd.isBordered = true
        self.buttonAdd.isTransparent = false
        self.buttonAdd.title = "Add"
        self.buttonAdd.target = self
        self.buttonAdd.action = #selector(self.selectFile(_:))
        self.buttonAdd.sizeToFit()
        self.buttonAdd.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.addSubview(self.buttonAdd)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.buttonAdd,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: fileView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        self.updateHeight((8 + self.buttonAdd.intrinsicContentSize.height))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.buttonAdd,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: self.buttonAdd,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
    }
}

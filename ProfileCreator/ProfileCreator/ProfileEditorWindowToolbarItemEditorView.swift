//
//  MainWindowToolbarItemExport.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-07.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileEditorWindowToolbarItemView: NSView {
    
    // MARK: -
    // MARK: Variables
    
    public weak var profile: Profile?
    
    let toolbarItem: NSToolbarItem
    let toolbarItemHeight: CGFloat = 32.0
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(profile: Profile, profileEditor: ProfileEditor) {
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        
        // ---------------------------------------------------------------------
        //  Create the size of the toolbar item
        // ---------------------------------------------------------------------
        let rect = NSRect(x: 0, y: 0, width: 80, height: self.toolbarItemHeight)
        
        // ---------------------------------------------------------------------
        //  Create the actual toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: .editorView)
        self.toolbarItem.toolTip = NSLocalizedString("View", comment: "")
        
        // ---------------------------------------------------------------------
        //  Initialize self after the class variables have been instantiated
        // ---------------------------------------------------------------------
        super.init(frame: rect)
        
        // ---------------------------------------------------------------------
        //  Create the button instance and add it to the toolbar item view
        // ---------------------------------------------------------------------
        self.addSubview(ProfileEditorWindowToolbarItemViewSegmentedControl(frame: rect, profileEditor: profileEditor))
        
        // ---------------------------------------------------------------------
        //  Set the toolbar item view
        // ---------------------------------------------------------------------
        self.toolbarItem.view = self
    }
}

class ProfileEditorWindowToolbarItemViewSegmentedControl: NSSegmentedControl {
    
    // MARK: -
    // MARK: Variables
    
    weak var profileEditor: ProfileEditor?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame frameRect: NSRect, profileEditor: ProfileEditor) {
        super.init(frame: frameRect)
        
        self.profileEditor = profileEditor
        
        // ---------------------------------------------------------------------
        //  Setup Self (Toolbar Item)
        // ---------------------------------------------------------------------
        self.segmentStyle = .texturedSquare
        self.segmentCount = 2
        self.trackingMode = .selectOne
        self.target = self
        self.action = #selector(self.clicked(segmentedControl:))
        
        // ---------------------------------------------------------------------
        //  Setup Segment 1 (Edit View)
        // ---------------------------------------------------------------------
        self.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 0)
        self.setWidth(36.0, forSegment: 0)
        
        if #available(OSX 10.13, *) {
            self.setTag(EditorViewTag.profileCreator.rawValue, forSegment: 0)
            self.setToolTip(NSLocalizedString("Edit", comment: ""), forSegment: 0)
        } else {
            // Fallback on earlier versions
        }
        
        if let iconEdit = NSImage(named: .init(rawValue: "edit")) {
            self.setImage(iconEdit, forSegment: 0)
        }
        
        // ---------------------------------------------------------------------
        //  Setup Segment 2 (XML View)
        // ---------------------------------------------------------------------
        self.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 1)
        self.setWidth(36.0, forSegment: 1)
        
        if #available(OSX 10.13, *) {
            self.setTag(EditorViewTag.source.rawValue, forSegment: 1)
            self.setToolTip(NSLocalizedString("XML", comment: ""), forSegment: 1)
        } else {
            // Fallback on earlier versions
        }
        
        if let iconXML = NSImage(named: .init(rawValue: "xml")) {
            self.setImage(iconXML, forSegment: 1)
        }
        
        // ---------------------------------------------------------------------
        //  Default select segment 0
        // ---------------------------------------------------------------------
        self.selectSegment(withTag: 0)
    }
    
    // MARK: -
    // MARK: Button/Menu Actions
    
    @objc func clicked(segmentedControl: NSSegmentedControl) {
        Swift.print("clicked: \(segmentedControl)")
        if let profileEditor = self.profileEditor {
            if #available(OSX 10.13, *) {
                let selectedTag = segmentedControl.tag(forSegment: segmentedControl.selectedSegment)
                profileEditor.select(view: selectedTag)
            } else {
                
            }
        }
    }
}

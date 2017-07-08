//
//  MainWindowToolbarItemExport.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-07.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowToolbarItemExport: NSView {

    // MARK: -
    // MARK: Variables
    
    let toolbarItem: NSToolbarItem
    let disclosureTriangle: NSImageView
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        
        // ---------------------------------------------------------------------
        //  Create the size of the toolbar item
        // ---------------------------------------------------------------------
        let rect = NSRect(x: 0, y: 0, width: 40, height: 32)
        
        // ---------------------------------------------------------------------
        //  Create the actual toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: MainWindowToolbarIdentifier.export)
        self.toolbarItem.toolTip = NSLocalizedString("Export profile", comment: "")
        
        // ---------------------------------------------------------------------
        //  Create the disclosure triangle overlay
        // ---------------------------------------------------------------------
        self.disclosureTriangle = NSImageView()
        self.disclosureTriangle.translatesAutoresizingMaskIntoConstraints = false
        self.disclosureTriangle.image = NSImage(named: "downarrow")
        self.disclosureTriangle.imageScaling = .scaleProportionallyUpOrDown
        self.disclosureTriangle.widthAnchor.constraint(equalToConstant: 3)
        self.disclosureTriangle.heightAnchor.constraint(equalToConstant: 3)
        self.disclosureTriangle.isHidden = true
        
        // ---------------------------------------------------------------------
        //  Initialize self after the class variables have been instantiated
        // ---------------------------------------------------------------------
        super.init(frame: rect)
        
        // ---------------------------------------------------------------------
        //  Create the button instance and add it to the toolbar item view
        // ---------------------------------------------------------------------
        self.addSubview(MainWindowToolbarItemExportButton(frame: rect))
        
        // ---------------------------------------------------------------------
        //  Add disclosure triangle to the toolbar item view
        // ---------------------------------------------------------------------
        self.addSubview(self.disclosureTriangle)
        
        // ---------------------------------------------------------------------
        //  Setup the disclosure triangle constraints
        // ---------------------------------------------------------------------
        addConstraintsForDisclosureTriangle()
        
        // ---------------------------------------------------------------------
        //  Set the toolbar item view
        // ---------------------------------------------------------------------
        self.toolbarItem.view = self
    }
    
    func disclosureTriangle(show: Bool) {
        self.disclosureTriangle.isHidden = !show
    }
    
    func addConstraintsForDisclosureTriangle() {
        var constraints = [NSLayoutConstraint]()
        
        // Width
        constraints.append(NSLayoutConstraint(
            item: self.disclosureTriangle,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 6))
        
        // Height == Width
        constraints.append(NSLayoutConstraint(
            item: self.disclosureTriangle,
            attribute: .height,
            relatedBy: .equal,
            toItem: self.disclosureTriangle,
            attribute: .width,
            multiplier: 1,
            constant: 0))
        
        // Bottom
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.disclosureTriangle,
            attribute: .bottom,
            multiplier: 1,
            constant: 5))
        
        // Trailing
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self.disclosureTriangle,
            attribute: .trailing,
            multiplier: 1,
            constant: 3))
        
        NSLayoutConstraint.activate(constraints)
    }
}

class MainWindowToolbarItemExportButton: NSButton {
    
    // MARK: -
    // MARK: Variables
    
    let buttonMenu = NSMenu()
    let menuDelay = 0.3
    
    var trackingArea: NSTrackingArea?
    var mouseIsDown = false
    var menuWasShownForLastMouseDown = false
    var mouseDownUniquenessCounter = 0
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // ---------------------------------------------------------------------
        //  Setup Self (Toolbar Item)
        // ---------------------------------------------------------------------
        self.bezelStyle = .texturedRounded
        self.image = NSImage(named: NSImageNameShareTemplate)
        self.target = self
        self.action = #selector(MainWindowToolbarItemExportButton.clicked(button:))
        self.imageScaling = .scaleProportionallyDown
        self.imagePosition = .imageOnly
        
        // ---------------------------------------------------------------------
        //  Setup the button menu
        // ---------------------------------------------------------------------
        setupButtonMenu()
    }
    
    func setupButtonMenu() {
        self.buttonMenu.delegate = self
        
        // ---------------------------------------------------------------------
        //  Add item: "Export Profile"
        // ---------------------------------------------------------------------
        let menuItemExportProfile = NSMenuItem()
        menuItemExportProfile.title = NSLocalizedString("Export Profile", comment: "")
        menuItemExportProfile.isEnabled = true
        menuItemExportProfile.target = self
        menuItemExportProfile.action = #selector(exportProfile(menuItem:))
        self.buttonMenu.addItem(menuItemExportProfile)
    }
    
    // MARK: -
    // MARK: Button/Menu Actions
    
    func clicked(button: NSButton) {
        if self.isEnabled {
            
            // -----------------------------------------------------------------
            //  If only button was clicked, call 'exportProfile'
            // -----------------------------------------------------------------
            self.exportProfile(menuItem: nil)
        }
    }
    
    func exportProfile(menuItem: NSMenuItem?) {
        Swift.print("Export Profile: \(String(describing: menuItem))")
    }
    
    // MARK: -
    // MARK: NSControl/NSResponder Methods
    
    override func mouseEntered(with event: NSEvent) {
        if let parent = self.superview, let toolbarItemExport = parent as? MainWindowToolbarItemExport {
            toolbarItemExport.disclosureTriangle(show: true)
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if !self.mouseIsDown {
            if let parent = self.superview, let toolbarItemExport = parent as? MainWindowToolbarItemExport {
                toolbarItemExport.disclosureTriangle(show: false)
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
        // ---------------------------------------------------------------------
        //  Reset mouse variables
        // ---------------------------------------------------------------------
        self.mouseIsDown = true
        self.menuWasShownForLastMouseDown = false
        self.mouseDownUniquenessCounter += 1
        let mouseDownUniquenessCounterCopy = self.mouseDownUniquenessCounter
        
        // ---------------------------------------------------------------------
        //  Show the button is being pressed
        // ---------------------------------------------------------------------
        self.highlight(true)
        
        // ---------------------------------------------------------------------
        //  Wait 'menuDelay' before showing the context menu
        //  If button has been released before time runs out, it's considered a normal button press
        // ---------------------------------------------------------------------
        DispatchQueue.main.asyncAfter(deadline: .now() + self.menuDelay) {
            if self.mouseIsDown && mouseDownUniquenessCounterCopy == self.mouseDownUniquenessCounter {
                self.menuWasShownForLastMouseDown = true
                guard let menuOrigin = self.superview?.convert(NSPoint(x: self.frame.origin.x + self.frame.size.width - 16,
                                                                       y: self.frame.origin.y + 2), to: nil) else {
                                                                        return
                }
                
                guard let event = NSEvent.mouseEvent(with: event.type,
                                                     location: menuOrigin,
                                                     modifierFlags: event.modifierFlags,
                                                     timestamp: event.timestamp,
                                                     windowNumber: event.windowNumber,
                                                     context: event.context,
                                                     eventNumber: event.eventNumber,
                                                     clickCount: event.clickCount,
                                                     pressure: event.pressure) else {
                                                        return
                }
                
                NSMenu.popUpContextMenu(self.buttonMenu, with: event, for: self)
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        
        // ---------------------------------------------------------------------
        //  Reset mouse variables
        // ---------------------------------------------------------------------
        self.mouseIsDown = false
        
        if !self.menuWasShownForLastMouseDown {
            if let parent = self.superview, let toolbarItemExport = parent as? MainWindowToolbarItemExport {
                toolbarItemExport.disclosureTriangle(show: false)
            }
            
            self.sendAction(self.action, to: self.target)
        }
        
        // ---------------------------------------------------------------------
        //  Hide the button is being pressed
        // ---------------------------------------------------------------------
        self.highlight(false)
    }
    
    // MARK: -
    // MARK: NSView Methods
    
    override func updateTrackingAreas() {
        
        // ---------------------------------------------------------------------
        //  Remove previous tracking area if it was set
        // ---------------------------------------------------------------------
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        // ---------------------------------------------------------------------
        //  Create a new tracking area
        // ---------------------------------------------------------------------
        let trackingOptions = NSTrackingAreaOptions(rawValue: (NSTrackingAreaOptions.mouseEnteredAndExited.rawValue | NSTrackingAreaOptions.activeAlways.rawValue))
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: trackingOptions, owner: self, userInfo: nil)
        
        // ---------------------------------------------------------------------
        //  Add the new tracking area to the button
        // ---------------------------------------------------------------------
        self.addTrackingArea(self.trackingArea!)
    }
}

// MARK: -
// MARK: NSMenuDelegate

extension MainWindowToolbarItemExportButton: NSMenuDelegate {
    
    func menuDidClose(_ menu: NSMenu) {
        
        // ---------------------------------------------------------------------
        //  Reset mouse variables
        // ---------------------------------------------------------------------
        self.mouseIsDown = false
        self.menuWasShownForLastMouseDown = false
        self.mouseDownUniquenessCounter = 0
        
        // ---------------------------------------------------------------------
        //  Turn of highlighting and disclosure triangle when the menu closes
        // ---------------------------------------------------------------------
        self.highlight(false)
        if let parent = self.superview, let toolbarItemExport = parent as? MainWindowToolbarItemExport {
            toolbarItemExport.disclosureTriangle(show: false)
        }
    }
}
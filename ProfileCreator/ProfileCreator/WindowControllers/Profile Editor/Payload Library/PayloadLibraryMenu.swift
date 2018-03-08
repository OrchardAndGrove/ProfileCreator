//
//  PayloadLibraryMenu.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

protocol PayloadLibrarySelectionDelegate: class {
    func selectLibrary(tag: LibraryTag, sender: Any?)
}

class PayloadLibraryMenu: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let view = NSStackView()
    var buttons = [NSButton]()
    
    var buttonAppleCollections: NSButton?
    var buttonAppleDomains: NSButton?
    var buttonApplications: NSButton?
    var buttonDeveloper: NSButton?
    
    weak var selectionDelegate: PayloadLibrarySelectionDelegate?
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup View
        // ---------------------------------------------------------------------
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.orientation = .horizontal
        self.view.alignment = .centerY
        self.view.spacing = 10
        self.view.distribution = .gravityAreas
        self.view.detachesHiddenViews = true
        
        // ---------------------------------------------------------------------
        //  Add current buttons to view
        // ---------------------------------------------------------------------
        self.updateButtons(keyPath: nil)
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryAppleCollections, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryAppleDomains, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryApplications, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryDeveloper, options: .new, context: nil)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryAppleCollections, context: nil)
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryAppleDomains, context: nil)
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryApplications, context: nil)
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryDeveloper, context: nil)
    }
    
    // MARK: -
    // MARK: Key/Value Observing Functions
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let add = change?[.newKey] as? Bool {
            if add {
                self.updateButtons(keyPath: keyPath)
                // FIXME: Keep selection here, if it isn't removed
                if let button = self.buttons.first {
                    self.selectLibrary(button)
                }
            } else if let button = self.buttonFor(keyPath: keyPath), self.view.views.contains(button) {
                self.view.removeView(button)
                self.buttons = self.buttons.filter({ $0 != button })
                // FIXME: Implement when the selection is added to the library
                
            }
        }
    }
    
    // MARK: -
    // MARK: Button Action Functions
    
    @objc func selectLibrary(_ sender: NSButton) {
        if let selectLibrary = self.selectionDelegate?.selectLibrary, let libraryTag = LibraryTag(rawValue: sender.tag) {
            selectLibrary(libraryTag, self)
            sender.state = .on
            for button in self.buttons {
                if button != sender { button.state = .off }
            }
        }
    }
    
    // MARK: -
    // MARK: Button Action Functions
    
    private func updateButtons(keyPath: String?) {
        
        // ---------------------------------------------------------------------
        //  Remove all current items from stack view
        // ---------------------------------------------------------------------
        self.buttons.removeAll()
        for view in self.view.views {
            self.view.removeView(view)
        }
        
        // ---------------------------------------------------------------------
        //  Add all enabled buttons to stack view
        // ---------------------------------------------------------------------
        let userDefaults = UserDefaults.standard
        
        // Apple Collections
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryAppleCollections) || keyPath == PreferenceKey.showPayloadLibraryAppleCollections {
            if let buttonAppleCollections = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryAppleCollections) {
                self.buttons.append(buttonAppleCollections)
                self.view.addView(buttonAppleCollections, in: .center)
            }
        }
        
        // Apple Domains
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryAppleDomains) || keyPath == PreferenceKey.showPayloadLibraryAppleDomains {
            if let buttonAppleDomains = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryAppleDomains) {
                self.buttons.append(buttonAppleDomains)
                self.view.addView(buttonAppleDomains, in: .center)
            }
        }
        
        // Applications
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryApplications) || keyPath == PreferenceKey.showPayloadLibraryApplications {
            if let buttonApplications = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryApplications) {
                self.buttons.append(buttonApplications)
                self.view.addView(buttonApplications, in: .center)
            }
        }
        
        // Developer
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryDeveloper) || keyPath == PreferenceKey.showPayloadLibraryDeveloper {
            if let buttonDeveloper = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryDeveloper) {
                self.buttons.append(buttonDeveloper)
                self.view.addView(buttonDeveloper, in: .center)
            }
        }
    }
    
    private func libraryTagFor(keyPath: String?) -> LibraryTag {
        if keyPath == PreferenceKey.showPayloadLibraryAppleCollections {
            return LibraryTag.appleCollections
        } else if keyPath == PreferenceKey.showPayloadLibraryAppleDomains {
            return LibraryTag.appleDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryApplications {
            return LibraryTag.applications
        } else if keyPath == PreferenceKey.showPayloadLibraryDeveloper {
            return LibraryTag.developer
        }
        return LibraryTag(rawValue: -1)!
    }
    
    private func buttonFor(keyPath: String?) -> NSButton? {
        
        if keyPath == PreferenceKey.showPayloadLibraryAppleCollections {
            if self.buttonAppleCollections == nil {
                if let image = NSImage(named: NSImage.Name(rawValue: "Approval-18")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "Approval Filled-18")) {
                    self.buttonAppleCollections = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue)
                }
            }
            return self.buttonAppleCollections
        } else if keyPath == PreferenceKey.showPayloadLibraryAppleDomains {
            if self.buttonAppleDomains == nil {
                if let image = NSImage(named: NSImage.Name(rawValue: "Approval-18")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "Approval Filled-18")) {
                    self.buttonAppleDomains = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue)
                }
            }
            return self.buttonAppleDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryApplications {
                if self.buttonApplications == nil {
                    if let image = NSImage(named: NSImage.Name(rawValue: "Approval-18")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "Approval Filled-18")) {
                        self.buttonApplications = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue)
                    }
                }
                return self.buttonApplications
        } else if keyPath == PreferenceKey.showPayloadLibraryDeveloper {
            if self.buttonDeveloper == nil {
                if let image = NSImage(named: NSImage.Name(rawValue: "Settings-16")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "Settings Filled-16")) {
                    self.buttonDeveloper = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue)
                }
            }
            return self.buttonDeveloper
        }
        return nil
    }
    
    private func button(image: NSImage, alternateImage: NSImage, tag: Int) -> NSButton? {
        
        guard let buttonImageTiffRep = image.tiffRepresentation else {
            // TODO: Proper Logging
            return nil
        }
        
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Create Button
        // ---------------------------------------------------------------------
        let button = NSButton()
        button.bezelStyle = .smallSquare
        button.setButtonType(.toggle)
        button.isBordered = false
        button.isTransparent = false
        button.tag = tag
        button.target = self
        button.action = #selector(self.selectLibrary(_:))
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyUpOrDown
        button.image = image
        button.alternateImage = alternateImage
        
        // ---------------------------------------------------------------------
        //  Calculate Image Size
        // ---------------------------------------------------------------------
        var width = 0, height = 0
        for imageRep in NSBitmapImageRep.imageReps(with: buttonImageTiffRep) {
            if (width < imageRep.pixelsWide) {
                width = imageRep.pixelsWide
            }
            if (height < imageRep.pixelsHigh) {
                height = imageRep.pixelsHigh
            }
        }
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Height
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: CGFloat(height)))
        
        // Width
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: CGFloat(width)))
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        return button
    }
}

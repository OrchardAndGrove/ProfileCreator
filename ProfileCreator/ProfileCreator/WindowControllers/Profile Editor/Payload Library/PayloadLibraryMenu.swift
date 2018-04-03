//
//  PayloadLibraryMenu.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2018 Erik Berglund. All rights reserved.
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
    
    var buttonAppleDomains: NSButton?
    var buttonApplicationDomains: NSButton?
    var buttonLocalApplicationDomains: NSButton?
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
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryAppleDomains, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryApplicationDomains, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryLocalApplicationDomains, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryDeveloper, options: .new, context: nil)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryAppleDomains, context: nil)
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryApplicationDomains, context: nil)
        UserDefaults.standard.removeObserver(self, forKeyPath: PreferenceKey.showPayloadLibraryLocalApplicationDomains, context: nil)
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
        
        // Apple Domains
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryAppleDomains) || keyPath == PreferenceKey.showPayloadLibraryAppleDomains {
            if let buttonAppleDomains = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryAppleDomains) {
                self.buttons.append(buttonAppleDomains)
                self.view.addView(buttonAppleDomains, in: .center)
            }
        }
        
        // Application Domains
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryApplicationDomains) || keyPath == PreferenceKey.showPayloadLibraryApplicationDomains {
            if let buttonApplicationDomains = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryApplicationDomains) {
                self.buttons.append(buttonApplicationDomains)
                self.view.addView(buttonApplicationDomains, in: .center)
            }
        }
        
        // Local Application Domains
        if userDefaults.bool(forKey: PreferenceKey.showPayloadLibraryLocalApplicationDomains) || keyPath == PreferenceKey.showPayloadLibraryLocalApplicationDomains {
            if let buttonLocalApplicationDomains = self.buttonFor(keyPath: PreferenceKey.showPayloadLibraryLocalApplicationDomains) {
                self.buttons.append(buttonLocalApplicationDomains)
                self.view.addView(buttonLocalApplicationDomains, in: .center)
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
        if keyPath == PreferenceKey.showPayloadLibraryAppleDomains {
            return LibraryTag.appleDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryApplicationDomains {
            return LibraryTag.applicationDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryLocalApplicationDomains {
            return LibraryTag.localApplicationDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryDeveloper {
            return LibraryTag.developer
        }
        return LibraryTag(rawValue: -1)!
    }
    
    private func buttonFor(keyPath: String?) -> NSButton? {
        
        if keyPath == PreferenceKey.showPayloadLibraryAppleDomains {
            if self.buttonAppleDomains == nil {
                if let image = NSImage(named: NSImage.Name(rawValue: "appleDomains")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "appleDomainsFilled")) {
                    self.buttonAppleDomains = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue, tooltip: "Apple Domains")
                }
            }
            return self.buttonAppleDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryApplicationDomains {
                if self.buttonApplicationDomains == nil {
                    if let image = NSImage(named: NSImage.Name(rawValue: "applicationDomains")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "applicationDomainsFilled")) {
                        self.buttonApplicationDomains = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue, tooltip: "Application Domains")
                    }
                }
                return self.buttonApplicationDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryLocalApplicationDomains {
            if self.buttonLocalApplicationDomains == nil {
                if let image = NSImage(named: NSImage.Name(rawValue: "localDomains")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "localDomainsFilled")) {
                    self.buttonLocalApplicationDomains = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue, tooltip: "Local Application Domains")
                }
            }
            return self.buttonLocalApplicationDomains
        } else if keyPath == PreferenceKey.showPayloadLibraryDeveloper {
            if self.buttonDeveloper == nil {
                if let image = NSImage(named: NSImage.Name(rawValue: "developerDomains")), let alternateImage = NSImage(named: NSImage.Name(rawValue: "developerDomainsFilled")) {
                    self.buttonDeveloper = self.button(image: image, alternateImage: alternateImage, tag: self.libraryTagFor(keyPath: keyPath).rawValue, tooltip: "Developer Domains")
                }
            }
            return self.buttonDeveloper
        }
        return nil
    }
    
    private func button(image: NSImage, alternateImage: NSImage, tag: Int, tooltip: String) -> NSButton? {
        
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
        button.toolTip = tooltip
        
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

//
//  PayloadLibrarySplitView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadLibrarySplitView: NSSplitView {
    
    // MARK: -
    // MARK: Variables
    
    private var tableViews: PayloadLibraryTableViews?
    private var noPayloads: PayloadLibraryNoPayloads?
    private var noPayloadsConstraints = [NSLayoutConstraint]()
    
    fileprivate let libraryView = NSView()
    fileprivate var libraryViewCollapsed: Bool = false
    
    private let libraryMenu = PayloadLibraryMenu()
    private let libraryMenuSeparator = NSBox()
    
    private var libraryMenuConstraints = [NSLayoutConstraint]()
    private var libraryPayloadsConstraints = [NSLayoutConstraint]()
    
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(profile: Profile, editor: ProfileEditor) {
        self.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.tableViews = PayloadLibraryTableViews(profile: profile, editor: editor, splitView: self)
        self.noPayloads = PayloadLibraryNoPayloads(draggingDestination: self.tableViews!, draggingTypes: [.payload])
        
        // ---------------------------------------------------------------------
        //  Setup Delegate
        // ---------------------------------------------------------------------
        self.libraryMenu.selectionDelegate = self.tableViews
        
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup SplitView
        // ---------------------------------------------------------------------
        self.identifier = NSUserInterfaceItemIdentifier(rawValue: "PayloadLibrarySplitView-ID")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dividerStyle = .thin
        self.isVertical = false
        self.delegate = self
        
        // ---------------------------------------------------------------------
        //  Add subviews to splitview
        // ---------------------------------------------------------------------
        setupSplitViewProfilePayloads(constraints: &constraints)
        setupSplitViewLibraryPayloads(constraints: &constraints)
        setupSplitViewNoPayloads(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  If library payloads is empty, need to show "No Profiles" view
        // ---------------------------------------------------------------------
        if self.tableViews!.libraryPayloads.isEmpty {
            self.noPayloads(show: true)
        }
        
        // ---------------------------------------------------------------------
        //  Select most left button in menu
        // ---------------------------------------------------------------------
        if let button = self.libraryMenu.buttons.first {
            self.libraryMenu.selectLibrary(button)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    // MARK: -
    // MARK: Instance Functions
    
    func noPayloads(show: Bool) {
        guard let noPayloadsView = self.noPayloads?.view else {
            // TODO: Proper Logging
            return
        }
        
        if show {
            if !self.libraryView.subviews.contains(noPayloadsView) {
                
                // -----------------------------------------------------------------
                //  Remove Library Payloads
                // -----------------------------------------------------------------
                self.tableViews?.libraryPayloadsScrollView.removeFromSuperview()
                
                // -----------------------------------------------------------------
                //  Insert No Payloads View and activate saved Constraints
                // -----------------------------------------------------------------
                self.libraryView.addSubview(noPayloadsView)
                NSLayoutConstraint.activate(self.noPayloadsConstraints)
            }
        } else {
            if let libraryPayloadsScrollView = self.tableViews?.libraryPayloadsScrollView,
                !self.libraryView.subviews.contains(libraryPayloadsScrollView) {
                
                // -----------------------------------------------------------------
                //  Remove No Payloads View
                // -----------------------------------------------------------------
                noPayloadsView.removeFromSuperview()
                
                // -----------------------------------------------------------------
                //  Insert Library Payloads and activate saved Constraints
                // -----------------------------------------------------------------
                self.libraryView.addSubview(libraryPayloadsScrollView)
                NSLayoutConstraint.activate(self.libraryPayloadsConstraints)
            }
        }
    }
    
    fileprivate func libraryFilter(show: Bool) {
        
        guard let editorSplitView = self.superview?.superview as? ProfileEditorSplitView else {
            // TODO: Proper Logging
            Swift.print("Class: \(self.self), Function: \(#function), Could not get ProfileEditorSplitView from: \(String(describing: self.superview))")
            return
        }
        
        // ---------------------------------------------------------------------
        //  Update internal bool to only show run this function once for each splitViewDidResizeSubviews
        // ---------------------------------------------------------------------
        self.libraryViewCollapsed = !show
        
        if show {
            
            // -----------------------------------------------------------------
            //  Tell editor split view to remove Library Menu
            // -----------------------------------------------------------------
            editorSplitView.showLibraryMenu(view: self.libraryMenu.view, show: false)
            
            // -----------------------------------------------------------------
            //  Insert Library Meny and activate saved Constraints
            // -----------------------------------------------------------------
            self.libraryView.addSubview(self.libraryMenu.view)
            NSLayoutConstraint.activate(self.libraryMenuConstraints)
            
            // -----------------------------------------------------------------
            //  Uncollapse the split view
            // -----------------------------------------------------------------
            if let libraryPayloadsScrollView = self.tableViews?.libraryPayloadsScrollView {
                self.setPosition(libraryPayloadsScrollView.contentSize.height - 108.0, ofDividerAt: 0)
            }
        } else {
            
            // -----------------------------------------------------------------
            //  Remove Library Menu
            // -----------------------------------------------------------------
            self.libraryMenu.view.removeFromSuperview()
            
            // -----------------------------------------------------------------
            //  Tell editor split view to add Library Menu in place of the Filter View
            // -----------------------------------------------------------------
            editorSplitView.showLibraryMenu(view: self.libraryMenu.view, show: true)
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupSplitViewProfilePayloads(constraints: inout [NSLayoutConstraint]) {
        
        if let profilePayloadsScrollView = self.tableViews?.profilePayloadsScrollView {
            self.addSubview(profilePayloadsScrollView)
            self.setHoldingPriority(NSLayoutConstraint.Priority.defaultLow, forSubviewAt: 0)
            
            // ---------------------------------------------------------------------
            //  Add constraints
            // ---------------------------------------------------------------------
            
            // Height Min
            constraints.append(NSLayoutConstraint(item: profilePayloadsScrollView,
                                                  attribute: .height,
                                                  relatedBy: .greaterThanOrEqual,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 96))
        }
    }
    
    private func setupSplitViewLibraryPayloads(constraints: inout [NSLayoutConstraint]) {
        
        if let libraryPayloadsScrollView = self.tableViews?.libraryPayloadsScrollView {
            
            // ---------------------------------------------------------------------
            //  Setup Library View
            // ---------------------------------------------------------------------
            self.libraryView.translatesAutoresizingMaskIntoConstraints = false
            
            // ---------------------------------------------------------------------
            //  Add Menu to Library View
            // ---------------------------------------------------------------------
            self.libraryView.addSubview(self.libraryMenu.view)
            
            // ---------------------------------------------------------------------
            //  Setup constraints for Menu
            // ---------------------------------------------------------------------
            // Height
            self.libraryMenuConstraints.append(NSLayoutConstraint(item: self.libraryMenu.view,
                                                                  attribute: .height,
                                                                  relatedBy: .equal,
                                                                  toItem: nil,
                                                                  attribute: .notAnAttribute,
                                                                  multiplier: 1,
                                                                  constant: 27))
            
            // Top
            self.libraryMenuConstraints.append(NSLayoutConstraint(item: self.libraryMenu.view,
                                                                  attribute: .top,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryView,
                                                                  attribute: .top,
                                                                  multiplier: 1,
                                                                  constant: 0))
            
            // Leading
            self.libraryMenuConstraints.append(NSLayoutConstraint(item: self.libraryMenu.view,
                                                                  attribute: .leading,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryView,
                                                                  attribute: .leading,
                                                                  multiplier: 1,
                                                                  constant: 0))
            
            // Trailing
            self.libraryMenuConstraints.append(NSLayoutConstraint(item: self.libraryMenu.view,
                                                                  attribute: .trailing,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryView,
                                                                  attribute: .trailing,
                                                                  multiplier: 1,
                                                                  constant: 0))
            
            // ---------------------------------------------------------------------
            //  Setup and add separator line between Menu and TableView
            // ---------------------------------------------------------------------
            self.libraryMenuSeparator.translatesAutoresizingMaskIntoConstraints = false
            self.libraryMenuSeparator.boxType = .separator
            self.libraryView.addSubview(self.libraryMenuSeparator)
            
            // ---------------------------------------------------------------------
            //  Setup constraints for separator line
            // ---------------------------------------------------------------------
            // Top
            self.libraryMenuConstraints.append(NSLayoutConstraint(item: self.libraryMenu.view,
                                                                  attribute: .bottom,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryMenuSeparator,
                                                                  attribute: .top,
                                                                  multiplier: 1,
                                                                  constant: 0))
            
            constraints.append(contentsOf: self.libraryMenuConstraints)
            
            // Leading
            constraints.append(NSLayoutConstraint(item: self.libraryMenuSeparator,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: self.libraryView,
                                                  attribute: .leading,
                                                  multiplier: 1,
                                                  constant: 0))
            
            // Trailing
            constraints.append(NSLayoutConstraint(item: self.libraryMenuSeparator,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: self.libraryView,
                                                  attribute: .trailing,
                                                  multiplier: 1,
                                                  constant: 0))
            
            // ---------------------------------------------------------------------
            //  Add TableView to Library View
            // ---------------------------------------------------------------------
            self.libraryView.addSubview(libraryPayloadsScrollView)
            
            
            // ---------------------------------------------------------------------
            //  Add constraints
            // ---------------------------------------------------------------------
            // Top
            self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: self.libraryMenuSeparator,
                                                                      attribute: .bottom,
                                                                      relatedBy: .equal,
                                                                      toItem: libraryPayloadsScrollView,
                                                                      attribute: .top,
                                                                      multiplier: 1,
                                                                      constant: 0))
            
            // Height Min
            self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: libraryPayloadsScrollView,
                                                                      attribute: .height,
                                                                      relatedBy: .greaterThanOrEqual,
                                                                      toItem: nil,
                                                                      attribute: .notAnAttribute,
                                                                      multiplier: 1,
                                                                      constant: 80))
            
            // Leading
            self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: libraryPayloadsScrollView,
                                                                      attribute: .leading,
                                                                      relatedBy: .equal,
                                                                      toItem: self.libraryView,
                                                                      attribute: .leading,
                                                                      multiplier: 1,
                                                                      constant: 0))
            
            // Trailing
            self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: libraryPayloadsScrollView,
                                                                      attribute: .trailing,
                                                                      relatedBy: .equal,
                                                                      toItem: self.libraryView,
                                                                      attribute: .trailing,
                                                                      multiplier: 1,
                                                                      constant: 0))
            
            // Bottom
            self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: libraryPayloadsScrollView,
                                                                      attribute: .bottom,
                                                                      relatedBy: .equal,
                                                                      toItem: self.libraryView,
                                                                      attribute: .bottom,
                                                                      multiplier: 1,
                                                                      constant: 0))
            
            constraints.append(contentsOf: self.libraryPayloadsConstraints)
            
            self.addSubview(self.libraryView)
            self.setHoldingPriority(NSLayoutConstraint.Priority.defaultLow, forSubviewAt: 1)
        }
    }
    
    private func setupSplitViewNoPayloads(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        if let noPayloadsView = self.noPayloads?.view {
            
            // Top
            self.noPayloadsConstraints.append(NSLayoutConstraint(item: self.libraryMenuSeparator,
                                                                 attribute: .bottom,
                                                                 relatedBy: .equal,
                                                                 toItem: noPayloadsView,
                                                                 attribute: .top,
                                                                 multiplier: 1.0,
                                                                 constant: 0))
            
            // Height
            self.noPayloadsConstraints.append(NSLayoutConstraint(item: noPayloadsView,
                                                                 attribute: .height,
                                                                 relatedBy: .greaterThanOrEqual,
                                                                 toItem: nil,
                                                                 attribute: .notAnAttribute,
                                                                 multiplier: 1.0,
                                                                 constant: 80))
            
            // Leading
            self.noPayloadsConstraints.append(NSLayoutConstraint(item: noPayloadsView,
                                                                 attribute: .leading,
                                                                 relatedBy: .equal,
                                                                 toItem: self.libraryView,
                                                                 attribute: .leading,
                                                                 multiplier: 1,
                                                                 constant: 0))
            
            // Trailing
            self.noPayloadsConstraints.append(NSLayoutConstraint(item: noPayloadsView,
                                                                 attribute: .trailing,
                                                                 relatedBy: .equal,
                                                                 toItem: self.libraryView,
                                                                 attribute: .trailing,
                                                                 multiplier: 1,
                                                                 constant: 0))
            
            // Bottom
            self.noPayloadsConstraints.append(NSLayoutConstraint(item: noPayloadsView,
                                                                 attribute: .bottom,
                                                                 relatedBy: .equal,
                                                                 toItem: self.libraryView,
                                                                 attribute: .bottom,
                                                                 multiplier: 1,
                                                                 constant: 0))
        }
    }
}

extension PayloadLibrarySplitView: NSSplitViewDelegate {
    
    /*
     ///////////////////////////////////////////////////////////////////////////////
     ////////////                        WARNING                        ////////////
     ///////////////////////////////////////////////////////////////////////////////
     
     Don't use any of the following NSSPlitView delegate methods as they don't
     work with AutoLayout.
     
     splitView:constrainMinCoordinate:ofSubviewAt:
     splitView:constrainMaxCoordinate:ofSubviewAt:
     splitView:resizeSubviewsWithOldSize:
     splitView:shouldAdjustSizeOfSubview:
     
     https://developer.apple.com/library/mac/releasenotes/AppKit/RN-AppKitOlderNotes/#10_8AutoLayout
     */
    
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        
        // -------------------------------------------------------------------------
        //  Allow Library Payloads to be collapsed
        // -------------------------------------------------------------------------
        if subview == splitView.subviews.last {
            return true
        }
        return false
    }
    
    func splitViewDidResizeSubviews(_ notification: Notification) {
        if !self.libraryViewCollapsed && self.isSubviewCollapsed(self.libraryView) {
            self.libraryFilter(show: false)
        } else if self.libraryViewCollapsed && !isSubviewCollapsed(self.libraryView) {
            self.libraryFilter(show: true)
        }
    }
}

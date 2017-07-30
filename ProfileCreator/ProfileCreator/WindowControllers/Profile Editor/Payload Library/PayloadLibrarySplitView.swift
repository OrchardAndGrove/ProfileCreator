//
//  PayloadLibrarySplitView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadLibrarySplitView: NSSplitView {
    
    // MARK: -
    // MARK: Variables
    
    private let tableViews = PayloadLibraryTableViews()
    private let noPayloads = PayloadLibraryNoPayloads()
    private var noPayloadsHidden: Bool = true
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
    
    convenience init(profile: Profile) {
        self.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup SplitView
        // ---------------------------------------------------------------------
        self.identifier = "PayloadLibrarySplitView-ID"
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
        if self.tableViews.libraryPayloads.isEmpty {
            self.noPayloads(show: true)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    // MARK: -
    // MARK: Instance Functions
    
    func noPayloads(show: Bool) {
        
        self.noPayloadsHidden = !show
        
        if show {
            
            // -----------------------------------------------------------------
            //  Remove Library Payloads
            // -----------------------------------------------------------------
            self.tableViews.libraryPayloadsScrollView.removeFromSuperview()
            
            // -----------------------------------------------------------------
            //  Insert No Payloads View and activate saved Constraints
            // -----------------------------------------------------------------
            self.libraryView.addSubview(self.noPayloads.view)
            NSLayoutConstraint.activate(self.noPayloadsConstraints)
        } else {
            
            // -----------------------------------------------------------------
            //  Remove No Payloads View
            // -----------------------------------------------------------------
            self.noPayloads.view.removeFromSuperview()
            
            // -----------------------------------------------------------------
            //  Insert Library Payloads and activate saved Constraints
            // -----------------------------------------------------------------
            self.libraryView.addSubview(self.tableViews.libraryPayloadsScrollView)
            NSLayoutConstraint.activate(self.libraryPayloadsConstraints)
        }
    }
    
    fileprivate func libraryFilter(show: Bool) {
        
        guard let editorSplitView = self.superview?.superview as? ProfileEditorSplitView else {
            // TODO: Proper Logging
            Swift.print("Could not get ProfileEditorSplitView from: \(String(describing: self.superview))")
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
            self.setPosition(self.tableViews.libraryPayloadsScrollView.contentSize.height - 108.0, ofDividerAt: 0)
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
        
        self.addSubview(self.tableViews.profilePayloadsScrollView)
        self.setHoldingPriority(NSLayoutPriorityDefaultLow, forSubviewAt: 0)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Height Min
        constraints.append(NSLayoutConstraint(item: self.tableViews.profilePayloadsScrollView,
                                              attribute: .height,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 96))
    }
    
    private func setupSplitViewLibraryPayloads(constraints: inout [NSLayoutConstraint]) {
        
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
        self.libraryView.addSubview(self.tableViews.libraryPayloadsScrollView)
        
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: self.libraryMenuSeparator,
                                                                  attribute: .bottom,
                                                                  relatedBy: .equal,
                                                                  toItem: self.tableViews.libraryPayloadsScrollView,
                                                                  attribute: .top,
                                                                  multiplier: 1,
                                                                  constant: 0))
        
        // Height Min
        self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: self.tableViews.libraryPayloadsScrollView,
                                                                  attribute: .height,
                                                                  relatedBy: .greaterThanOrEqual,
                                                                  toItem: nil,
                                                                  attribute: .notAnAttribute,
                                                                  multiplier: 1,
                                                                  constant: 80))
        
        // Leading
        self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: self.tableViews.libraryPayloadsScrollView,
                                                                  attribute: .leading,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryView,
                                                                  attribute: .leading,
                                                                  multiplier: 1,
                                                                  constant: 0))
        
        // Trailing
        self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: self.tableViews.libraryPayloadsScrollView,
                                                                  attribute: .trailing,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryView,
                                                                  attribute: .trailing,
                                                                  multiplier: 1,
                                                                  constant: 0))
        
        // Bottom
        self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: self.tableViews.libraryPayloadsScrollView,
                                                                  attribute: .bottom,
                                                                  relatedBy: .equal,
                                                                  toItem: self.libraryView,
                                                                  attribute: .bottom,
                                                                  multiplier: 1,
                                                                  constant: 0))
        
        constraints.append(contentsOf: self.libraryPayloadsConstraints)
        
        self.addSubview(self.libraryView)
        self.setHoldingPriority(NSLayoutPriorityDefaultLow, forSubviewAt: 1)
    }
    
    private func setupSplitViewNoPayloads(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Top
        self.noPayloadsConstraints.append(NSLayoutConstraint(item: self.libraryMenuSeparator,
                                                             attribute: .bottom,
                                                             relatedBy: .equal,
                                                             toItem: self.noPayloads.view,
                                                             attribute: .top,
                                                             multiplier: 1.0,
                                                             constant: 0))
        
        // Height
        self.noPayloadsConstraints.append(NSLayoutConstraint(item: self.noPayloads.view,
                                                             attribute: .height,
                                                             relatedBy: .greaterThanOrEqual,
                                                             toItem: nil,
                                                             attribute: .notAnAttribute,
                                                             multiplier: 1.0,
                                                             constant: 80))
        
        // Leading
        self.noPayloadsConstraints.append(NSLayoutConstraint(item: self.noPayloads.view,
                                                             attribute: .leading,
                                                             relatedBy: .equal,
                                                             toItem: self.libraryView,
                                                             attribute: .leading,
                                                             multiplier: 1,
                                                             constant: 0))
        
        // Trailing
        self.noPayloadsConstraints.append(NSLayoutConstraint(item: self.noPayloads.view,
                                                             attribute: .trailing,
                                                             relatedBy: .equal,
                                                             toItem: self.libraryView,
                                                             attribute: .trailing,
                                                             multiplier: 1,
                                                             constant: 0))
        
        // Bottom
        self.noPayloadsConstraints.append(NSLayoutConstraint(item: self.noPayloads.view,
                                                             attribute: .bottom,
                                                             relatedBy: .equal,
                                                             toItem: self.libraryView,
                                                             attribute: .bottom,
                                                             multiplier: 1,
                                                             constant: 0))
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

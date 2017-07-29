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
    
    private let libraryView = NSView()
    private let libraryMenu = PayloadLibraryMenu()
    
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
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
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
        let line = NSBox()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.boxType = .separator
        self.libraryView.addSubview(line)
        
        // ---------------------------------------------------------------------
        //  Setup constraints for separator line
        // ---------------------------------------------------------------------
        // Top
        self.libraryMenuConstraints.append(NSLayoutConstraint(item: self.libraryMenu.view,
                                                              attribute: .bottom,
                                                              relatedBy: .equal,
                                                              toItem: line,
                                                              attribute: .top,
                                                              multiplier: 1,
                                                              constant: 0))
        
        constraints.append(contentsOf: self.libraryMenuConstraints)
        
        // Leading
        constraints.append(NSLayoutConstraint(item: line,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.libraryView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: line,
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
        self.libraryPayloadsConstraints.append(NSLayoutConstraint(item: line,
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
        
        // ---------------------------------------------------------------------
        //  Allow left view (SIDEBAR) to be collapsed
        // ---------------------------------------------------------------------
        if subview == splitView.subviews.last {
            return true
        }
        return false
    }
    
    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        
        // ---------------------------------------------------------------------
        //  Hide left divider if left view is collapsed
        // ---------------------------------------------------------------------
        // TODO: Use this if we add a button to show/hide the sidebar. For now, leave the divider visible
        /*
         if dividerIndex == 0 {
         return splitView.isSubviewCollapsed(splitView.subviews.first!)
         }
         */
        return false
    }
}

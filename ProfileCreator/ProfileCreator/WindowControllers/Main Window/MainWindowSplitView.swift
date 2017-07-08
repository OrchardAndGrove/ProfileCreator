//
//  MainWindowSplitView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-08.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowSplitView: NSSplitView {
    
    // MARK: -
    // MARK: Variables
    
    let outlineViewController = MainWindowOutlineViewController()
    let tableViewController = MainWindowTableViewController()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // ---------------------------------------------------------------------
        //  Setup SplitView
        // ---------------------------------------------------------------------
        self.identifier = "MainWindowSplitView-ID"
        self.autosaveName = "MainWindowSplitView-AS"
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dividerStyle = .thin
        self.isVertical = true
        self.delegate = self
        
        // ---------------------------------------------------------------------
        //  Add subviews to splitview
        // ---------------------------------------------------------------------
        self.addSubview(outlineViewController.scrollView)
        self.setHoldingPriority((NSLayoutPriorityDefaultLow + 1), forSubviewAt: 0)
        self.addSubview(tableViewController.scrollView)
        self.setHoldingPriority(NSLayoutPriorityDefaultLow, forSubviewAt: 1)
        
        // ---------------------------------------------------------------------
        //  Setup views in splitview
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        setupSplitViewLeft(constraints: &constraints)
        setupSplitViewCenter(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    // MARK: Layout Constraints
    
    func setupSplitViewLeft(constraints: inout [NSLayoutConstraint]) {
        
        // Min Width
        constraints.append(NSLayoutConstraint(item: self.outlineViewController.scrollView,
                                              attribute: .width,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 150))
        
        // Max Width
        constraints.append(NSLayoutConstraint(item: self.outlineViewController.scrollView,
                                              attribute: .width,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 300))
        
    }
    
    func setupSplitViewCenter(constraints: inout [NSLayoutConstraint]) {
        
        // Min Width
        constraints.append(NSLayoutConstraint(item: self.tableViewController.scrollView,
                                              attribute: .width,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 150))
        
        // Max Width
        constraints.append(NSLayoutConstraint(item: self.tableViewController.scrollView,
                                              attribute: .width,
                                              relatedBy: .lessThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 300))
        
    }
}

extension MainWindowSplitView: NSSplitViewDelegate {
    
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
        //  Allow left view (SIDEBAR) to be collapsed
        // -------------------------------------------------------------------------
        if subview == splitView.subviews.first && splitView.subviews.contains(self.tableViewController.scrollView) {
            return true
        }
        return false
    }
    
    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        
        // -------------------------------------------------------------------------
        //  Hide left divider if left view is collapsed
        // -------------------------------------------------------------------------
        if dividerIndex == 0 {
            return splitView.isSubviewCollapsed(splitView.subviews.first!)
        }
        return false
    }
}

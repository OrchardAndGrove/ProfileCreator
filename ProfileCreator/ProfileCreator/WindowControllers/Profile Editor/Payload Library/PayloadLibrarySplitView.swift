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
        //setupSplitViewLibraryPayloads(constraints: &constraints)
        
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
        
        // Height
        constraints.append(NSLayoutConstraint(item: self.tableViews.profilePayloadsScrollView,
                                              attribute: .height,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 96))
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
        //if subview == splitView.subviews.first && splitView.subviews.contains(self.tableViewController.scrollView) {
        return true
        //}
        //return false
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

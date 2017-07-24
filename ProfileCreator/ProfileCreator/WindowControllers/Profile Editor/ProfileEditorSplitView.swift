//
//  ProfileEditorSplitView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-21.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileEditorSplitView: NSSplitView {

    // MARK: -
    // MARK: Variables
    
    //let outlineViewController = MainWindowOutlineViewController()
    //let tableViewController = MainWindowTableViewController()
    //let profilePreviewController = MainWindowProfilePreviewController()
    //let welcomeViewController = MainWindowWelcomeViewController()
    
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
        self.identifier = "ProfileEditorSplitView-ID"
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dividerStyle = .thin
        self.isVertical = true
        self.delegate = self
    }
}

extension ProfileEditorSplitView: NSSplitViewDelegate {
    
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


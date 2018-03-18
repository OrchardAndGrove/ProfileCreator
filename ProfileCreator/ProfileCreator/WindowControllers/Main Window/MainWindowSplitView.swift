//
//  MainWindowSplitView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-08.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowSplitView: NSSplitView {
    
    // MARK: -
    // MARK: Variables
    
    let outlineViewController = MainWindowOutlineViewController()
    let tableViewController = MainWindowTableViewController()
    let profilePreviewController = MainWindowProfilePreviewController()
    let welcomeViewController = MainWindowWelcomeViewController()
    
    var autoSavePosition0: CGFloat = 150.0
    var autoSavePosition1: CGFloat = 0.0
    
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
        self.identifier = NSUserInterfaceItemIdentifier(rawValue: "MainWindowSplitView-ID")
        self.autosaveName = NSSplitView.AutosaveName(rawValue: "MainWindowSplitView-AS")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dividerStyle = .thin
        self.isVertical = true
        self.delegate = self
        
        // ---------------------------------------------------------------------
        //  Get AutoSave Positions for SplitView Separatos
        // ---------------------------------------------------------------------
        self.getAutoSavePositions()
        
        // ---------------------------------------------------------------------
        //  Add subviews to splitview
        // ---------------------------------------------------------------------
        self.addSubview(outlineViewController.scrollView)
        self.setHoldingPriority((NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.RawValue(Int(NSLayoutConstraint.Priority.defaultLow.rawValue) + 1))), forSubviewAt: 0)
        self.addSubview(tableViewController.scrollView)
        self.setHoldingPriority(NSLayoutConstraint.Priority.defaultLow, forSubviewAt: 1)
        self.addSubview(profilePreviewController.view)
        self.setHoldingPriority((NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.RawValue(Int(NSLayoutConstraint.Priority.defaultLow.rawValue) - 1))), forSubviewAt: 1)
        
        // ---------------------------------------------------------------------
        //  Setup views in splitview
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        setupSplitViewSidebar(constraints: &constraints)
        setupSplitViewProfileList(constraints: &constraints)
        setupSplitViewProfilePreview(constraints: &constraints)
        setupSplitViewWelcomeView(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Setup delegate connections
        // ---------------------------------------------------------------------
        self.outlineViewController.selectionDelegate = self.tableViewController
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(noProfileConfigured(_:)), name: .noProfileConfigured, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddProfile(_:)), name: .didAddProfile, object: nil)
        
        // ---------------------------------------------------------------------
        //  Select "All Profiles"
        // ---------------------------------------------------------------------
        self.outlineViewController.outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
        
        // ---------------------------------------------------------------------
        //  If no profile identifiers are loaded, show welcome view
        // ---------------------------------------------------------------------
        if ProfileController.sharedInstance.profiles.count == 0 {
            self.noProfileConfigured(nil)
        }
        
        // ---------------------------------------------------------------------
        //  Restore AutoSaved positions, as this isn't done automatically when using AutoLayout
        // ---------------------------------------------------------------------
        // TODO: Fix the restore. It seems it has to be done from the SplitViewController
        // But to use that this whole implementation has to change. This need to be tested later
        //self.setPosition(150.0, ofDividerAt: 0)
        //self.setPosition(150.0, ofDividerAt: 0)
        //
        
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.setPosition(self.autoSavePosition0, ofDividerAt: 0)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .noProfileConfigured, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didAddProfile, object: nil)
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    @objc func noProfileConfigured(_ notification: NSNotification?) {
        if !self.subviews.contains(self.welcomeViewController.view) {
            self.tableViewController.scrollView.removeFromSuperview()
            self.profilePreviewController.view.removeFromSuperview()
            self.addSubview(self.welcomeViewController.view)
            self.setHoldingPriority(NSLayoutConstraint.Priority.defaultLow, forSubviewAt: 1)
            
            // -----------------------------------------------------------------
            //  Remove the internal selection state
            // -----------------------------------------------------------------
            // TODO: This should probably be handled elsewhere. Feels like a bug.
            self.tableViewController.selectedProfileIdentitifers = nil
        }
    }
    
    @objc func didAddProfile(_ notification: NSNotification?) {
        if !self.subviews.contains(self.tableViewController.scrollView) {
            self.welcomeViewController.view.removeFromSuperview()
            self.addSubview(self.tableViewController.scrollView)
            self.setHoldingPriority(NSLayoutConstraint.Priority.defaultLow, forSubviewAt: 1)
            self.addSubview(self.profilePreviewController.view)
            self.setHoldingPriority((NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.RawValue(Int(NSLayoutConstraint.Priority.defaultLow.rawValue) - 1)) ), forSubviewAt: 2)
            
            // -----------------------------------------------------------------
            //  Select the newly created profile
            // -----------------------------------------------------------------
            self.tableViewController.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupSplitViewSidebar(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
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
    
    private func setupSplitViewProfileList(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
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
    
    private func setupSplitViewProfilePreview(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Min Width
        constraints.append(NSLayoutConstraint(item: self.profilePreviewController.view,
                                              attribute: .width,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 260))
    }
    
    private func setupSplitViewWelcomeView(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Min Width
        constraints.append(NSLayoutConstraint(item: self.welcomeViewController.view,
                                              attribute: .width,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 400))
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
        
        // ---------------------------------------------------------------------
        //  Allow left view (SIDEBAR) to be collapsed
        // ---------------------------------------------------------------------
        if subview == splitView.subviews.first && splitView.subviews.contains(self.tableViewController.scrollView) {
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



// https://stackoverflow.com/a/42014989

extension MainWindowSplitView {
    
    /*
     ** unfortunately this needs to be called in the controller's viewDidAppear function as
     ** auto layout kicks in to override any default values after the split view's awakeFromNib
     */
    func getAutoSavePositions() {
        let key = String(format: "NSSplitView Subview Frames %@", self.autosaveName! as CVarArg)
        let subViewFrames = UserDefaults.standard.array(forKey: key)
        guard subViewFrames != nil else { return }

        for (i, frame) in (subViewFrames?.enumerated())! {
            if let frameString = frame as? String {
                
                let components = frameString.components(separatedBy: ", ")
                guard components.count >= 4 else { return }
                
                var position: CGFloat = 0.0
                
                // Manage the 'hidden state' per view
                // let hidden = NSString(string:components[4].lowercased()).boolValue
                // let subView = self.subviews[i]
                //subView.isHidden = hidden
                
                // Set height (horizontal) or width (vertical)
                if self.isVertical {
                    if let width = Float(components[2]) {
                        position = position + CGFloat(width)
                        //subView.setFrameSize(NSSize.init(width: position, height: subView.frame.size.height))
                    }
                }
                
                if i == 0 {
                    self.autoSavePosition0 = position
                }
                // Swift.print("Class: \(self.self), Function: \(#function), Set position: \(position) of divider: \(i)")
                // setPosition(position, ofDividerAt: i)
            }
        }
    }
    
    /*
    func restoreAutoSavePositions(forSubviews subviews: [Int]?) {
        let key = String(format: "NSSplitView Subview Frames %@", self.autosaveName! as CVarArg)
        let subViewFrames = UserDefaults.standard.array(forKey: key)
        guard subViewFrames != nil else { return }
        
        for (i, frame) in (subViewFrames?.enumerated())! {
            if let subviewIndexes = subviews, !subviewIndexes.contains(i) {
                Swift.print("Will not reset for view at index: \(i)")
                continue
            }
            Swift.print("i: \(i)")
            Swift.print("frame: \(frame)")
            if let frameString = frame as? String {
                
                let components = frameString.components(separatedBy: ", ")
                guard components.count >= 4 else { return }
                
                var position: CGFloat = 0.0
                
                // Manage the 'hidden state' per view
                // let hidden = NSString(string:components[4].lowercased()).boolValue
                // let subView = self.subviews[i]
                //subView.isHidden = hidden
                
                // Set height (horizontal) or width (vertical)
                if self.isVertical {
                    if let width = Float(components[2]) {
                        Swift.print("width: \(width)")
                        position = position + CGFloat(width)
                        //subView.setFrameSize(NSSize.init(width: position, height: subView.frame.size.height))
                    }
                } else {
                    if let height = Float(components[3]) {
                        position = CGFloat(height)
                        //subView.setFrameSize(NSSize.init(width: subView.frame.size.width , height:position ))
                    }
                }
                
                Swift.print("Class: \(self.self), Function: \(#function), Set position: \(position) of divider: \(i)")
                setPosition(position, ofDividerAt: i)
            }
        }
    }
    */
}

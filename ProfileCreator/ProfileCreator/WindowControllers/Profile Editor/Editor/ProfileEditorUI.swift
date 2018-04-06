//
//  ProfileEditorUI.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-02-12.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

extension ProfileEditor {
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    internal func setupEditorView(constraints: inout [NSLayoutConstraint]) {
        self.editorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal func setupHeaderView(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add and setup Header View
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.headerView.headerView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: self.headerView.headerView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 30.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.headerView.headerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.editorView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.headerView.headerView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    internal func setupSeparator(constraints: inout [NSLayoutConstraint]) {
        self.separator.translatesAutoresizingMaskIntoConstraints = false
        self.separator.boxType = .separator
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.separator)
        
        // ---------------------------------------------------------------------
        //  Add Constraints
        // ---------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.separator,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.headerView.headerView,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.separator,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0.0)) // 20.0
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.editorView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.separator,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0.0)) // 20.0
        
    }
    
    func setupTextView(constraints: inout [NSLayoutConstraint]) {
        self.textView.minSize = NSSize(width: 0, height: 0)
        self.textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        self.textView.isVerticallyResizable = true
        self.textView.isHorizontallyResizable = true
        self.textView.drawsBackground = false
        self.textView.isEditable = false
        self.textView.isSelectable = true
        
        self.textView.font = NSFont(name: "Menlo Regular", size: NSFont.systemFontSize(for: .regular))
        self.textView.textColor = .controlTextColor
        self.textView.string = "This is a test string"
        
        self.textView.textContainerInset = NSSize(width: 50, height: 30)
        
        // Use old resizing masks until I know how to replicate with AutoLayout.
        self.textView.autoresizingMask = .width
        
        self.textView.textContainer?.containerSize = NSSize(width: self.scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        self.textView.textContainer?.heightTracksTextView = false
    }
    
    internal func setupTableView(profile: Profile, constraints: inout [NSLayoutConstraint]) {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.floatsGroupRows = false
        self.tableView.rowSizeStyle = .default
        self.tableView.headerView = nil
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.target = self
        self.tableView.allowsMultipleSelection = true
        self.tableView.selectionHighlightStyle = .none
        self.tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        self.tableView.sizeLastColumnToFit()
        self.tableView.refusesFirstResponder = true
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Leading
        // ---------------------------------------------------------------------
        let tableColumnPaddingLeading = NSTableColumn(identifier: .tableColumnPaddingLeading)
        tableColumnPaddingLeading.isEditable = false
        tableColumnPaddingLeading.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingLeading.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingLeading)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Disable Leading
        // ---------------------------------------------------------------------
        if profile.editorColumnEnable {
            let tableColumnPayloadEnable = NSTableColumn(identifier: .tableColumnPayloadEnableLeading)
            tableColumnPayloadEnable.isEditable = false
            tableColumnPayloadEnable.width = 20.0
            tableColumnPayloadEnable.minWidth = 20.0
            tableColumnPayloadEnable.maxWidth = 20.0
            self.tableView.addTableColumn(tableColumnPayloadEnable)
        }
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Payload
        // ---------------------------------------------------------------------
        let tableColumnPayload = NSTableColumn(identifier: .tableColumnPayload)
        tableColumnPayload.isEditable = false
        tableColumnPayload.width = editorTableViewColumnPayloadWidth
        tableColumnPayload.minWidth = editorTableViewColumnPayloadWidth
        tableColumnPayload.maxWidth = editorTableViewColumnPayloadWidth
        self.tableView.addTableColumn(tableColumnPayload)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Disable Trailing
        // ---------------------------------------------------------------------
        if profile.editorColumnEnable {
            let tableColumnPayloadEnable = NSTableColumn(identifier: .tableColumnPayloadEnableTrailing)
            tableColumnPayloadEnable.isEditable = false
            tableColumnPayloadEnable.width = 20.0
            tableColumnPayloadEnable.minWidth = 20.0
            tableColumnPayloadEnable.maxWidth = 20.0
            self.tableView.addTableColumn(tableColumnPayloadEnable)
        }
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Trailing
        // ---------------------------------------------------------------------
        let tableColumnPaddingTrailing = NSTableColumn(identifier: .tableColumnPaddingTrailing)
        tableColumnPaddingTrailing.isEditable = false
        tableColumnPaddingTrailing.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingTrailing.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingTrailing)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView and add TableView as Document View
        // ---------------------------------------------------------------------
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        // self.scrollView.hasVerticalScroller = true
        self.scrollView.documentView = self.tableView
        // self.scrollView.autoresizesSubviews = true
        
        // ---------------------------------------------------------------------
        //  Add and setup ScrollView
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.scrollView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        self.constraintScrollViewTopSeparator = NSLayoutConstraint(item: self.scrollView,
                                                                   attribute: .top,
                                                                   relatedBy: .equal,
                                                                   toItem: self.separator,
                                                                   attribute: .bottom,
                                                                   multiplier: 1.0,
                                                                   constant: 0.0)
        constraints.append(self.constraintScrollViewTopSeparator)
        
        self.constraintScrollViewTopTab = NSLayoutConstraint(item: self.scrollView,
                                                             attribute: .top,
                                                             relatedBy: .equal,
                                                             toItem: self.tabView,
                                                             attribute: .bottom,
                                                             multiplier: 1.0,
                                                             constant: 0.0)
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.scrollView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.editorView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.scrollView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Bottom
        constraints.append(NSLayoutConstraint(item: self.scrollView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.editorView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    internal func setupButtonAddTab(constraints: inout [NSLayoutConstraint]) {
        self.buttonAddTab.translatesAutoresizingMaskIntoConstraints = false
        self.buttonAddTab.bezelStyle = .roundRect
        self.buttonAddTab.setButtonType(.momentaryPushIn)
        self.buttonAddTab.isBordered = false
        self.buttonAddTab.isTransparent = false
        self.buttonAddTab.image = NSImage(named: .addTemplate)
        self.buttonAddTab.action = #selector(self.addTab(_:))
        self.buttonAddTab.target = self
        
        // ---------------------------------------------------------------------
        //  Add and to superview
        // ---------------------------------------------------------------------
        self.editorView.addSubview(self.buttonAddTab)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Center Y
        self.constraintsTabView.append(NSLayoutConstraint(item: self.buttonAddTab,
                                                          attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: self.tabView,
                                                          attribute: .centerY,
                                                          multiplier: 1.0,
                                                          constant: 0.0))
        // Trailing
        self.constraintsTabView.append(NSLayoutConstraint(item: self.editorView,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: self.buttonAddTab,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0))
        
        // Width
        self.constraintsTabView.append(NSLayoutConstraint(item: self.buttonAddTab,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 18.0))
        
        // Width == Height
        self.constraintsTabView.append(NSLayoutConstraint(item: self.buttonAddTab,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self.buttonAddTab,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 0.0))
    }
    
    internal func setupTabView(constraints: inout [NSLayoutConstraint]) {
        self.tabView.translatesAutoresizingMaskIntoConstraints = false
        self.tabView.spacing = 1.0
        self.tabView.distribution = .fillEqually
        self.tabView.alignment = .centerY
        self.tabView.detachesHiddenViews = true
        
        let testTab = ProfileEditorTab(editor: self)
        self.tabView.addView(testTab, in: .trailing)
        
        // ---------------------------------------------------------------------
        //  Add and setup ScrollView
        // ---------------------------------------------------------------------
        // self.editorView.addSubview(self.tabView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        self.constraintsTabView.append(NSLayoutConstraint(item: self.tabView,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: self.separator,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0.0))
        
        // Height
        self.constraintsTabView.append(NSLayoutConstraint(item: self.tabView,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: 24.0))
        
        // Leading
        self.constraintsTabView.append(NSLayoutConstraint(item: self.tabView,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: self.editorView,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0))
        
        // Trailing
        self.constraintsTabView.append(NSLayoutConstraint(item: self.tabView,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: self.buttonAddTab,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0))
    }
}

//
//  PayloadCellViewItemCheckbox.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-02.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class EditorCheckbox {

    class func noTitle(constraints: inout [NSLayoutConstraint],
                       cellView: CheckboxCellView) -> NSButton {
        
        // ---------------------------------------------------------------------
        //  Create and setup Checkbox
        // ---------------------------------------------------------------------
        let checkbox = NSButton()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.setButtonType(.switch)
        checkbox.action = #selector(cellView.clicked(_:))
        checkbox.target = cellView
        checkbox.title = ""
        
        return checkbox
    }
}

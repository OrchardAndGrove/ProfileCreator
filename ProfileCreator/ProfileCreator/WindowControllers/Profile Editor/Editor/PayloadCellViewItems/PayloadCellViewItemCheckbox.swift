//
//  PayloadCellViewItemCheckbox.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-02.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class EditorCheckbox {

    class func noTitle(cellView: CheckboxCellView) -> NSButton {
        
        // ---------------------------------------------------------------------
        //  Create and setup Checkbox
        // ---------------------------------------------------------------------
        let checkbox = PayloadCheckbox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.setButtonType(.switch)
        checkbox.action = #selector(cellView.clicked(_:))
        checkbox.target = cellView
        checkbox.title = ""
        
        return checkbox
    }
}

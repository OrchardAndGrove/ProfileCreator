//
//  PayloadCellViewItemPopUpButton.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class EditorPopUpButton {

    class func withTitles(titles: [String],
                          constraints: inout [NSLayoutConstraint],
                          cellView: PopUpButtonCellView) -> NSPopUpButton {
        
        // ---------------------------------------------------------------------
        //  Create and setup Checkbox
        // ---------------------------------------------------------------------
        let popUpButton = PayloadPopUpButton()
        popUpButton.translatesAutoresizingMaskIntoConstraints = false
        popUpButton.action = #selector(cellView.selected(_:))
        popUpButton.target = cellView
        popUpButton.addItems(withTitles: titles)
        
        return popUpButton
    }
    
}

//
//  PayloadCellViewItemConstraints.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-27.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

enum OrientationAttribute {
    case above, below, leading, trailing
}

func addConstraintsFor(item: NSView, orientation: OrientationAttribute, constraints: inout [NSLayoutConstraint], cellView: PayloadCellView) {
    switch orientation {
    case .above:
        return
    case .below:
        addConstraintBelowFor(item: item, constraints: &constraints, cellView: cellView)
        return
    case .leading:
        return
    case .trailing:
        return
    }
}

fileprivate func addConstraintBelowFor(item: NSView, constraints: inout [NSLayoutConstraint], cellView: PayloadCellView) {
    if cellView.textFieldDescription != nil {
        constraints.append(NSLayoutConstraint(item: item,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: cellView.textFieldDescription,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 7.0))
        
        cellView.updateHeight(7.0 + item.intrinsicContentSize.height)
    } else if cellView.textFieldTitle != nil {
        constraints.append(NSLayoutConstraint(item: cellView.textFieldTitle!,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: item,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 7.0))
        
        cellView.updateHeight(7.0 + item.intrinsicContentSize.height)
    } else {
        constraints.append(NSLayoutConstraint(item: item,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        cellView.updateHeight(8.0 + item.intrinsicContentSize.height)
    }
}

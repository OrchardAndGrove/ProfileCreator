//
//  PFCMainWindowTableViewItemCellView.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PFCMainWindowTableViewItemCellView.h"

@interface PFCMainWindowTableViewItemCellView ()
@end

@implementation PFCMainWindowTableViewItemCellView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (NSTableCellView *_Nonnull)cellViewWithTitle:(NSString *_Nonnull)title {

    // -------------------------------------------------------------------------
    //  Create new CellView instance
    // -------------------------------------------------------------------------
    NSTableCellView *cellView = [[NSTableCellView alloc] init];

    // -------------------------------------------------------------------------
    //  Create and setup TextField
    // -------------------------------------------------------------------------
    NSTextField *textFieldTitle = [[NSTextField alloc] init];
    [textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldTitle setBordered:NO];
    [textFieldTitle setBezeled:NO];
    [textFieldTitle setDrawsBackground:NO];
    [textFieldTitle setEditable:NO];
    [textFieldTitle setFont:[NSFont boldSystemFontOfSize:12]];
    [textFieldTitle setTextColor:[NSColor controlTextColor]];
    [textFieldTitle setAlignment:NSLeftTextAlignment];
    [textFieldTitle setStringValue:title];
    [textFieldTitle setLineBreakMode:NSLineBreakByTruncatingTail];
    [cellView addSubview:textFieldTitle];

    // -------------------------------------------------------------------------
    //  Setup TextField Constraints
    // -------------------------------------------------------------------------
    NSMutableArray *constraints = [[NSMutableArray alloc] init];

    // Center Vertically
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:cellView
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:cellView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:11]];

    // Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:cellView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:6]];

    // -------------------------------------------------------------------------
    //  Activate Layout Constraints
    // -------------------------------------------------------------------------
    [NSLayoutConstraint activateConstraints:constraints];

    return cellView;
}

@end

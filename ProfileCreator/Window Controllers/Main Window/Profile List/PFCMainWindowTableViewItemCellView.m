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

+ (NSTableCellView *_Nonnull)cellViewWithTitle:(NSString *_Nonnull)title payloadCount:(NSInteger)payloadCount errorCount:(NSInteger)errorCount {

    // -------------------------------------------------------------------------
    //  Create new CellView instance
    // -------------------------------------------------------------------------
    NSTableCellView *cellView = [[NSTableCellView alloc] init];

    // -------------------------------------------------------------------------
    //  Create and add TextField Title
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

    // Top
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:cellView
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:2]];

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
    //  Create and add TextField Description
    // -------------------------------------------------------------------------
    NSTextField *textFieldDescription = [[NSTextField alloc] init];
    [textFieldDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldDescription setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldDescription setBordered:NO];
    [textFieldDescription setBezeled:NO];
    [textFieldDescription setDrawsBackground:NO];
    [textFieldDescription setEditable:NO];
    [textFieldDescription setFont:[NSFont systemFontOfSize:10]];
    [textFieldDescription setTextColor:[NSColor controlShadowColor]];
    [textFieldDescription setAlignment:NSLeftTextAlignment];
    NSString *descriptionString;
    if (payloadCount == 1) {
        descriptionString = NSLocalizedString(([NSString stringWithFormat:@"%ld Payload", (long)payloadCount]), @"");
    } else {
        descriptionString = NSLocalizedString(([NSString stringWithFormat:@"%ld Payloads", (long)payloadCount]), @"");
    }
    [textFieldDescription setStringValue:descriptionString];
    [textFieldDescription setLineBreakMode:NSLineBreakByTruncatingTail];
    [cellView addSubview:textFieldDescription];

    // Top
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldDescription
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:textFieldTitle
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:1]];

    // Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldDescription
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:textFieldTitle
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldDescription
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:textFieldTitle
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];

    // -------------------------------------------------------------------------
    //  Activate Layout Constraints
    // -------------------------------------------------------------------------
    [NSLayoutConstraint activateConstraints:constraints];

    return cellView;
}

@end

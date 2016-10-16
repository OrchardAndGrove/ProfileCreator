//
//  PFCProfileEditorLibraryFilter.m
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

#import "PFCProfileEditorLibraryFilter.h"

@interface PFCProfileEditorLibraryFilter ()
@property (nonatomic, readwrite, nonnull) NSView *view;
@property (nonatomic, readwrite, nonnull) NSSearchField *searchField;
@end

@implementation PFCProfileEditorLibraryFilter

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Create View
        // ---------------------------------------------------------------------
        _view = [[NSView alloc] init];
        [_view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_view setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
        [_view setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];

        // ---------------------------------------------------------------------
        //  Create and add SearchField
        // ---------------------------------------------------------------------
        _searchField = [[NSSearchField alloc] init];
        [_searchField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_searchField setControlSize:NSSmallControlSize];
        [_searchField setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [_searchField setPlaceholderString:NSLocalizedString(@"Filter Payloads", @"Placeholder string for profile editor library filter field")];
        [_view addSubview:_searchField];

        // ---------------------------------------------------------------------
        //  Setup constraints for SearchField
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // SearchField - Center Vertically
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_searchField
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:-1]];

        // SearchField - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_searchField
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:5]];

        // SearchField - Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_view
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_searchField
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:5]];

        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

@end

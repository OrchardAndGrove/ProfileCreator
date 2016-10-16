//
//  PFCProfileEditorLibraryNoPayloads.m
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

#import "PFCProfileEditorLibraryNoPayloads.h"

@interface PFCProfileEditorLibraryNoPayloads ()
@property (nonatomic, strong, readwrite, nonnull) PFCViewWhite *view;
@property (nonatomic, strong, nonnull) NSTextField *textFieldTitle;
@property (nonatomic, strong, nonnull) NSTextField *textFieldInformation;
@end

@implementation PFCProfileEditorLibraryNoPayloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithDraggingDelegate:(id<NSDraggingDestination> _Nonnull)draggingDelegate {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Create View
        // ---------------------------------------------------------------------
        _view = [[PFCViewWhite alloc] initWithDraggingDelegate:draggingDelegate];
        [_view setTranslatesAutoresizingMaskIntoConstraints:NO];

        // ---------------------------------------------------------------------
        //  Create and add TextField Title
        // ---------------------------------------------------------------------
        _textFieldTitle = [[NSTextField alloc] init];
        [_textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
        [_textFieldTitle setBordered:NO];
        [_textFieldTitle setBezeled:NO];
        [_textFieldTitle setDrawsBackground:NO];
        [_textFieldTitle setEditable:NO];
        [_textFieldTitle setSelectable:NO];
        [_textFieldTitle setStringValue:@"No Payloads"];
        [_textFieldTitle setTextColor:[NSColor tertiaryLabelColor]];
        [_textFieldTitle setFont:[NSFont systemFontOfSize:14 weight:NSFontWeightMedium]];
        [_textFieldTitle setAlignment:NSTextAlignmentCenter];
        [_view addSubview:_textFieldTitle];

        // ---------------------------------------------------------------------
        //  Setup constraints for TextField Title
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0f
                                                             constant:0]];

        // Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0f
                                                             constant:0]];

        // Center Vertically
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_view
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0f
                                                             constant:0]];

        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}
@end

//
//  PFCMainWindowTableViewWelcome.m
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

#import "PFCConstants.h"
#import "PFCMainWindowTableViewWelcome.h"

@interface PFCMainWindowTableViewWelcome ()
@property (nonatomic, strong, readwrite, nonnull) PFCViewWhite *view;
@property (nonatomic, strong, nonnull) NSButton *button;
@property (nonatomic, strong, nonnull) NSTextField *textFieldTitle;
@property (nonatomic, strong, nonnull) NSTextField *textFieldInformation;

@end

@implementation PFCMainWindowTableViewWelcome

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Create View
        // ---------------------------------------------------------------------
        _view = [[PFCViewWhite alloc] init];
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
        [_textFieldTitle setStringValue:NSLocalizedString(@"Welcome to ProfileCreator", @"")];
        [_textFieldTitle setTextColor:[NSColor labelColor]];
        [_textFieldTitle setFont:[NSFont boldSystemFontOfSize:28]];
        [_textFieldTitle setAlignment:NSTextAlignmentCenter];
        [_view addSubview:_textFieldTitle];

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints for TextField Title
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // Center Horizontally
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0f
                                                             constant:0]];

        // Center Vertically
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_view
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0f
                                                             constant:30]];

        // ---------------------------------------------------------------------
        //  Create and add TextField Information
        // ---------------------------------------------------------------------
        _textFieldInformation = [[NSTextField alloc] init];
        [_textFieldInformation setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_textFieldInformation setLineBreakMode:NSLineBreakByWordWrapping];
        [_textFieldInformation setBordered:NO];
        [_textFieldInformation setBezeled:NO];
        [_textFieldInformation setDrawsBackground:NO];
        [_textFieldInformation setEditable:NO];
        [_textFieldInformation setSelectable:NO];
        [_textFieldInformation setStringValue:NSLocalizedString(@"To create your first profile, click the ", @"")];
        [_textFieldInformation setTextColor:[NSColor secondaryLabelColor]];
        [_textFieldInformation setFont:[NSFont systemFontOfSize:16]];
        [_textFieldInformation setAlignment:NSTextAlignmentCenter];
        [_view addSubview:_textFieldInformation];

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints for TextField Information
        // ---------------------------------------------------------------------
        // Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldInformation
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0f
                                                             constant:13]];

        // Center Horizontally
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldInformation
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0f
                                                             constant:21]];

        // ---------------------------------------------------------------------
        //  Create and add Button Add
        // ---------------------------------------------------------------------
        _button = [[NSButton alloc] init];
        [_button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_button setBezelStyle:NSTexturedRoundedBezelStyle];
        [_button setImage:[NSImage imageNamed:NSImageNameAddTemplate]];
        [_button setTarget:self];
        [_button setAction:@selector(buttonClicked:)];
        [[_button cell] setImageScaling:NSImageScaleProportionallyDown];
        [_button setImagePosition:NSImageOnly];
        [_view addSubview:_button];

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints for Button Add
        // ---------------------------------------------------------------------
        // Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldInformation
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0f
                                                             constant:2]];

        // Baseline
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldInformation
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0f
                                                             constant:0]];

        // Width
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:40]];

        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)buttonClicked:(NSButton *)button {

    // -------------------------------------------------------------------------
    //  If the button is clicked, post PFCAddProfileNotification
    // -------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCAddProfileNotification object:self userInfo:@{PFCNotificationUserInfoParentTitle : PFCMainWindowOutlineViewParentTitleLibrary}];
}

@end

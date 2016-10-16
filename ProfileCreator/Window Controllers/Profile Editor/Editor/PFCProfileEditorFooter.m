//
//  PFCProfileEditorFooter.m
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

#import "PFCProfile.h"
#import "PFCProfileEditorFooter.h"
#import "PFCProfileEditorSettingsPopOver.h"

@interface PFCProfileEditorFooter ()
@property (nonatomic, weak, nullable) PFCProfile *profile;
@property (nonatomic, readwrite, nonnull) NSView *view;
@property (nonatomic, strong, nonnull) NSButton *buttonSave;
@property (nonatomic, strong, nonnull) NSButton *buttonPopOver;
@property (nonatomic, strong, nonnull) PFCProfileEditorSettingsPopOver *settingsPopOver;
@end

@implementation PFCProfileEditorFooter

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfile:(PFCProfile *_Nonnull)profile {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profile = profile;
        _settingsPopOver = [[PFCProfileEditorSettingsPopOver alloc] initWithProfile:_profile];

        // ---------------------------------------------------------------------
        //  Create View
        // ---------------------------------------------------------------------
        _view = [[NSView alloc] init];
        [_view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_view setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
        [_view setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];

        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        [self addButtonSave:constraints];
        [self addButtonPopOver:constraints];

        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

- (void)addButtonSave:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Create and add Button Save
    // -------------------------------------------------------------------------
    _buttonSave = [[NSButton alloc] init];
    [_buttonSave setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_buttonSave setBezelStyle:NSRoundedBezelStyle];
    [_buttonSave setButtonType:NSMomentaryPushInButton];
    [_buttonSave setBordered:YES];
    [_buttonSave setControlSize:NSSmallControlSize];
    [_buttonSave setTransparent:NO];
    [_buttonSave setTarget:self];
    [_buttonSave setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [_buttonSave setAction:@selector(saveProfile:)];
    [_buttonSave setTitle:@"Save"];
    [_buttonSave sizeToFit];
    [_buttonSave setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_view addSubview:_buttonSave];

    // -------------------------------------------------------------------------
    //  Setup constraints for button save
    // -------------------------------------------------------------------------
    // Center Vertically
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonSave
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_view
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_view
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_buttonSave
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:10]];
}

- (void)addButtonPopOver:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Create and add Button PopOver
    // -------------------------------------------------------------------------
    _buttonPopOver = [[NSButton alloc] init];
    [_buttonPopOver setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_buttonPopOver setBezelStyle:NSRegularSquareBezelStyle];
    [_buttonPopOver setButtonType:NSMomentaryChangeButton];
    [_buttonPopOver setBordered:NO];
    [_buttonPopOver setTransparent:NO];
    [_buttonPopOver setImagePosition:NSImageOnly];
    [_buttonPopOver setImage:[NSImage imageNamed:@"ButtonPopOverMenu"]];
    [[_buttonPopOver cell] setHighlightsBy:NSPushInCellMask | NSChangeBackgroundCellMask];
    [_buttonPopOver setTarget:self];
    [_buttonPopOver setAction:@selector(showPopOver:)];
    [_buttonPopOver sizeToFit];
    [_buttonPopOver setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_view addSubview:_buttonPopOver];

    // -------------------------------------------------------------------------
    //  Setup constraints for button popover
    // -------------------------------------------------------------------------
    // Center Vertically
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonPopOver
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_view
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonPopOver
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_view
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:10]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)saveProfile:(id)sender {
    if (self.profile) {
        [self.profile save];
    }
}

- (void)showPopOver:(id)sender {
    [self.settingsPopOver.popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
}

@end

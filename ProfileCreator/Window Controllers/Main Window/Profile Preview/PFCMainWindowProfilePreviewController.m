//
//  PFCMainWindowProfilePreviewController.m
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
#import "PFCMainWindowProfilePreviewController.h"
#import "PFCMainWindowProfilePreviewInfoView.h"
#import "PFCMainWindowProfilePreviewView.h"

@interface PFCMainWindowProfilePreviewController ()
@property (nonatomic, readwrite, nonnull) NSVisualEffectView *view;
@property (nonatomic, nonnull) PFCMainWindowProfilePreviewView *previewView;
@property (nonatomic, nonnull) PFCMainWindowProfilePreviewInfoView *infoView;
@end

@implementation PFCMainWindowProfilePreviewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Effect View (Background)
        // ---------------------------------------------------------------------
        NSVisualEffectView *view = [[NSVisualEffectView alloc] init];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [view setMaterial:NSVisualEffectMaterialLight];
        _view = view;

        // ---------------------------------------------------------------------
        //  Setup Info View
        // ---------------------------------------------------------------------
        _infoView = [[PFCMainWindowProfilePreviewInfoView alloc] init];
        [self insertSubview:_infoView.view];

        // ---------------------------------------------------------------------
        //  Setup Preview View
        // ---------------------------------------------------------------------
        _previewView = [[PFCMainWindowProfilePreviewView alloc] init];

        // ---------------------------------------------------------------------
        //  Add Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(profileSelectionDidChange:) name:PFCProfileSelectionDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notification
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCProfileSelectionDidChangeNotification object:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)profileSelectionDidChange:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Get identifiers for profiles of the new selection
    // -------------------------------------------------------------------------
    NSDictionary *userInfo = notification.userInfo;
    NSArray *profileIdentifiers = userInfo[PFCNotificationUserInfoProfileIdentifiers];

    // -------------------------------------------------------------------------
    //  If only one (1) profile was selected, show preview, otherwise show info
    // -------------------------------------------------------------------------
    if (profileIdentifiers.count == 1) {
        [self.infoView updateSelectionCount:profileIdentifiers.count];
        [self.view setState:NSVisualEffectStateInactive];
    } else {
        [self.infoView updateSelectionCount:profileIdentifiers.count];
        [self.view setState:NSVisualEffectStateActive];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)insertSubview:(NSView *)subview {

    // -------------------------------------------------------------------------
    //  Add subview to main view
    // -------------------------------------------------------------------------
    [self.view addSubview:subview];

    // -------------------------------------------------------------------------
    //  Setup Layout Constraints
    // -------------------------------------------------------------------------
    NSMutableArray *constraints = [[NSMutableArray alloc] init];

    // Top
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:subview
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0]];

    // Bottom
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:subview
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0]];

    // Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:subview
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.view
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:subview
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];

    // -------------------------------------------------------------------------
    //  Activate Layout Constraints
    // -------------------------------------------------------------------------
    [NSLayoutConstraint activateConstraints:constraints];
}

@end

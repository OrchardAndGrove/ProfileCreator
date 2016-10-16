//
//  PFCProfileEditorSettingsView.m
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
#import "PFCProfileEditorSettingsView.h"

@interface PFCProfileEditorSettingsView ()
@property (nonatomic, weak) PFCProfile *profile;
@property (nonatomic, weak, readwrite, nullable) IBOutlet NSTextField *textFieldProfileName;
@property (nonatomic, weak) IBOutlet NSButton *checkboxShowSupervised;
@property (nonatomic, weak) IBOutlet NSPopUpButton *popUpButtonScope;

@end

@implementation PFCProfileEditorSettingsView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfile:(PFCProfile *_Nonnull)profile {
    self = [super initWithNibName:@"PFCProfileEditorSettingsView" bundle:nil];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profile = profile;

        // ---------------------------------------------------------------------
        //  Setup Value Bindings
        // ---------------------------------------------------------------------
        [self setupBindings];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Unbind
    // -------------------------------------------------------------------------
    [_textFieldProfileName unbind:NSValueBinding];
    [_checkboxShowSupervised unbind:NSValueBinding];
    [_popUpButtonScope unbind:NSSelectedTagBinding];
}

- (void)setupBindings {

    // -------------------------------------------------------------------------
    //  Wakeup View
    // -------------------------------------------------------------------------
    [self view];

    // -------------------------------------------------------------------------
    //  Setup Value Bindings
    // -------------------------------------------------------------------------
    [_textFieldProfileName bind:NSValueBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(title)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [_checkboxShowSupervised bind:NSValueBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(showSupervised)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [_popUpButtonScope bind:NSSelectedTagBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(scope)) options:nil];
}

@end

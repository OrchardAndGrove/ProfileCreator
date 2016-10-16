//
//  PFCProfileEditorSettingsPopOver.m
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
#import "PFCProfileEditorSettingsPopOver.h"

@interface PFCProfileEditorSettingsPopOver ()
@property (nonatomic, strong, readwrite, nonnull) NSPopover *popover;
@property (nonatomic, weak, nullable) PFCProfile *profile;

// UI Items
@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxPlatformmacOS;
@property (nonatomic, weak, nullable) IBOutlet NSPopUpButton *popUpButtonPlatformmacOSMax;
@property (nonatomic, weak, nullable) IBOutlet NSPopUpButton *popUpButtonPlatformmacOSMin;

@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxPlatformiOS;
@property (nonatomic, weak, nullable) IBOutlet NSPopUpButton *popUpButtonPlatformiOSMax;
@property (nonatomic, weak, nullable) IBOutlet NSPopUpButton *popUpButtonPlatformiOSMin;

@property (nonatomic, weak, nullable) IBOutlet NSPopUpButton *popUpButtonScope;
@property (nonatomic, weak, nullable) IBOutlet NSPopUpButton *popUpButtonDistribution;

@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxShowSupervised;
@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxShowDisabled;
@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxShowHidden;
@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxShowSource;

@property (nonatomic, weak, nullable) IBOutlet NSButton *checkboxShowColumnDisable;

@end

@implementation PFCProfileEditorSettingsPopOver

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfile:(PFCProfile *_Nonnull)profile {
    self = [super initWithNibName:@"PFCProfileEditorSettingsPopOver" bundle:nil];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profile = profile;

        // ---------------------------------------------------------------------
        //  Setup Value Bindings
        // ---------------------------------------------------------------------
        [self setupBindings];

        // ---------------------------------------------------------------------
        //  Setup PopOver
        // ---------------------------------------------------------------------
        _popover = [[NSPopover alloc] init];
        [_popover setBehavior:NSPopoverBehaviorTransient];
        [_popover setAnimates:YES];
        [_popover setContentViewController:self];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Unbind
    // -------------------------------------------------------------------------
    [_checkboxShowHidden unbind:NSValueBinding];
    [_checkboxShowSupervised unbind:NSValueBinding];
    [_checkboxShowDisabled unbind:NSValueBinding];
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
    [_checkboxShowHidden bind:NSValueBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(showHidden)) options:nil];
    [_checkboxShowSupervised bind:NSValueBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(showSupervised)) options:nil];
    [_checkboxShowDisabled bind:NSValueBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(showDisabled)) options:nil];
    [_popUpButtonScope bind:NSSelectedTagBinding toObject:_profile withKeyPath:NSStringFromSelector(@selector(scope)) options:nil];
}

@end

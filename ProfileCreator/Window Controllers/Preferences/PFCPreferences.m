//
//  PFCPreferences.m
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

#import "PFCPreferences.h"
#import "PFCPreferencesToolbarItemGeneral.h"
#import "PFCPreferencesToolbarItemProfileDefaults.h"

NSUInteger const PFCPreferencesWindowWidth = 450;

@interface PFCPreferences ()
@property (nonatomic, strong) NSToolbar *toolbar;
@property (nonatomic, strong) PFCPreferencesToolbarItemGeneral *toolbarItemGeneral;
@property (nonatomic, strong) PFCPreferencesToolbarItemProfileDefaults *toolbarItemProfileDefaults;
@property (nonatomic, strong) NSArray *toolbarItemIdentifiers;
@property (nonatomic, strong) NSLayoutConstraint *layoutConstraintWindowWidth;
@end

@implementation PFCPreferences

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup preferences window
        // ---------------------------------------------------------------------
        NSRect frame = NSMakeRect(0, 0, 200, PFCPreferencesWindowWidth);
        NSWindow *preferencesWindow =
            [[NSWindow alloc] initWithContentRect:frame styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask backing:NSBackingStoreBuffered defer:NO];

        [preferencesWindow setReleasedWhenClosed:NO];
        [preferencesWindow setRestorable:NO];
        [preferencesWindow center];

        self.window = preferencesWindow;

        // ---------------------------------------------------------------------
        //  Setup toolbar items
        // ---------------------------------------------------------------------
        _toolbarItemIdentifiers = @[
            PFCPreferencesToolbarItemIdentifierGeneral,
            PFCPreferencesToolbarItemIdentifierProfileDefaults,
            NSToolbarSeparatorItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier
        ];

        // ---------------------------------------------------------------------
        //  Setup toolbar
        // ---------------------------------------------------------------------
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolbar"];
        [toolbar setVisible:YES];
        [toolbar setShowsBaselineSeparator:YES];
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:YES];
        [toolbar setSizeMode:NSToolbarSizeModeRegular];
        [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
        [toolbar setDelegate:self];
        _toolbar = toolbar;

        // ---------------------------------------------------------------------
        // Add toolbar to window
        // ---------------------------------------------------------------------
        [self.window setToolbar:_toolbar];

        // ---------------------------------------------------------------------
        // Show toolbar view General
        // ---------------------------------------------------------------------
        [self showPreferencesViewWithIdentifier:PFCPreferencesToolbarItemIdentifierGeneral];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSToolbarDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarItemIdentifiers;
} // toolbarAllowedItemIdentifiers

- (NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarItemIdentifiers;
} // toolbarDefaultItemIdentifiers

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    id toolbarItem = [self toolbarItemWithIdentifier:itemIdentifier];
    if (toolbarItem != nil) {
        return [toolbarItem toolbarItem];
    } else {
        return nil;
    }
} // toolbar:itemForItemIdentifier

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)selectedToolbarItem:(id)sender {
    [self showPreferencesViewWithIdentifier:[sender itemIdentifier]];
} // selectedToolbarItem

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)toolbarItemWithIdentifier:(NSString *)identifier {

    // -------------------------------------------------------------------------
    //  Return toolbar item instance matching identifier
    // -------------------------------------------------------------------------
    if ([identifier isEqualToString:PFCPreferencesToolbarItemIdentifierGeneral]) {
        if (!self.toolbarItemGeneral) {
            [self setToolbarItemGeneral:[[PFCPreferencesToolbarItemGeneral alloc] initWithSender:self]];
        }
        return self.toolbarItemGeneral;
    } else if ([identifier isEqualToString:PFCPreferencesToolbarItemIdentifierProfileDefaults]) {
        if (!self.toolbarItemProfileDefaults) {
            [self setToolbarItemProfileDefaults:[[PFCPreferencesToolbarItemProfileDefaults alloc] initWithSender:self]];
        }
        return self.toolbarItemProfileDefaults;
    }
    return nil;
} // toolbarItemWithIdentifier

- (void)showPreferencesViewWithIdentifier:(NSString *_Nonnull)identifier {

    // -------------------------------------------------------------------------
    //  Get toolbar item for identifier
    // -------------------------------------------------------------------------
    id toolbarItem = [self toolbarItemWithIdentifier:identifier];
    if (toolbarItem != nil) {

        // ---------------------------------------------------------------------
        //  Get toolbar item view
        // ---------------------------------------------------------------------
        NSView *toolbarItemView = [toolbarItem view];
        if (toolbarItemView != nil) {

            // -----------------------------------------------------------------
            //  Update preferences window with the new view, rezising window to match the view size
            // -----------------------------------------------------------------
            [self.window setTitle:identifier];
            [self.window.contentView removeFromSuperview];
            [self updatePreferencesWindowSizeForView:toolbarItemView];
            [self.window setContentView:toolbarItemView];
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self.window.contentView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:PFCPreferencesWindowWidth]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
    }
} // selectedToolbarItem

- (void)updatePreferencesWindowSizeForView:(NSView *_Nonnull)view {
    NSRect frame = self.window.frame;
    NSRect oldView = self.window.contentView.frame;
    NSRect newView = view.frame;

    frame.origin.y = frame.origin.y + (oldView.size.height - newView.size.height);
    frame.size.height = ((frame.size.height - oldView.size.height) + newView.size.height);

    [self.window setFrame:frame display:YES animate:YES];
} // updatePreferencesWindowSizeForView

@end

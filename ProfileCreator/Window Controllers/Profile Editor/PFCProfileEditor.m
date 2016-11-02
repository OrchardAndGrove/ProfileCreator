//
//  PFCProfileEditor.m
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

#import "PFCAlert.h"
#import "PFCLog.h"
#import "PFCProfile.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorLibraryPayloads.h"
#import "PFCProfileEditorLibrarySplitView.h"
#import "PFCProfileEditorSettings.h"
#import "PFCProfileEditorSettingsView.h"
#import "PFCProfileEditorSplitView.h"
#import "PFCProfileEditorTableViewController.h"
#import "PFCProfileEditorToolbarItemTitle.h"

@interface PFCProfileEditor ()
@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorSplitView *splitView;
@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorSettings *settings;
@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorToolbarItemTitle *toolbarItemTitle;
@property (nonatomic, strong, readwrite, nonnull) PFCProfile *profile;

@property (nonatomic, strong, nullable) PFCAlert *alert;
@property (nonatomic, strong, nonnull) NSToolbar *toolbar;
@property (nonatomic, strong, nonnull) NSArray *toolbarItemIdentifiers;
@end

@implementation PFCProfileEditor

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
        _settings = [[PFCProfileEditorSettings alloc] initWithProfile:_profile];

        // ---------------------------------------------------------------------
        //  Setup main window
        // ---------------------------------------------------------------------
        NSRect frame = NSMakeRect(0, 0, 801, 700); // 801 because if 800 the text appears blurry when first loaded
        NSWindow *profileEditorWindow = [[NSWindow alloc]
            initWithContentRect:frame
                      styleMask:NSFullSizeContentViewWindowMask | NSTitledWindowMask | NSUnifiedTitleAndToolbarWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                        backing:NSBackingStoreBuffered
                          defer:NO];

        [profileEditorWindow setTitleVisibility:NSWindowTitleHidden];
        [profileEditorWindow setReleasedWhenClosed:NO];
        [profileEditorWindow setRestorable:YES];
        [profileEditorWindow setIdentifier:[NSString stringWithFormat:@"ProfileCreatorEditorWindow-%@", _profile.identifier]];
        [profileEditorWindow setContentMinSize:NSMakeSize(600, 400)];
        [profileEditorWindow setBackgroundColor:[NSColor whiteColor]];
        [profileEditorWindow setAutorecalculatesKeyViewLoop:YES];
        [profileEditorWindow center];
        [profileEditorWindow setDelegate:self];
        self.window = profileEditorWindow;

        // ---------------------------------------------------------------------
        //  Setup splitview
        // ---------------------------------------------------------------------
        _splitView = [[PFCProfileEditorSplitView alloc] initWithProfileEditor:self];

        // ---------------------------------------------------------------------
        // Add splitview to window
        // ---------------------------------------------------------------------
        [self.window setContentView:_splitView];

        // ---------------------------------------------------------------------
        //  Setup toolbar
        // ---------------------------------------------------------------------
        _toolbar = [[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"ProfileCreatorEditorWindowToolbar-%@", _profile.identifier]];
        [_toolbar setVisible:YES];
        [_toolbar setShowsBaselineSeparator:YES];
        [_toolbar setAllowsUserCustomization:NO];
        [_toolbar setAutosavesConfiguration:YES];
        [_toolbar setSizeMode:NSToolbarSizeModeRegular];
        [_toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
        [_toolbar setDelegate:self];

        // ---------------------------------------------------------------------
        //  Setup toolbar items
        // ---------------------------------------------------------------------
        _toolbarItemIdentifiers = @[ NSToolbarFlexibleSpaceItemIdentifier, PFCProfileEditorToolbarItemIdentifierTitle, NSToolbarFlexibleSpaceItemIdentifier ];

        // ---------------------------------------------------------------------
        // Add toolbar to window
        // ---------------------------------------------------------------------
        [self.window setToolbar:_toolbar];

        // ---------------------------------------------------------------------
        // Set first responder to display name of the profile
        // ---------------------------------------------------------------------
        PFCProfileEditorLibraryPayloads *libraryPayloads = _splitView.librarySplitView.libraryPayloads;
        [libraryPayloads.tableViewProfilePayloads selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        NSArray *payloadEditorKeys = _splitView.tableViewController.payloadKeys;
        if (2 <= payloadEditorKeys.count) {
            id tableViewItem = payloadEditorKeys[1];
            if ([[tableViewItem class] isSubclassOfClass:[PFPViewTypeTableViewTextField class]]) {
                [self.window setInitialFirstResponder:[(PFPViewTypeTableViewTextField *)tableViewItem textFieldInput]];
            }
        } else {
            [self.window setInitialFirstResponder:libraryPayloads.tableViewProfilePayloads];
        }

        // ---------------------------------------------------------------------
        // Set the initial position of the library SplitView
        // NOTE: This has to be called twice, probably because of using AutoLayout.
        // ---------------------------------------------------------------------
        [_splitView.librarySplitView setPosition:250 ofDividerAtIndex:0];
        [_splitView.librarySplitView setPosition:250 ofDividerAtIndex:0];
    }
    return self;
} // initWithProfile

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister as toolbar delegate
    // -------------------------------------------------------------------------
    [_toolbar setDelegate:nil];
}

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

- (id)toolbarItemWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:PFCProfileEditorToolbarItemIdentifierTitle]) {
        if (!self.toolbarItemTitle) {
            [self setToolbarItemTitle:[[PFCProfileEditorToolbarItemTitle alloc] initWithProfile:_profile]];
        }
        return self.toolbarItemTitle;
    }
    return nil;
} // toolbarItemWithIdentifier

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindowDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Respond to windowShouldClose to warn user about unsaved changes
// -----------------------------------------------------------------------------
- (BOOL)windowShouldClose:(id)sender {

    // -------------------------------------------------------------------------
    //  Check if profile title is empty or PFCProfileDefaultName
    // -------------------------------------------------------------------------
    if (self.profile.title.length == 0 || [self.profile.title isEqualToString:PFCProfileDefaultName]) {

        // ---------------------------------------------------------------------
        //  Setup return block
        // ---------------------------------------------------------------------
        void (^returnValue)(NSString *_Nullable, NSInteger) = ^void(NSString *inputText, NSInteger returnCode) {

          // -------------------------------------------------------------------
          //  User selected: Save & Close
          // -------------------------------------------------------------------
          if (returnCode == NSAlertFirstButtonReturn) {
              [self.profile updateTitle:inputText];
              if ([self.profile save]) {
                  [self.window close];
              }

              // ---------------------------------------------------------------
              //  User selected: Close
              // ---------------------------------------------------------------
          } else if (returnCode == NSAlertSecondButtonReturn) {
              [self.window close];
          }
        };

        // ---------------------------------------------------------------------
        //  Setup Alert
        // ---------------------------------------------------------------------
        PFCAlert *alert = [[PFCAlert alloc] init];
        [self setAlert:alert];

        // ---------------------------------------------------------------------
        //  Show Alert to User
        // ---------------------------------------------------------------------
        [alert showAlertTextInputWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Do you want to save the changes you made in the profile \"%@\"?",
                                                                                          @"Alert message when closing editor window when there are unsaved changes"),
                                                                        (self.profile.title.length != 0) ? self.profile.title : PFCProfileDefaultName]
                             informativeText:NSLocalizedString(@"Your changes will be lost if you don't save them.\n\nPlease enter a name for the profile:",
                                                               @"Alert informative text when closing editor window when there are unsaved changes")
                                      window:self.window
                               defaultString:@""
                           placeholderString:NSLocalizedString(@"Profile Name", @"")
                            firstButtonTitle:PFCButtonTitleSaveAndClose
                           secondButtonTitle:PFCButtonTitleClose
                            thirdButtonTitle:PFCButtonTitleCancel
                     firstButtonInitialState:NO
                                      sender:self
                                 returnValue:returnValue];

        // ---------------------------------------------------------------------
        //  Select all text in the profile name text field
        // ---------------------------------------------------------------------
        [alert.textFieldInput selectText:self];

        // ---------------------------------------------------------------------
        //  Return NO so the window doesn't close
        // ---------------------------------------------------------------------
        return NO;
    } else if (![self.profile isSaved]) {

        // ---------------------------------------------------------------------
        //  Setup return block
        // ---------------------------------------------------------------------
        void (^returnCodeBlock)(NSInteger) = ^void(NSInteger returnCode) {

          // -------------------------------------------------------------------
          //  User selected: Save & Close
          // -------------------------------------------------------------------
          if (returnCode == NSAlertFirstButtonReturn) {
              if ([self.profile save]) {
                  [self.window close];
              }

              // ---------------------------------------------------------------
              //  User selected: Close
              // ---------------------------------------------------------------
          } else if (returnCode == NSAlertSecondButtonReturn) {
              [self.window close];
          }
        };

        // ---------------------------------------------------------------------
        //  Setup Alert
        // ---------------------------------------------------------------------
        PFCAlert *alert = [[PFCAlert alloc] init];
        [self setAlert:alert];

        // ---------------------------------------------------------------------
        //  Show Alert to User
        // ---------------------------------------------------------------------
        [alert showAlertUnsavedChangesWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Do you want to save the changes you made in the profile \"%@\"?",
                                                                                               @"Alert message when closing editor window when there are unsaved changes"),
                                                                             (self.profile.title.length != 0) ? self.profile.title : PFCProfileDefaultName]
                                  informativeText:NSLocalizedString(@"Your changes will be lost if you don't save them.",
                                                                    @"Alert informative text when closing editor window when there are unsaved changes")
                                           window:self.window
                                       returnCode:returnCodeBlock];

        // ---------------------------------------------------------------------
        //  Return NO so the window doesn't close
        // ---------------------------------------------------------------------
        return NO;
    } else {
        return YES;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTextFieldDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Used when selecting a new profile name to not allow invalid or empty name
// -----------------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Get current text in the text field
    // -------------------------------------------------------------------------
    NSString *inputText = [[notification.userInfo valueForKey:@"NSFieldEditor"] string];

    // -------------------------------------------------------------------------
    //  If name is invalid or empty, disable save button, else enable it
    // -------------------------------------------------------------------------
    if (self.alert.firstButton.enabled && (inputText.length == 0 || [inputText isEqualToString:PFCProfileDefaultName])) {
        [self.alert.firstButton setEnabled:NO];
    } else {
        [self.alert.firstButton setEnabled:YES];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)saveProfile {
    
    if (self.profile.title.length == 0) {
        
        // ---------------------------------------------------------------------
        //  Setup return block
        // ---------------------------------------------------------------------
        void (^returnValue)(NSString *_Nullable, NSInteger) = ^void(NSString *inputText, NSInteger returnCode) {
            
            // -------------------------------------------------------------------
            //  User selected: Save & Close
            // -------------------------------------------------------------------
            if (returnCode == NSAlertFirstButtonReturn) {
                [self.profile updateTitle:inputText];
                if (![self.profile save]) {
                    // FIXME - Show alert that save failed!
                }
                
                // ---------------------------------------------------------------
                //  Reload settings view to show the new title
                // ---------------------------------------------------------------
                [self.profile.editor.splitView.tableViewController reloadDataWithForcedReload:YES];
            }
        };
        
        // ---------------------------------------------------------------------
        //  Setup Alert
        // ---------------------------------------------------------------------
        PFCAlert *alert = [[PFCAlert alloc] init];
        [self setAlert:alert];
        
        // ---------------------------------------------------------------------
        //  Show Alert to User
        // ---------------------------------------------------------------------
        [alert showAlertTextInputWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Please enter a name for the profile:",
                                                                                          @"Alert message when closing editor window when there are unsaved changes")]
                             informativeText:nil
                                      window:self.window
                               defaultString:@""
                           placeholderString:NSLocalizedString(@"Profile Name", @"")
                            firstButtonTitle:PFCButtonTitleSave
                           secondButtonTitle:PFCButtonTitleCancel
                            thirdButtonTitle:nil
                     firstButtonInitialState:NO
                                      sender:self
                                 returnValue:returnValue];
        
        // ---------------------------------------------------------------------
        //  Select all text in the profile name text field
        // ---------------------------------------------------------------------
        [alert.textFieldInput selectText:self];
    } else {
        [self.profile save];
    }
    
}

@end

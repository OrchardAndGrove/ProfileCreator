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

#import "PFCAlert.h"
#import "PFCConstants.h"
#import "PFCProfile.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorFooter.h"
#import "PFCProfileEditorSettingsPopOver.h"
#import "PFCProfileEditorSplitView.h"
#import "PFCProfileEditorTableViewController.h"

@interface PFCProfileEditorFooter ()
@property (nonatomic, weak, nullable) PFCProfile *profile;
@property (nonatomic, readwrite, nonnull) NSView *view;
@property (nonatomic, strong, nonnull) NSButton *buttonSave;
@property (nonatomic, strong, nonnull) NSButton *buttonSettings;
@property (nonatomic, strong, nonnull) NSButton *buttonPopOver;
@property (nonatomic, strong, nonnull) PFCProfileEditorSettingsPopOver *settingsPopOver;
@property (nonatomic, weak, nullable) PFCProfileEditor *profileEditor;
@property (nonatomic, strong, nullable) PFCAlert *alert;
@end

@implementation PFCProfileEditorFooter

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfileEditor:(PFCProfileEditor *_Nonnull)profileEditor {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profileEditor = profileEditor;
        _profile = profileEditor.profile;
        _settingsPopOver = [[PFCProfileEditorSettingsPopOver alloc] initWithProfile:_profile];

        // ---------------------------------------------------------------------
        //  Create View
        // ---------------------------------------------------------------------
        _view = [[NSView alloc] init];
        [_view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_view setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
        [_view setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];

        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        //[self addButtonSave:constraints];
        [self addButtonSettings:constraints];
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
    [_buttonSave setTitle:NSLocalizedString(@"Save", @"")];
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

- (void)addButtonSettings:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Create and add Button Settings
    // -------------------------------------------------------------------------
    _buttonSettings = [[NSButton alloc] init];
    [_buttonSettings setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_buttonSettings setBezelStyle:NSRoundedBezelStyle];
    [_buttonSettings setButtonType:NSMomentaryPushInButton];
    [_buttonSettings setBordered:YES];
    [_buttonSettings setControlSize:NSSmallControlSize];
    [_buttonSettings setTransparent:NO];
    [_buttonSettings setTarget:self];
    [_buttonSettings setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [_buttonSettings setAction:@selector(showSettings:)];
    [_buttonSettings setTitle:NSLocalizedString(@"Settings", @"")];
    [_buttonSettings sizeToFit];
    [_buttonSettings setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_view addSubview:_buttonSettings];

    // -------------------------------------------------------------------------
    //  Setup constraints for button save
    // -------------------------------------------------------------------------
    // Center Vertically
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonSettings
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
                                                           toItem:_buttonSettings
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:10]];

    /*
    // Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonSave
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_buttonSettings
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:6]];
     */
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
                                      window:self.profileEditor.window
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

- (void)showSettings:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCSelectProfileSettingsNotification object:self.profileEditor userInfo:nil];
}

- (void)showPopOver:(id)sender {
    [self.settingsPopOver.popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
}

@end

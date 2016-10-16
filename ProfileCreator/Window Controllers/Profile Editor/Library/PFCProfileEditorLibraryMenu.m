//
//  PFCProfileEditorLibraryMenu.m
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
#import "PFCLog.h"
#import "PFCProfileEditorLibraryMenu.h"
#import "PFCProfileEditorLibraryPayloads.h"

@interface PFCProfileEditorLibraryMenu ()
@property (nonatomic, weak) PFCProfileEditorLibraryPayloads *library;
@property (nonatomic, readwrite, nonnull) NSStackView *stackView;
@property (nonatomic, strong, nonnull) NSMutableArray *stackViewButtons;
@property (nonatomic, strong, nonnull) NSButton *buttonLibraryApple;
@property (nonatomic, strong, nonnull) NSButton *buttonLibraryDeveloper;
@property (nonatomic, strong, nonnull) NSButton *buttonLibraryLocal;
@property (nonatomic, strong, nonnull) NSButton *buttonLibraryMCX;
@property (nonatomic, strong, nonnull) NSButton *buttonLibraryCustom;
@end

@implementation PFCProfileEditorLibraryMenu

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithLibraryPayloads:(PFCProfileEditorLibraryPayloads *_Nonnull)library {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _library = library;
        _stackViewButtons = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Setup StackView
        // ---------------------------------------------------------------------
        _stackView = [[NSStackView alloc] init];
        [_stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_stackView setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
        [_stackView setAlignment:NSLayoutAttributeCenterY];
        [_stackView setSpacing:10];
        [_stackView setDistribution:NSStackViewDistributionEqualSpacing];
        [_stackView setDetachesHiddenViews:YES];

        // ---------------------------------------------------------------------
        //  Setup KeyValue Observers
        // ---------------------------------------------------------------------
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryApple options:NSKeyValueObservingOptionNew context:nil];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryLocal options:NSKeyValueObservingOptionNew context:nil];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryMCX options:NSKeyValueObservingOptionNew context:nil];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryCustom options:NSKeyValueObservingOptionNew context:nil];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryDeveloper options:NSKeyValueObservingOptionNew context:nil];

        [self updateButtonsWithOverrideKeyPath:nil];
        [self buttonLibraryClicked:_stackViewButtons.firstObject];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister as observer
    // -------------------------------------------------------------------------
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryApple];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryLocal];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryMCX];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryCustom];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowPayloadLibraryDeveloper];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([change[NSKeyValueChangeNewKey] boolValue]) {
        [self updateButtonsWithOverrideKeyPath:keyPath];
        [self buttonLibraryClicked:self.stackViewButtons.firstObject];
    } else {
        NSButton *button = [self buttonForKeyPath:keyPath];
        if (button) {
            [self.stackView removeView:button];
            [self.stackViewButtons removeObject:button];
            if ([self.library selectedLibrary] == [self libraryForKeyPath:keyPath]) {
                [self buttonLibraryClicked:self.stackViewButtons.firstObject];
            }
        } else {
            DDLogError(@"No button returned!");
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)buttonLibraryClicked:(NSButton *)sender {
    [self.library selectLibrary:sender.tag];
    [sender setState:NSOnState];
    for (NSButton *button in self.stackViewButtons) {
        if (![button isEqual:sender]) {
            [button setState:NSOffState];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Return the library enum constant for KeyPath string
// -----------------------------------------------------------------------------
- (PFCPayloadLibrary)libraryForKeyPath:(NSString *)keyPath {
    if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryApple]) {
        return kPFCPayloadLibraryApple;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryLocal]) {
        return kPFCPayloadLibraryUserPreferences;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryMCX]) {
        return kPFCPayloadLibraryMCX;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryCustom]) {
        return kPFCPayloadLibraryCustom;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryDeveloper]) {
        return kPFCPayloadLibraryDeveloper;
    } else {
        return -1;
    }
}

// -----------------------------------------------------------------------------
//  Return the button instance for KeyPath string
// -----------------------------------------------------------------------------
- (NSButton *)buttonForKeyPath:(NSString *)keyPath {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryApple]) {
        if (!self.buttonLibraryApple) {
            [self setButtonLibraryApple:[self buttonLibraryWithImage:[NSImage imageNamed:@"Approval-18"]
                                                      alternateImage:[NSImage imageNamed:@"Approval Filled-18"]
                                                         constraints:constraints
                                                                 tag:kPFCPayloadLibraryApple]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
        return self.buttonLibraryApple;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryLocal]) {
        if (!self.buttonLibraryLocal) {
            [self setButtonLibraryLocal:[self buttonLibraryWithImage:[NSImage imageNamed:@"Home-15"]
                                                      alternateImage:[NSImage imageNamed:@"Home Filled-15"]
                                                         constraints:constraints
                                                                 tag:kPFCPayloadLibraryUserPreferences]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
        return self.buttonLibraryLocal;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryMCX]) {
        if (!self.buttonLibraryMCX) {
            [self setButtonLibraryMCX:[self buttonLibraryWithImage:[NSImage imageNamed:@"Settings-16"]
                                                    alternateImage:[NSImage imageNamed:@"Settings Filled-16"]
                                                       constraints:constraints
                                                               tag:kPFCPayloadLibraryMCX]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
        return self.buttonLibraryMCX;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryCustom]) {
        if (!self.buttonLibraryCustom) {
            [self setButtonLibraryCustom:[self buttonLibraryWithImage:[NSImage imageNamed:@"Settings-16"]
                                                       alternateImage:[NSImage imageNamed:@"Settings Filled-16"]
                                                          constraints:constraints
                                                                  tag:kPFCPayloadLibraryCustom]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
        return self.buttonLibraryCustom;
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryDeveloper]) {
        if (!self.buttonLibraryDeveloper) {
            [self setButtonLibraryDeveloper:[self buttonLibraryWithImage:[NSImage imageNamed:@"Settings-16"]
                                                          alternateImage:[NSImage imageNamed:@"Settings Filled-16"]
                                                             constraints:constraints
                                                                     tag:kPFCPayloadLibraryDeveloper]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
        return self.buttonLibraryDeveloper;
    } else {
        return nil;
    }
} // buttonForKeyPath

// -----------------------------------------------------------------------------
//  Create a button with passed properties
// -----------------------------------------------------------------------------
- (NSButton *)buttonLibraryWithImage:(NSImage *)image alternateImage:(NSImage *)alternateImage constraints:(NSMutableArray *)constraints tag:(NSInteger)tag {

    // -------------------------------------------------------------------------
    //  Create button
    // -------------------------------------------------------------------------
    NSButton *button = [[NSButton alloc] init];
    [button setBezelStyle:NSSmallSquareBezelStyle];
    [button setButtonType:NSToggleButton];
    [button setBordered:NO];
    [button setTransparent:NO];
    [button setTag:tag];
    [button setTarget:self];
    [button setAction:@selector(buttonLibraryClicked:)];
    [button setImagePosition:NSImageOnly];
    [button.cell setImageScaling:NSImageScaleProportionallyUpOrDown];
    [button setImage:image];
    [button setAlternateImage:alternateImage];

    // -------------------------------------------------------------------------
    //  Calculate Image Size
    // -------------------------------------------------------------------------
    NSArray *imageReps = [NSBitmapImageRep imageRepsWithData:[image TIFFRepresentation]];

    NSInteger width = 0;
    NSInteger height = 0;

    for (NSImageRep *imageRep in imageReps) {
        if (width < imageRep.pixelsWide) {
            width = imageRep.pixelsWide;
        }
        if (height < imageRep.pixelsHigh) {
            height = imageRep.pixelsHigh;
        }
    }

    // -------------------------------------------------------------------------
    //  Setup Button Height/Width from calculated size
    // -------------------------------------------------------------------------
    // Button - Height
    [constraints addObject:[NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:height]];

    // Button - Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:width]];

    return button;
} // buttonLibraryWithImage:alternateImage:constraints:tag

// -----------------------------------------------------------------------------
//  Setup Menu View depending on current user preferences
//  Called by KeyValue Observing whenerver a user changes a library preference
// -----------------------------------------------------------------------------
- (void)updateButtonsWithOverrideKeyPath:(NSString *)keyPath {

    // -------------------------------------------------------------------------
    //  Remove all current items from stack view
    // -------------------------------------------------------------------------
    [self.stackViewButtons removeAllObjects];
    for (NSView *view in self.stackView.views) {
        [self.stackView removeView:view];
    }

    // -------------------------------------------------------------------------
    //  Check all preferences, if enabled, add button to stack view
    // -------------------------------------------------------------------------
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([[ud valueForKey:PFCUserDefaultsShowPayloadLibraryApple] boolValue] || [keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryApple]) {
        NSButton *buttonApple = [self buttonForKeyPath:PFCUserDefaultsShowPayloadLibraryApple];
        if (buttonApple) {
            [self.stackViewButtons addObject:buttonApple];
            [self.stackView addView:buttonApple inGravity:NSStackViewGravityCenter];
        }
    }

    if ([[ud valueForKey:PFCUserDefaultsShowPayloadLibraryLocal] boolValue] || [keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryLocal]) {
        NSButton *buttonLocal = [self buttonForKeyPath:PFCUserDefaultsShowPayloadLibraryLocal];
        if (buttonLocal) {
            [self.stackViewButtons addObject:buttonLocal];
            [self.stackView addView:buttonLocal inGravity:NSStackViewGravityCenter];
        }
    }

    if ([[ud valueForKey:PFCUserDefaultsShowPayloadLibraryMCX] boolValue] || [keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryMCX]) {
        NSButton *buttonMCX = [self buttonForKeyPath:PFCUserDefaultsShowPayloadLibraryMCX];
        if (buttonMCX) {
            [self.stackViewButtons addObject:buttonMCX];
            [self.stackView addView:buttonMCX inGravity:NSStackViewGravityCenter];
        }
    }

    if ([[ud valueForKey:PFCUserDefaultsShowPayloadLibraryCustom] boolValue] || [keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryCustom]) {
        NSButton *buttonCustom = [self buttonForKeyPath:PFCUserDefaultsShowPayloadLibraryCustom];
        if (buttonCustom) {
            [self.stackViewButtons addObject:buttonCustom];
            [self.stackView addView:buttonCustom inGravity:NSStackViewGravityCenter];
        }
    }

    if ([[ud valueForKey:PFCUserDefaultsShowPayloadLibraryDeveloper] boolValue] || [keyPath isEqualToString:PFCUserDefaultsShowPayloadLibraryDeveloper]) {
        NSButton *buttonDeveloper = [self buttonForKeyPath:PFCUserDefaultsShowPayloadLibraryDeveloper];
        if (buttonDeveloper) {
            [self.stackViewButtons addObject:buttonDeveloper];
            [self.stackView addView:buttonDeveloper inGravity:NSStackViewGravityCenter];
        }
    }
} // updateButtonsWithOverrideKeyPath

@end

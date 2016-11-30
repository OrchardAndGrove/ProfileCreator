//
//  PFCProfileEditorToolbarItemTitle.m
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
#import "PFCProfileEditorToolbarItemTitle.h"

NSString *_Nonnull const PFCProfileEditorToolbarItemIdentifierTitle = @"Title";

@interface PFCProfileEditorToolbarItemTitle ()
@property (nonatomic, strong, readwrite, nonnull) NSToolbarItem *toolbarItem;
@property (nonatomic, strong, nonnull) NSTextField *textFieldTitle;
@property (nonatomic, strong, nonnull) NSString *profileTitle;
@property (nonatomic, strong, nonnull) NSString *localSelectionTitle;
@property (nonatomic, weak, nullable) PFCProfile *profile;
@end

@implementation PFCProfileEditorToolbarItemTitle

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

        // ---------------------------------------------------------------------
        //  Setup KeyValue Observers
        // ---------------------------------------------------------------------
        [_profile addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:nil];

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
        [_textFieldTitle setFont:[NSFont systemFontOfSize:18 weight:NSFontWeightLight]];
        [_textFieldTitle setTextColor:[NSColor controlTextColor]];
        [_textFieldTitle setAlignment:NSCenterTextAlignment];
        [_textFieldTitle setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:_textFieldTitle];

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints for TextField Title
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:0]];

        // Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:0]];

        // Horizontal
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0]];

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:constraints];

        // ---------------------------------------------------------------------
        //  Update the toolbar item view with the current size of the text field
        // ---------------------------------------------------------------------
        [self setFrame:NSMakeRect(0.0, 0.0, _textFieldTitle.intrinsicContentSize.width, 38.0)];

        // ---------------------------------------------------------------------
        //  Create the actual toolbar item and set it's view
        // ---------------------------------------------------------------------
        _toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PFCProfileEditorToolbarItemIdentifierTitle];
        [_toolbarItem setMinSize:NSMakeSize(_textFieldTitle.intrinsicContentSize.width, 38.0)];
        [_toolbarItem setMaxSize:NSMakeSize(_textFieldTitle.intrinsicContentSize.width, 38.0)];
        [_toolbarItem setView:self];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister as observer
    // -------------------------------------------------------------------------
    [_profile removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Used if wanting to add profile name before the title, like: My Profile - General
// -----------------------------------------------------------------------------
// FIXME - Decide if this should be used
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    /*
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
        NSString *newTitle = [change objectForKey:NSKeyValueChangeNewKey] ?: @"";
        [self setProfileTitle:[newTitle copy]];
        [self updateTitle];
    }
     */
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setSelectionTitle:(NSString *)title {
    // FIXME - Have two different values if I decide to add another string before selection title
    _selectionTitle = title;
    [self setLocalSelectionTitle:title];
    [self updateTitle];
}

- (void)updateTitle {
    // FIXME - Have two different values if I decide to add another string before selection title
    if (self.profileTitle.length == 0) {
        [self.textFieldTitle setStringValue:self.localSelectionTitle];
    } else {
        [self.textFieldTitle setStringValue:self.localSelectionTitle];
        // [self.textFieldTitle setStringValue:[NSString stringWithFormat:@"%@ - %@", self.profileTitle, self.localSelectionTitle]];
    }

    // -------------------------------------------------------------------------
    //  Update the toolbar item view with the current size of the text field
    // -------------------------------------------------------------------------
    [self.toolbarItem setMinSize:NSMakeSize(self.textFieldTitle.intrinsicContentSize.width, 38.0)];
    [self.toolbarItem setMaxSize:NSMakeSize(self.textFieldTitle.intrinsicContentSize.width, 38.0)];
    [self setFrame:NSMakeRect(0.0, 0.0, self.textFieldTitle.intrinsicContentSize.width, 38.0)];
}

@end

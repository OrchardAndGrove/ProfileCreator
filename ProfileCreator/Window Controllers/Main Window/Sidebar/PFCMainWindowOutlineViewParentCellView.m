//
//  PFCMainWindowOutlineViewParentCellView.m
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
#import "PFCMainWindowOutlineViewParentCellView.h"

@interface PFCMainWindowOutlineViewParentCellView ()
@property (nonatomic, strong) NSTextField *textFieldTitle;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, weak) id<PFCMainWindowOutlineViewParent> parent;
@end

@implementation PFCMainWindowOutlineViewParentCellView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithParent:(id<PFCMainWindowOutlineViewParent> _Nonnull)parent {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _parent = parent;

        // ---------------------------------------------------------------------
        //  Setup TextField
        // ---------------------------------------------------------------------
        [self addTextFieldTitle];

        // ---------------------------------------------------------------------
        //  If parent allows adding groups, setup button
        // ---------------------------------------------------------------------
        if (parent.isEditable) {
            [self addButtonAdd];
        }

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints
        // ---------------------------------------------------------------------
        [self setupConstraints];
    }
    return self;
} // initWithGroup

- (void)addTextFieldTitle {
    NSTextField *textFieldTitle = [[NSTextField alloc] init];
    [textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldTitle setBordered:NO];
    [textFieldTitle setBezeled:NO];
    [textFieldTitle setDrawsBackground:NO];
    [textFieldTitle setEditable:NO];
    [textFieldTitle setSelectable:NO];
    [textFieldTitle setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize] weight:NSFontWeightMedium]];
    [textFieldTitle setTextColor:[NSColor secondaryLabelColor]];
    [textFieldTitle setAlignment:NSLeftTextAlignment];
    [textFieldTitle setLineBreakMode:NSLineBreakByTruncatingTail];
    _textFieldTitle = textFieldTitle;
    [self addSubview:_textFieldTitle];
} // addTextFieldTitle

- (void)addButtonAdd {
    NSButton *buttonAdd = [[NSButton alloc] init];
    [buttonAdd setTranslatesAutoresizingMaskIntoConstraints:NO];
    [buttonAdd setBezelStyle:NSInlineBezelStyle];
    [buttonAdd setButtonType:NSMomentaryChangeButton];
    [buttonAdd setBordered:NO];
    [buttonAdd setTransparent:NO];
    [buttonAdd setImagePosition:NSImageOnly];
    [buttonAdd setImage:[NSImage imageNamed:NSImageNameAddTemplate]];
    [[buttonAdd cell] setHighlightsBy:NSPushInCellMask | NSChangeBackgroundCellMask];
    [buttonAdd sizeToFit];
    [buttonAdd setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [buttonAdd setTarget:self];
    [buttonAdd setAction:@selector(addGroup)];
    [buttonAdd setHidden:YES];
    _buttonAdd = buttonAdd;
    [self addSubview:_buttonAdd];
} // addButtonAdd

- (void)setupConstraints {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];

    // TextField - Center Vertically
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // TextField - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:2]];

    if (_buttonAdd != nil) {

        // ButtonAdd - Center Vertically
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonAdd
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0]];

        // ButtonAdd - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonAdd
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:4]];

        // ButtonAdd - Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonAdd
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:1]];

    } else {

        // TextField - Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:2]];
    }

    [NSLayoutConstraint activateConstraints:constraints];
} // addLayoutConstraints

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)addGroup {
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCAddGroupNotification object:self userInfo:@{PFCNotificationUserInfoParentTitle : self.parent.title}];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSResponder Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)mouseEntered:(NSEvent *)theEvent {
    [self.buttonAdd setHidden:NO];
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    [self.buttonAdd setHidden:YES];
} // mouseExited

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)viewWillDraw {
    [super viewWillDraw];
    [self.textFieldTitle setStringValue:[self.parent.title uppercaseString]];
} // viewWillDraw

- (void)updateTrackingAreas {
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }

    NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

@end

//
//  PFCMainWindowOutlineViewChildCellView.m
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
#import "PFCMainWindowOutlineViewChildCellView.h"

@interface PFCMainWindowOutlineViewChildCellView ()
@property (nonatomic, strong) NSTextField *textFieldTitle;
@property (nonatomic, readwrite, strong, nullable) NSImage *icon;
@property (nonatomic, strong, nullable) NSButton *buttonCount;
@property (nonatomic, strong, nullable) NSImageView *iconImageView;
@property (nonatomic, weak) id<PFCMainWindowOutlineViewChild> child;

@property (nonatomic, strong, nonnull) NSLayoutConstraint *constraintTextFieldToButtonCount;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *constraintTextFieldToSuperview;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *constraintIconToTextField;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *constraintSuperviewToTextField;
@end

@implementation PFCMainWindowOutlineViewChildCellView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithChild:(id<PFCMainWindowOutlineViewChild> _Nonnull)child {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _child = child;
        _icon = child.icon;

        // ---------------------------------------------------------------------
        //  Setup KeyValue Observers
        // ---------------------------------------------------------------------
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowProfileCount options:NSKeyValueObservingOptionNew context:nil];
        [ud addObserver:self forKeyPath:PFCUserDefaultsShowGroupIcons options:NSKeyValueObservingOptionNew context:nil];

        // ---------------------------------------------------------------------
        //  Setup View Items
        // ---------------------------------------------------------------------
        [self addTextFieldTitle];
        [self addButtonCount];
        [self addIcon];

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints
        // ---------------------------------------------------------------------
        [self setupConstraints];

        // ---------------------------------------------------------------------
        //  Setup Initial Values for showProfileCount and showIcon
        // ---------------------------------------------------------------------
        [self showProfileCount:[[[NSUserDefaults standardUserDefaults] objectForKey:PFCUserDefaultsShowProfileCount] boolValue]];
        [self showIcon:[[[NSUserDefaults standardUserDefaults] objectForKey:PFCUserDefaultsShowGroupIcons] boolValue]];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister as observer
    // -------------------------------------------------------------------------
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowProfileCount context:nil];
    [ud removeObserver:self forKeyPath:PFCUserDefaultsShowGroupIcons context:nil];
}

- (void)addTextFieldTitle {
    NSTextField *textFieldTitle = [[NSTextField alloc] init];
    [textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldTitle setBordered:NO];
    [textFieldTitle setBezeled:NO];
    [textFieldTitle setDrawsBackground:NO];
    [textFieldTitle setEditable:_child.isEditable];
    [textFieldTitle setDelegate:_child];
    [textFieldTitle setFont:[NSFont systemFontOfSize:12]];
    [textFieldTitle setTextColor:[NSColor controlTextColor]];
    [textFieldTitle setAlignment:NSLeftTextAlignment];
    [textFieldTitle setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [textFieldTitle setLineBreakMode:NSLineBreakByTruncatingTail];
    [self addSubview:textFieldTitle];
    _textFieldTitle = textFieldTitle;
}

- (void)addButtonCount {
    NSButton *buttonCount = [[NSButton alloc] init];
    [buttonCount setTranslatesAutoresizingMaskIntoConstraints:NO];
    [buttonCount setBezelStyle:NSInlineBezelStyle];
    [buttonCount setButtonType:NSMomentaryPushInButton];
    [buttonCount setBordered:YES];
    [buttonCount setTransparent:NO];
    [buttonCount setTitle:@"0"];
    [buttonCount setFont:[NSFont boldSystemFontOfSize:12]];
    [buttonCount sizeToFit];
    [[buttonCount cell] setHighlightsBy:0];
    [buttonCount setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [buttonCount setHidden:![[[NSUserDefaults standardUserDefaults] objectForKey:PFCUserDefaultsShowProfileCount] boolValue]];
    [self addSubview:buttonCount];
    _buttonCount = buttonCount;
}

- (void)addIcon {
    NSImageView *imageView = [[NSImageView alloc] init];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [imageView setImage:_icon];
    [self addSubview:imageView];
    _iconImageView = imageView;
}

- (void)setupConstraints {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];

    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------

    // Icon - Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_iconImageView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:16]];

    // Icon - Height
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_iconImageView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:16]];

    // Icon - Center Vertical
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_iconImageView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // Icon - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_iconImageView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:16]];

    // Icon - Trailing
    _constraintIconToTextField = [NSLayoutConstraint constraintWithItem:_iconImageView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_textFieldTitle
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:-6];
    [constraints addObject:_constraintIconToTextField];

    // ---------------------------------------------------------------------
    //  TextField
    // ---------------------------------------------------------------------

    // TextField - Center Vertical
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // TextField - Leading
    _constraintSuperviewToTextField = [NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0
                                                                    constant:16];
    [constraints addObject:_constraintSuperviewToTextField];

    // TextField - Trailing
    _constraintTextFieldToSuperview = [NSLayoutConstraint constraintWithItem:_textFieldTitle
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1.0
                                                                    constant:-8];
    [constraints addObject:_constraintTextFieldToSuperview];

    // ---------------------------------------------------------------------
    //  ButtonCount
    // ---------------------------------------------------------------------

    // ButtonCount - Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonCount
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:24]];

    // ButtonCount - Height
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonCount
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:18]];

    // ButtonCount - Center Vertical
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonCount
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];

    // ButtonCount - Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonCount
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:-4]];

    // ButtonCount - Leading
    _constraintTextFieldToButtonCount = [NSLayoutConstraint constraintWithItem:_buttonCount
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_textFieldTitle
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:6];
    [constraints addObject:_constraintTextFieldToButtonCount];

    [NSLayoutConstraint activateConstraints:constraints];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:PFCUserDefaultsShowProfileCount]) {
        BOOL showProfileCount = [change[NSKeyValueChangeNewKey] boolValue];
        [self showProfileCount:showProfileCount];
    } else if ([keyPath isEqualToString:PFCUserDefaultsShowGroupIcons]) {
        BOOL showIcon = [change[NSKeyValueChangeNewKey] boolValue];
        [self showIcon:showIcon];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showProfileCount:(BOOL)show {
    if (show) {
        [_constraintTextFieldToSuperview setActive:NO];
        [_constraintTextFieldToButtonCount setActive:YES];
    } else {
        [_constraintTextFieldToButtonCount setActive:NO];
        [_constraintTextFieldToSuperview setActive:YES];
    }
    [self.buttonCount setHidden:!show];
}

- (void)showIcon:(BOOL)show {
    if (show) {
        [_constraintSuperviewToTextField setActive:NO];
        [_constraintIconToTextField setActive:YES];
    } else {
        [_constraintIconToTextField setActive:NO];
        [_constraintSuperviewToTextField setActive:YES];
    }
    [self.iconImageView setHidden:!show];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)viewWillDraw {
    [super viewWillDraw];
    [self.textFieldTitle setStringValue:self.child.title];
    [self.buttonCount setTitle:[@(self.child.profileIdentifiers.count) stringValue]];
}

@end

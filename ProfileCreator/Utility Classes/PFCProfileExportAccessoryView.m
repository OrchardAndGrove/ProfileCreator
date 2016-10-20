//
//  PFCProfileExportAccessoryView.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-10-19.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFCProfileExportAccessoryView.h"

@interface PFCProfileExportAccessoryView ()
@property (nonatomic) NSInteger height;
@property (nonatomic) BOOL setupWidth;

@property (nonatomic, strong, nonnull) NSTextField *textFieldLabelUpdatePayloadVersions;
@property (nonatomic, strong, nonnull) NSButton *checkboxUpdatePayloadVersions;

@property (nonatomic, strong, nonnull) NSTextField *textFieldLabelScope; // Top
@property (nonatomic, strong, nonnull) NSPopUpButton *popUpButtonScope;

@property (nonatomic, strong, nonnull) NSTextField *textFieldLabelDistribution;
@property (nonatomic, strong, nonnull) NSPopUpButton *popUpButtonDistribution;

@end

@implementation PFCProfileExportAccessoryView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithProfile:(PFCProfile *_Nonnull)profile {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup properties
        // ---------------------------------------------------------------------
        _height = 0;
        _scope = profile.scope;
        _distribution = profile.distribution;
        _updatePayloadVersions = YES;

        // ---------------------------------------------------------------------
        //  Setup self (view)
        // ---------------------------------------------------------------------
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];

        // ---------------------------------------------------------------------
        //  Create and add items to view
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        [self addSettingScope:constraints enabled:NO labelAbove:nil];
        [self addSettingDistribution:constraints enabled:NO labelAbove:_textFieldLabelScope];
        [self addSettingUpdatePayloadVersions:constraints enabled:NO labelAbove:_textFieldLabelDistribution];

        // ---------------------------------------------------------------------
        //  Setup constraints for top item
        // ---------------------------------------------------------------------
        // Item - Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textFieldLabelScope
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:6]];

        _height = (_height + 6);

        // Item - Bottom
        _height = (_height + 8);

        // ---------------------------------------------------------------------
        //  Setup constraints for self (View)
        // ---------------------------------------------------------------------
        // Height
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:_height]];

        // Width
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:400]];

        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

- (void)dealloc {
    [_popUpButtonScope unbind:NSSelectedTagBinding];
    [_popUpButtonDistribution unbind:NSSelectedTagBinding];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setup Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)addSettingScope:(NSMutableArray *_Nonnull)constraints enabled:(BOOL)enabled labelAbove:(NSTextField *_Nullable)labelAbove {

    // ---------------------------------------------------------------------
    //  Create and add TextField Label Scope
    // ---------------------------------------------------------------------
    _textFieldLabelScope = [self textFieldLabelWithTitle:NSLocalizedString(@"Scope:", @"") labelAbove:labelAbove constraints:constraints enabled:enabled];

    if (enabled) {

        // ---------------------------------------------------------------------
        //  Create and add PopUpButton Scope
        // ---------------------------------------------------------------------
        _popUpButtonScope = [[NSPopUpButton alloc] init];
        [_popUpButtonScope setControlSize:NSSmallControlSize];
        [_popUpButtonScope setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_popUpButtonScope setEnabled:enabled];
        [PFPUtility addScopeMenuItemsToMenu:_popUpButtonScope.menu controlSize:NSSmallControlSize];
        [self addSubview:_popUpButtonScope];

        [_popUpButtonScope bind:NSSelectedTagBinding toObject:self withKeyPath:NSStringFromSelector(@selector(scope)) options:nil];

        _height = (_height + _popUpButtonScope.intrinsicContentSize.height);

        // -------------------------------------------------------------------------
        //  Setup layout constraints
        // -------------------------------------------------------------------------
        // PopUpButton - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_popUpButtonScope
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:2]];

        // PopUpButton - Baseline
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_popUpButtonScope
                                                            attribute:NSLayoutAttributeBaseline
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldLabelScope
                                                            attribute:NSLayoutAttributeBaseline
                                                           multiplier:1.0
                                                             constant:0]];
    } else {
        [self textFieldValueWithString:[PFPUtility stringForScope:_scope] label:_textFieldLabelScope constraints:constraints enabled:enabled];
    }
}

- (void)addSettingDistribution:(NSMutableArray *_Nonnull)constraints enabled:(BOOL)enabled labelAbove:(NSTextField *_Nullable)labelAbove {

    // -------------------------------------------------------------------------
    //  Create and add TextField Label Distribution
    // -------------------------------------------------------------------------
    _textFieldLabelDistribution = [self textFieldLabelWithTitle:NSLocalizedString(@"Distribution:", @"") labelAbove:labelAbove constraints:constraints enabled:enabled];

    if (enabled) {

        // ---------------------------------------------------------------------
        //  Create and add PopUpButton Distribution
        // ---------------------------------------------------------------------
        _popUpButtonDistribution = [[NSPopUpButton alloc] init];
        [_popUpButtonDistribution setControlSize:NSSmallControlSize];
        [_popUpButtonDistribution setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_popUpButtonDistribution setEnabled:enabled];
        [PFPUtility addDistributionMenuItemsToMenu:_popUpButtonDistribution.menu controlSize:NSSmallControlSize];
        [self addSubview:_popUpButtonDistribution];

        _height = (_height + _popUpButtonDistribution.intrinsicContentSize.height);

        [_popUpButtonDistribution bind:NSSelectedTagBinding toObject:self withKeyPath:NSStringFromSelector(@selector(distribution)) options:nil];

        // ---------------------------------------------------------------------
        //  Setup layout constraints
        // ---------------------------------------------------------------------
        // PopUpButton - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_popUpButtonDistribution
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:2]];

        // PopUpButton - Baseline
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_popUpButtonDistribution
                                                            attribute:NSLayoutAttributeBaseline
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_textFieldLabelDistribution
                                                            attribute:NSLayoutAttributeBaseline
                                                           multiplier:1.0
                                                             constant:0]];
    } else {
        [self textFieldValueWithString:[PFPUtility stringForDistribution:_distribution] label:_textFieldLabelDistribution constraints:constraints enabled:enabled];
    }
}

- (void)addSettingUpdatePayloadVersions:(NSMutableArray *_Nonnull)constraints enabled:(BOOL)enabled labelAbove:(NSTextField *_Nullable)labelAbove {

    // -------------------------------------------------------------------------
    //  Create and add TextField Label Scope
    // -------------------------------------------------------------------------
    _textFieldLabelUpdatePayloadVersions = [self textFieldLabelWithTitle:NSLocalizedString(@"Update Payload Versions:", @"") labelAbove:labelAbove constraints:constraints enabled:enabled];

    // -------------------------------------------------------------------------
    //  Create and add Checkbox Distribution
    // -------------------------------------------------------------------------
    _checkboxUpdatePayloadVersions = [[NSButton alloc] init];
    [_checkboxUpdatePayloadVersions setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_checkboxUpdatePayloadVersions setButtonType:NSSwitchButton];
    [_checkboxUpdatePayloadVersions setTitle:@""];
    [_checkboxUpdatePayloadVersions setEnabled:enabled];

    [self addSubview:_checkboxUpdatePayloadVersions];

    _height = (_height + _checkboxUpdatePayloadVersions.intrinsicContentSize.height);

    if (enabled) {
        [_checkboxUpdatePayloadVersions bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(updatePayloadVersions)) options:nil];
    } else if (_updatePayloadVersions) {
        [_checkboxUpdatePayloadVersions setState:NSOnState];
    }

    // -------------------------------------------------------------------------
    //  Setup layout constraints
    // -------------------------------------------------------------------------
    // Checkbox - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_checkboxUpdatePayloadVersions
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:2]];

    // Checkbox - Baseline
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_checkboxUpdatePayloadVersions
                                                        attribute:NSLayoutAttributeBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_textFieldLabelUpdatePayloadVersions
                                                        attribute:NSLayoutAttributeBaseline
                                                       multiplier:1.0
                                                         constant:0]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Item Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSTextField *_Nonnull)textFieldLabelWithTitle:(NSString *_Nullable)title labelAbove:(NSTextField *_Nullable)labelAbove constraints:(NSMutableArray *_Nonnull)constraints enabled:(BOOL)enabled {

    NSTextField *textFieldLabel = [[NSTextField alloc] init];
    [textFieldLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldLabel setBordered:NO];
    [textFieldLabel setBezeled:NO];
    [textFieldLabel setDrawsBackground:NO];
    [textFieldLabel setEditable:NO];
    [textFieldLabel setControlSize:NSSmallControlSize];
    [textFieldLabel setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [textFieldLabel setTextColor:[NSColor controlTextColor]];
    [textFieldLabel setAlignment:NSRightTextAlignment];
    [textFieldLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [textFieldLabel setStringValue:title ?: @""];
    [self addSubview:textFieldLabel];

    // ---------------------------------------------------------------------
    //  Setup constraints for TextField Label
    // ---------------------------------------------------------------------
    // TextField Label - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldLabel
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:6]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:textFieldLabel
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:2]];

    if (labelAbove) {

        // TextField Label - Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldLabel
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:labelAbove
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:6]];

        _height = (_height + 6);
    }

    return textFieldLabel;
}

- (NSTextField *_Nonnull)textFieldValueWithString:(NSString *_Nullable)string label:(NSTextField *_Nullable)label constraints:(NSMutableArray *_Nonnull)constraints enabled:(BOOL)enabled {

    NSTextField *textFieldValue = [[NSTextField alloc] init];
    [textFieldValue setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldValue setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldValue setBordered:NO];
    [textFieldValue setBezeled:NO];
    [textFieldValue setDrawsBackground:NO];
    [textFieldValue setEditable:NO];
    [textFieldValue setControlSize:NSSmallControlSize];
    [textFieldValue setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [textFieldValue setTextColor:[NSColor controlTextColor]];
    [textFieldValue setAlignment:NSRightTextAlignment];
    [textFieldValue setLineBreakMode:NSLineBreakByTruncatingTail];
    [textFieldValue setStringValue:string ?: @""];
    [self addSubview:textFieldValue];

    _height = (_height + textFieldValue.intrinsicContentSize.height);

    // ---------------------------------------------------------------------
    //  Setup constraints for TextField Label
    // ---------------------------------------------------------------------
    // TextField Value - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldValue
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:2]];

    // TextField Value - Baseline
    [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldValue
                                                        attribute:NSLayoutAttributeBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:label
                                                        attribute:NSLayoutAttributeBaseline
                                                       multiplier:1.0
                                                         constant:0]];

    return textFieldValue;
}

@end

//
//  PFCProfileEditorLibraryProfilePayloadsTableViewItemCellView.m
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

#import "PFCProfileEditorLibraryPayloads.h"
#import "PFCProfileEditorLibraryPayloadsCellViewProfile.h"
@import QuartzCore;

NSInteger const PFCProfileEditorLibraryPayloadsCellViewProfileLeading = 5;
NSInteger const PFCProfileEditorLibraryPayloadsCellViewProfileButtonWidth = 14;

@interface PFCProfileEditorLibraryPayloadsCellViewProfile ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *constraintIconLeading;
@property (nonatomic, strong, nonnull) NSButton *buttonDisable;
@property (nonatomic) NSInteger buttonToggleWidthIndent;
@property (nonatomic) BOOL isMovable;
@end

@implementation PFCProfileEditorLibraryPayloadsCellViewProfile

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithTitle:(NSString *_Nonnull)title description:(NSString *_Nonnull)description icon:(NSImage *_Nullable)icon row:(NSInteger)row sender:(id _Nonnull)sender {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _buttonToggleWidthIndent = ((PFCProfileEditorLibraryPayloadsCellViewProfileLeading * 2) + PFCProfileEditorLibraryPayloadsCellViewProfileButtonWidth);

        // ---------------------------------------------------------------------
        //  Setup ImageView Icon
        // ---------------------------------------------------------------------
        NSImageView *imageViewIcon = [[NSImageView alloc] init];
        [imageViewIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageViewIcon setImageScaling:NSImageScaleProportionallyUpOrDown];
        [imageViewIcon setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];

        // FIXME - Should have a placeholder icon for those without
        if (icon) {
            [imageViewIcon setImage:icon];
        }
        [self addSubview:imageViewIcon];

        // ---------------------------------------------------------------------
        //  Setup constraints for ImageView Icon
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // ImageView Icon - Width
        [constraints addObject:[NSLayoutConstraint constraintWithItem:imageViewIcon
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:31]];

        // ImageView Icon - Height
        [constraints addObject:[NSLayoutConstraint constraintWithItem:imageViewIcon
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:imageViewIcon
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0f
                                                             constant:0]];

        // ImageView Icon - Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:imageViewIcon
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:4]];

        // ImageView Icon - Bottom
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                               toItem:imageViewIcon
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:4]];

        // ImageView Icon - Leading
        _constraintIconLeading = [NSLayoutConstraint constraintWithItem:imageViewIcon
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:PFCProfileEditorLibraryPayloadsCellViewProfileLeading];
        [constraints addObject:_constraintIconLeading];

        // ---------------------------------------------------------------------
        //  Hardcoded check if this is the item at index 0 (row),
        //  which means it's the General payload that's not allowed to be removed
        // ---------------------------------------------------------------------
        if (0 < row) {

            // -----------------------------------------------------------------
            //  Set it to be movable
            // -----------------------------------------------------------------
            _isMovable = YES;

            // -----------------------------------------------------------------
            //  Create and add Button Disable
            // -----------------------------------------------------------------
            _buttonDisable = [[NSButton alloc] init];
            [_buttonDisable setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_buttonDisable setBezelStyle:NSRegularSquareBezelStyle];
            [_buttonDisable setButtonType:NSMomentaryChangeButton];
            [_buttonDisable setBordered:NO];
            [_buttonDisable setTransparent:NO];
            [_buttonDisable setImagePosition:NSImageOnly];
            [_buttonDisable setImage:[NSImage imageNamed:NSImageNameRemoveTemplate]];
            [[_buttonDisable cell] setHighlightsBy:NSPushInCellMask | NSChangeBackgroundCellMask];
            [_buttonDisable setTarget:sender];
            [_buttonDisable setTag:row];
            [_buttonDisable setAction:@selector(togglePayload:)];
            [_buttonDisable sizeToFit];
            [_buttonDisable setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
            [_buttonDisable setHidden:YES];
            [self addSubview:_buttonDisable];

            // -----------------------------------------------------------------
            //  Setup constraints for Button Disable
            // -----------------------------------------------------------------
            // Button Disable - Leading
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonDisable
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:PFCProfileEditorLibraryPayloadsCellViewProfileLeading]];

            // Button Disable - Center Vertically
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonDisable
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0]];

            // Button Disable - Height
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonDisable
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:PFCProfileEditorLibraryPayloadsCellViewProfileButtonWidth]];

            // Button Disable - Width
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonDisable
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:PFCProfileEditorLibraryPayloadsCellViewProfileButtonWidth]];
        } else {
            _isMovable = NO;
        }

        // ---------------------------------------------------------------------
        //  Create and add TextField Title
        // ---------------------------------------------------------------------
        NSTextField *textFieldTitle = [[NSTextField alloc] init];
        [textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
        [textFieldTitle setBordered:NO];
        [textFieldTitle setBezeled:NO];
        [textFieldTitle setDrawsBackground:NO];
        [textFieldTitle setEditable:NO];
        [textFieldTitle setControlSize:NSRegularControlSize];
        [textFieldTitle setFont:[NSFont boldSystemFontOfSize:12]];
        [textFieldTitle setTextColor:[NSColor controlTextColor]];
        [textFieldTitle setAlignment:NSLeftTextAlignment];
        [textFieldTitle setLineBreakMode:NSLineBreakByTruncatingTail];
        [textFieldTitle setStringValue:title];
        [self addSubview:textFieldTitle];

        // ---------------------------------------------------------------------
        //  Setup constraints for TextField Title
        // ---------------------------------------------------------------------
        // TextField Title - Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:4.5]];

        // TextField Title - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:imageViewIcon
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:6]];

        // TextField Title - Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:6]];

        // ---------------------------------------------------------------------
        //  Create and add TextField Description
        // ---------------------------------------------------------------------
        NSTextField *textFieldDescription = [[NSTextField alloc] init];
        [textFieldDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textFieldDescription setLineBreakMode:NSLineBreakByWordWrapping];
        [textFieldDescription setBordered:NO];
        [textFieldDescription setBezeled:NO];
        [textFieldDescription setDrawsBackground:NO];
        [textFieldDescription setEditable:NO];
        [textFieldDescription setFont:[NSFont systemFontOfSize:10]];
        [textFieldDescription setControlSize:NSRegularControlSize];
        [textFieldDescription setTextColor:[NSColor controlShadowColor]];
        [textFieldDescription setAlignment:NSLeftTextAlignment];
        [textFieldDescription setLineBreakMode:NSLineBreakByTruncatingTail];
        [textFieldDescription setStringValue:description];
        [self addSubview:textFieldDescription];

        // ---------------------------------------------------------------------
        //  Setup constraints for TextField Description
        // ---------------------------------------------------------------------
        // TextField Description - Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldDescription
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:textFieldTitle
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:1]];

        // TextField Description - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:textFieldDescription
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:0]];

        // TextField Description - Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:textFieldDescription
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:0]];

        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSResponder Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)mouseEntered:(NSEvent *)theEvent {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
      [context setDuration:0.1];
      [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
      [self.buttonDisable setHidden:NO];
      [[self.constraintIconLeading animator] setConstant:self.buttonToggleWidthIndent];
    }
        completionHandler:^{
        }];

} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
      [context setDuration:0.08];
      [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
      [[self.constraintIconLeading animator] setConstant:PFCProfileEditorLibraryPayloadsCellViewProfileLeading];
      [[self.buttonDisable animator] setHidden:YES];
    }
        completionHandler:^{
        }];
} // mouseExited

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updateTrackingAreas {
    if (self.isMovable) {
        if (self.trackingArea != nil) {
            [self removeTrackingArea:self.trackingArea];
        }

        NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
        NSRect rect = self.bounds;
        rect.size.width = (rect.size.width / 3);
        [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:rect options:opts owner:self userInfo:nil]];
        [self addTrackingArea:self.trackingArea];
    }
} // updateTrackingAreas

@end

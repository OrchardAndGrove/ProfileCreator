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
#import "PFCProfileEditorLibraryPayloadsCellViewLibrary.h"
@import QuartzCore;

NSInteger const PFCProfileEditorLibraryPayloadsCellViewLibraryLeading = 5;
NSInteger const PFCProfileEditorLibraryPayloadsCellViewLibraryButtonWidth = 14;

@interface PFCProfileEditorLibraryPayloadsCellViewLibrary ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *constraintIconLeading;
@property (nonatomic, strong, nonnull) NSButton *buttonEnable;
@property (nonatomic) NSInteger buttonToggleWidthIndent;
@end

@implementation PFCProfileEditorLibraryPayloadsCellViewLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithTitle:(NSString *_Nonnull)title icon:(NSImage *_Nullable)icon row:(NSInteger)row sender:(id _Nonnull)sender {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _buttonToggleWidthIndent = ((PFCProfileEditorLibraryPayloadsCellViewLibraryLeading * 2) + PFCProfileEditorLibraryPayloadsCellViewLibraryButtonWidth);

        // ---------------------------------------------------------------------
        //  Setup ImageView Icon
        // ---------------------------------------------------------------------
        NSImageView *imageView = [[NSImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [imageView setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
        // FIXME - Should have a placeholder icon for those without
        if (icon) {
            [imageView setImage:icon];
        }
        [self addSubview:imageView];

        // ---------------------------------------------------------------------
        //  Setup constraints for ImageView Icon
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // ImageView Icon - Width
        [constraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:28]];

        // ImageView Icon - Height
        [constraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant:28]];

        // ImageView Icon - Top
        [constraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:2]];

        // ImageView Icon - Bottom
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:imageView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:2]];

        // ImageView Icon - Leading
        _constraintIconLeading = [NSLayoutConstraint constraintWithItem:imageView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:PFCProfileEditorLibraryPayloadsCellViewLibraryLeading];
        [constraints addObject:_constraintIconLeading];

        // ---------------------------------------------------------------------
        //  Create and add Button Enable
        // ---------------------------------------------------------------------
        _buttonEnable = [[NSButton alloc] init];
        [_buttonEnable setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_buttonEnable setBezelStyle:NSRegularSquareBezelStyle];
        [_buttonEnable setButtonType:NSMomentaryChangeButton];
        [_buttonEnable setBordered:NO];
        [_buttonEnable setTransparent:NO];
        [_buttonEnable setImagePosition:NSImageOnly];
        [_buttonEnable setImage:[NSImage imageNamed:NSImageNameAddTemplate]];
        [[_buttonEnable cell] setHighlightsBy:NSPushInCellMask | NSChangeBackgroundCellMask];
        [_buttonEnable setTarget:sender];
        [_buttonEnable setTag:row];
        [_buttonEnable setAction:@selector(togglePayload:)];
        [_buttonEnable sizeToFit];
        [_buttonEnable setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
        [_buttonEnable setHidden:YES];
        [self addSubview:_buttonEnable];

        // ---------------------------------------------------------------------
        //  Setup constraints for Button Enable
        // ---------------------------------------------------------------------
        // Button Enable - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonEnable
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:PFCProfileEditorLibraryPayloadsCellViewLibraryLeading]];

        // Button Enable - Center Vertically
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_buttonEnable
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:1]];

        // Button Enable - Height
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonEnable
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:PFCProfileEditorLibraryPayloadsCellViewLibraryButtonWidth]];

        // Button Enable - Width
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonEnable
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:PFCProfileEditorLibraryPayloadsCellViewLibraryButtonWidth]];

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
        [textFieldTitle setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightSemibold]];
        [textFieldTitle setTextColor:[NSColor controlTextColor]];
        [textFieldTitle setAlignment:NSLeftTextAlignment];
        [textFieldTitle setLineBreakMode:NSLineBreakByTruncatingTail];
        [textFieldTitle setStringValue:title];
        [self addSubview:textFieldTitle];

        // ---------------------------------------------------------------------
        //  Setup constraints for TextField Title
        // ---------------------------------------------------------------------
        // TextField Title - Vertical
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0]];
        // TextField Title - Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:imageView
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:4]];

        // TextField Title - Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:textFieldTitle
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:4]];

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
      [self.buttonEnable setHidden:NO];
      [[self.constraintIconLeading animator] setConstant:self.buttonToggleWidthIndent];
    }
        completionHandler:^{
        }];
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
      [context setDuration:0.08];
      [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
      [[self.constraintIconLeading animator] setConstant:PFCProfileEditorLibraryPayloadsCellViewLibraryLeading];
      [[self.buttonEnable animator] setHidden:YES];
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
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }

    NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    NSRect rect = self.bounds;
    rect.size.width = (rect.size.width / 3);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:rect options:opts owner:self userInfo:nil]];
    [self addTrackingArea:self.trackingArea];
} // updateTrackingAreas

@end

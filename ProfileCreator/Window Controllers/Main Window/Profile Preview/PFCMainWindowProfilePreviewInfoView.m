//
//  PFCMainWindowProfilePreviewInfoView.m
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

#import "PFCMainWindowProfilePreviewInfoView.h"

@interface PFCMainWindowProfilePreviewInfoView ()
@property (nonatomic, readwrite, nonnull) NSView *view;
@property (nonatomic, nonnull) NSTextField *textField;
@end

@implementation PFCMainWindowProfilePreviewInfoView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup View
        // ---------------------------------------------------------------------
        _view = [[NSView alloc] init];
        [_view setTranslatesAutoresizingMaskIntoConstraints:NO];

        // ---------------------------------------------------------------------
        //  Create and add TextField
        // ---------------------------------------------------------------------
        _textField = [[NSTextField alloc] init];
        [_textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_textField setLineBreakMode:NSLineBreakByWordWrapping];
        [_textField setBordered:NO];
        [_textField setBezeled:NO];
        [_textField setDrawsBackground:NO];
        [_textField setEditable:NO];
        [_textField setStringValue:@"No Profile Selected"];
        [_textField setFont:[NSFont systemFontOfSize:19]];
        [_textField setTextColor:[NSColor tertiaryLabelColor]];
        [_textField setAlignment:NSCenterTextAlignment];
        [_view addSubview:_textField];

        // ---------------------------------------------------------------------
        //  Setup Layout Constraints for TextField
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // Center Vertically
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0]];

        // Leading
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:0]];

        // Trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_view
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:0]];

        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updateSelectionCount:(NSInteger)count {
    switch (count) {
    case 0:
        [self.textField setStringValue:NSLocalizedString(@"No Profile Selected", @"No Profile Selected")];
        break;
    case 1:
        [self.textField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%ld Profile Selected", @"Single Profile Selected"), count]];
        break;
    default:
        [self.textField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%ld Profiles Selected", @"Multiple Profiles Selected"), count]];
        break;
    }
}

@end

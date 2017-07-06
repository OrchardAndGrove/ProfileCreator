//
//  PFPViewTypeTableView.h
//  ProfilePayloads
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

#pragma once

#import "PFPPayloadCollectionKey.h"
#import "PFPViewModelTableView.h"
#import <Cocoa/Cocoa.h>
@class PFPPayloadSettings;

@protocol PFPViewTypeTableView <NSObject>

@required

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// Readwrite Properties
@property (nonatomic) NSInteger height;
@property (nonatomic, readonly) NSInteger row;

// Readonly Properties
@property (nonatomic, readonly, strong, nullable) NSTextField *textFieldTitle;
@property (nonatomic, readonly, strong, nullable) NSTextField *textFieldDescription;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithPayloadCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey
                                           viewModel:(PFPViewModelTableView *_Nonnull)viewModel
                                    payloadSettings:(PFPPayloadSettings *_Nullable)payloadSettings;

- (void)updateValue:(NSDictionary *_Nullable)settings sender:(id _Nonnull)sender;

@optional

- (void)updateTag:(NSInteger)tag;
- (nullable id)firstElement;
- (nullable id)selectedElement;

@end

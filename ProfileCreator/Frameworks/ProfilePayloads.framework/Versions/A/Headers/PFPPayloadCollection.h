//
//  PFPPayloadCollection.h
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

#import "PFPConstants.h"
#import <Foundation/Foundation.h>
@class PFPPlatform;
@class PFPPayloadCollectionKey;
@class PFPPayloadCollections;

@protocol PFPPayloadCollection <NSObject>

@required
@property (nonatomic, readonly, weak, nullable) PFPPayloadCollections *payloadCollections;
@property (nonatomic, readonly) PFPViewModel viewModel;
@property (nonatomic, readonly) PFPCollectionSet collectionSet;
@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly, strong, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, strong, nonnull) NSArray<PFPPayloadCollectionKey *> *subkeys;
@property (nonatomic, readonly, strong, nonnull) NSString *identifier;
@property (nonatomic, readonly, strong, nonnull) NSString *domain;
@property (nonatomic, readonly, strong, nonnull) NSString *title;
@property (nonatomic, readonly, strong, nonnull) NSString *descriptionString;
@property (nonatomic, readonly, strong, nonnull) NSImage *icon;
@property (nonatomic, readonly, strong, nullable) NSDictionary *payloadTypes;
@property (nonatomic, readonly, strong, nullable) NSString *payloadTypeString;
@property (nonatomic, readonly, strong, nullable) NSArray *payloadTypeConditions;

@end

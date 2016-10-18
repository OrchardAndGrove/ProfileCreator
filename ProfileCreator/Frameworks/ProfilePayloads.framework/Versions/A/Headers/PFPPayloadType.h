//
//  PFPPayloadType.h
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

#import "PFPConstants.h"
#import <Foundation/Foundation.h>
@class PFPPayloadTypeKey;
@class PFPPlatform;

@interface PFPPayloadType : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, nonnull) NSString *payloadType;
@property (nonatomic, readonly, nonnull) NSArray<PFPPayloadTypeKey *> *subkeys;
@property (nonatomic, readonly, nonnull) NSDictionary *payloadKeyDict;
@property (nonatomic, readonly, nonnull) NSString *domain;
@property (nonatomic, readonly, nonnull) NSString *title;
@property (nonatomic, readonly, nonnull) NSString *descriptionString;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithManifest:(NSDictionary *_Nonnull)manifestDict;
- (PFPPayloadTypeKey *_Nullable)payloadKeyForPayloadKeyPath:(NSString *_Nonnull)payloadKeyPath error:(NSError *_Nullable *_Nullable)error; // Only last key

@end

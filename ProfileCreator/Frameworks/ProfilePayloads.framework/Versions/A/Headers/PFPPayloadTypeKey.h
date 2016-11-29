//
//  PFPPayloadTypeKey.h
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
#import "PFPPayloadTypeKey.h"
#import <Foundation/Foundation.h>
@class PFPPayloadType;
@class PFPPlatform;
@class PFPSelection;

@interface PFPPayloadTypeKey : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly) PFPValueType valueType;
@property (nonatomic, weak, readonly, nullable) PFPPayloadType *payloadType;
@property (nonatomic, readonly, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, nonnull) NSArray<PFPPayloadTypeKey *> *subkeys;
@property (nonatomic, readonly, nonnull) NSDictionary *payloadKeyDict;
@property (nonatomic, readonly, nonnull) NSString *payloadKey;
@property (nonatomic, readonly, nonnull) NSString *payloadKeyPath;
@property (nonatomic, readonly, nonnull) NSString *payloadTypeString;
@property (nonatomic, readonly, nonnull) NSString *identifier;

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *descriptionString;
@property (nonatomic, readonly, nullable) NSString *extendedDescription;
@property (nonatomic, readonly, nullable) NSDictionary *excludeDict;
@property (nonatomic, readonly, nullable) NSArray *requiredArray;
@property (nonatomic, readonly) BOOL exclude;
@property (nonatomic, readonly, nullable) NSArray *excludeConditions;
@property (nonatomic, readonly) BOOL optional;
@property (nonatomic, readonly, nullable) NSArray *optionalConditions;
@property (nonatomic, readonly) BOOL supervised;

@property (nonatomic, readonly, nullable) id valueDefault;
@property (nonatomic, readonly, nullable) id valueMax;           // (Only used for Integer/Float and Date types)
@property (nonatomic, readonly, nullable) id valueMin;           // (Only used for Integer/Float and Date types)
@property (nonatomic, readonly, nullable) NSString *valueFormat; // Regex string the value need to conform to (Only used for String types)
@property (nonatomic, readonly, nullable) NSArray *valueList;    // List of selectable values
@property (nonatomic, readonly) BOOL valueInvert;                // (Only used for Boolean types)
@property (nonatomic, readonly) BOOL valueIsSensitive;           // Denotes the user input value as sensitive

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithKeyDict:(NSDictionary *_Nonnull)keyDict payloadType:(PFPPayloadType *_Nonnull)payloadType parentPayloadKey:(PFPPayloadTypeKey *_Nullable)parentPayloadKey;
- (BOOL)isRequired;
@end

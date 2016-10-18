//
//  PFPPlatform.h
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
@class PFPPayloadType;

@interface PFPPlatform : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) PFPOSPlatform platforms; // Platforms this class represents. (No Default)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithPlatformArray:(NSArray<NSDictionary *> *_Nonnull)platformArray parent:(id _Nullable)parent;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (PFPOSPlatform)platformForString:(NSString *_Nonnull)platformString;
+ (NSString *_Nullable)minVersionForPlatform:(PFPOSPlatform)platform;
+ (NSString *_Nullable)maxVersionForPlatform:(PFPOSPlatform)platform;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSString *_Nullable)minVersionForPlatform:(PFPOSPlatform)platform;
- (NSString *_Nullable)maxVersionForPlatform:(PFPOSPlatform)platform;
- (BOOL)supportsPlatform:(PFPOSPlatform)platform;
- (BOOL)supportsVersion:(NSString *_Nonnull)version platform:(PFPOSPlatform)platform;
- (BOOL)supportsVersionsFrom:(NSString *_Nonnull)minVersion to:(NSString *_Nonnull)maxVersion platform:(PFPOSPlatform)platform inclusive:(BOOL)inclusive;

@end

//
//  PFCProfileController.h
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

#import <Foundation/Foundation.h>
@class PFCProfile;

@interface PFCProfileController : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (nonnull id)sharedController;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Methods for getting profiles and profile information
// -----------------------------------------------------------------------------
- (NSArray *_Nullable)profileIdentifiers;
- (NSString *_Nullable)titleForProfileWithIdentifier:(NSString *_Nonnull)identifier;
- (PFCProfile *_Nullable)profileWithIdentifier:(NSString *_Nonnull)identifier;

// -----------------------------------------------------------------------------
//  Methods for interacting with profiles
// -----------------------------------------------------------------------------
- (BOOL)saveProfile:(PFCProfile *_Nonnull)profile error:(NSError *_Nullable *_Nullable)error;
- (void)editProfileWithIdentifier:(NSString *_Nonnull)identifier;
- (void)exportProfileWithIdentifier:(NSString *_Nonnull)identifier sender:(id _Nonnull)sender;
- (BOOL)removeProfileWithIdentifier:(NSString *_Nonnull)identifier error:(NSError *_Nullable *_Nullable)error;

@end

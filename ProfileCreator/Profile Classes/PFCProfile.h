//
//  PFCProfile.h
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
#import <ProfilePayloads/ProfilePayloads.h>

@class PFCProfileEditor;
@class PFCProfileSettings;

@interface PFCProfile : NSObject <PFPPayloadSettingsDelegate>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  General Settings
// -----------------------------------------------------------------------------
@property (nonatomic, copy, nonnull) NSString *title;
@property (nonatomic, strong, nullable) NSURL *url;
@property (nonatomic, strong, nullable) PFCProfileEditor *editor;
@property (nonatomic, strong, nullable) PFPProfilePayloads *profilePayloads;

// -----------------------------------------------------------------------------
//  Payload Settings
// -----------------------------------------------------------------------------
@property (nonatomic, readonly, strong, nonnull) NSString *identifier;
@property (nonatomic, readonly, strong, nonnull) NSDictionary *savedPayloadSettings;
@property (nonatomic, readonly, strong, nonnull) NSMutableArray *modifiedIdentifiers;
@property (nonatomic, strong, nonnull) NSMutableArray *enabledPayloadIdentifiers;

// -----------------------------------------------------------------------------
//  View Settings
// -----------------------------------------------------------------------------
@property (nonatomic) PFPScope scope;
@property (nonatomic) PFPDistribution distribution;
@property (nonatomic) BOOL showHidden;
@property (nonatomic) BOOL showSupervised;
@property (nonatomic) BOOL showDisabled;
@property (nonatomic, readonly, strong, nonnull) NSDictionary *viewSettings;
@property (nonatomic, readonly, strong, nonnull) NSDictionary *savedViewSettings;

// -----------------------------------------------------------------------------
//  View Delegate
// -----------------------------------------------------------------------------
@property (nonatomic, weak, nullable) id viewDelegate;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithTitle:(NSString *_Nullable)title
                            identifier:(NSString *_Nullable)identifier
                       payloadSettings:(NSDictionary *_Nullable)payloadSettings
                          viewSettings:(NSDictionary *_Nullable)viewSettings
                                   url:(NSURL *_Nullable)url;

- (BOOL)save;
- (BOOL)isSaved;

- (NSDictionary *_Nullable)payloadSettingsForExport:(NSError *_Nullable *_Nullable)error;
- (void)removeEditor;
- (void)updateTitle:(NSString *_Nullable)title;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (NSDictionary *_Nullable)defaultPayloadSettings;

@end

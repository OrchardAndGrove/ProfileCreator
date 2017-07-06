//
//  PFPPayloadCollectionKey.h
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
#import "PFPPayloadCollection.h"
#import "PFPPayloadTypeKey.h"
#import <Cocoa/Cocoa.h>
@class PFPPayloadSettings;

@interface PFPPayloadCollectionKey : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  CollectionProperties (Not specific to any key)
// -----------------------------------------------------------------------------

//--- REFERENCES ---//
@property (nonatomic, readonly, weak, nullable) id<PFPPayloadCollection> payloadCollection; // The payload collection this key belongs to
@property (nonatomic, readonly, strong, nonnull) NSDictionary *subkeyDict;                  // The manifest subkey dict this key is based on
@property (nonatomic, readonly, strong, nonnull) NSDictionary *payloadKeys;                 // The Payload Keys dict from the subkeyDict
@property (nonatomic, readonly, strong, nonnull) NSDictionary *payloadTypes;                // The Payload Types referenced in the payload keys, accessed by the payloadKeys keys.
@property (nonatomic, readonly, strong, nonnull) NSDictionary *valueSubkeys;                // The Subkeys used when a specific value is selected or entered.

//--- REQUIRED ---//
@property (nonatomic, readonly) PFPViewType viewType;                  // Determines the format of the viewRepresentation
@property (nonatomic, readonly, strong, nonnull) NSString *identifier; // Unique identifier

//--- OPTIONAL ---//
@property (nonatomic, readonly, nullable) NSString *title;               // Title for the representation
@property (nonatomic, readonly, nullable) NSString *descriptionString;   // Description for the representation
@property (nonatomic, readonly, nullable) NSString *extendedDescription; // Extended description for the representation
@property (nonatomic, readonly, strong, nullable) id viewRepresentation; // The representation of this key, matching the viewType
@property (nonatomic, readonly) PFPFontWeight titleFontWeight;           // Default Value: kPFPFontWeightBold, The font wight used to the title in the representation

// UNSURE
@property (nonatomic, readonly) PFPViewStyle viewStyle;

// TO BE REPLACED BY DIRECT LOOKUP
@property (nonatomic, readonly, strong, nullable) NSString *valueDefaultKeyPath;  // If set, contains path to settings key to use as default value
@property (nonatomic, readonly, weak, nullable) id selectionDefault;
@property (nonatomic, readonly, nullable) id valuePlaceholder;
@property (nonatomic, readonly) BOOL valueIsSensitive;

// PAYLOAD KEYS

@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, nonnull) NSArray<PFPPayloadCollectionKey *> *subkeys;
@property (nonatomic, readonly, strong, nullable) id payloadValue;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithSubkeyDict:(NSDictionary *_Nonnull)subkeyDict
                         payloadCollection:(id<PFPPayloadCollection> _Nonnull)payloadCollection
                                 viewModel:(PFPViewModel)viewModel
                          payloadSettings:(PFPPayloadSettings *_Nonnull)payloadSettings;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable id)viewWithSettings:(NSDictionary *_Nullable)settingsDict;
- (PFPPayloadTypeKey *_Nullable)payloadTypeKeyForPayloadKeyPath:(NSString *_Nonnull)payloadKeyPath;
- (BOOL)isRequired;

// Should add these to make the conditions check internal
// - (BOOL)isOptional;
- (BOOL)isHiddenWithSettings:(NSDictionary *_Nullable)settings;
- (BOOL)isOptionalWithSettings:(NSDictionary *_Nullable)settings;
- (BOOL)isExcludedWithSettings:(NSDictionary *_Nullable)settings;

// Use this to get values for view specific items
- (id _Nullable)viewItem:(NSString *_Nullable)viewItem payloadTypeKey:(PFPPayloadTypeKey *_Nullable)payloadTypeKey valueForManifestKey:(NSString *_Nonnull)manifestKey;
- (id _Nullable)viewItem:(NSString *_Nonnull)viewItem valueForManifestKey:(NSString *_Nonnull)manifestKey;
- (id _Nullable)viewItem:(NSString *_Nullable)viewItem valueSubkeysForPayloadTypeKey:(PFPPayloadTypeKey *_Nonnull)payloadTypeKey;
- (BOOL)viewItem:(NSString *_Nonnull)viewItem isRequired:(NSDictionary *_Nonnull)settings;

@end

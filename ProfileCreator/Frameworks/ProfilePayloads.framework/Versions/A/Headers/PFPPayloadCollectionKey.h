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
#import "PFPViewTypeDelegate.h"
#import <Cocoa/Cocoa.h>

@interface PFPPayloadCollectionKey : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// Collection Properties
@property (nonatomic, readonly) PFPViewType viewType;
@property (nonatomic, readonly, strong, nullable) id viewRepresentation;
@property (nonatomic, readonly) PFPFontWeight fontWeightTitle; // Default Value: kPFPFontWeightBold
@property (nonatomic, readonly, weak, nullable) id<PFPPayloadCollection> payloadCollection;
@property (nonatomic, readonly, strong, nonnull) NSDictionary *payloadKeyDictCollection;
@property (nonatomic, readonly) BOOL enabled; // Default Value: YES

@property (nonatomic, readonly) BOOL hidden; // Default Value: NO
@property (nonatomic, readonly, nullable) NSArray *hiddenConditionals;

@property (nonatomic, readonly) BOOL exclude; // Default Value: NO
@property (nonatomic, readonly, nullable) NSArray *excludeConditionals;

@property (nonatomic, readonly) BOOL optional;
@property (nonatomic, readonly, nullable) NSArray *optionalConditionals;

@property (nonatomic, readonly) BOOL supervised;
@property (nonatomic, readonly, nullable) NSArray *supervisedConditionals;

@property (nonatomic, readonly, strong, nullable) NSString *payloadTypeString;
@property (nonatomic, readonly, strong, nullable) NSArray *payloadTypeConditions;

@property (nonatomic, readonly) BOOL isListItem;                                  // Default Value: NO, Used by: PopUpButton
@property (nonatomic, readonly) BOOL hasPayload;                                  // If itself (not any subkeys) contains atleast one payloadKeyPath
@property (nonatomic, readonly) NSInteger visibleRows;                            // Default Value: 3, Used by: TextView
@property (nonatomic, readonly) NSInteger popUpButtonWidth;                       // Default Value: -1 (Automatic), Used by: PopUpButton
@property (nonatomic, readonly, strong, nullable) NSArray *allowedFileTypes;      // Default Value: -, Used by: File
@property (nonatomic, readonly, strong, nullable) NSArray *allowedFileExtensions; // Default Value: -, Used by: File
@property (nonatomic, readonly, strong, nullable) NSString *filePrompt;           // Default Value: Add File…, Used by: File
@property (nonatomic, readonly, strong, nullable) NSString *fileProcessor;        // Default Value: -, Used by: File
@property (nonatomic, readonly, strong, nullable) NSString *fileButtonTitle;      // Default Value: Add File…, Used by: File
@property (nonatomic, readonly, strong, nullable) NSString *valueDefaultKeyPath;  // If set, contains path to settings key to use as default value
@property (nonatomic, readonly, weak, nullable) id selectionDefault;

// PayloadKey Properties
// Required properties
@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, nonnull) NSArray<PFPPayloadCollectionKey *> *subkeys;
@property (nonatomic, readonly, nonnull) NSString *identifier;

// Basic information
@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *descriptionString;
@property (nonatomic, readonly, nullable) NSString *extendedDescription;
@property (nonatomic, readonly, nullable) NSDictionary *excludeDict;
@property (nonatomic, readonly, nullable) NSArray *requiredArray;

// Value Properties
@property (nonatomic, readonly, nullable) id valueDefault;
@property (nonatomic, readonly, nullable) id valueMax;                // (Only used for Integer/Float and Date types)
@property (nonatomic, readonly, nullable) id valueMin;                // (Only used for Integer/Float and Date types)
@property (nonatomic, readonly, nullable) NSString *valueFormat;      // Regex string the value need to conform to (Only used for String types)
@property (nonatomic, readonly, nullable) NSArray *valueList;         // List of selectable values
@property (nonatomic, readonly, nullable) NSDictionary *valueSubkeys; // Dict containing subkeys for values in valueList
@property (nonatomic, readonly, nullable) id valuePlaceholder;
@property (nonatomic, readonly) BOOL valueIsSensitive;

@property (nonatomic, readonly) NSInteger valueMinOffsetDays;    // Default Value: 0, Used by: DatePicker
@property (nonatomic, readonly) NSInteger valueMinOffsetHours;   // Default Value: 0, Used by: DatePicker
@property (nonatomic, readonly) NSInteger valueMinOffsetMinutes; // Default Value: 0, Used by: DatePicker
@property (nonatomic, readonly) BOOL showDate;                   // Default Value: YES, Used by: DatePicker
@property (nonatomic, readonly) BOOL showDateTime;               // Default Value: NO, Used by: DatePicker
@property (nonatomic, readonly) BOOL showDateInterval;           // Default Value: YES, Used by: DatePicker
@property (nonatomic, readonly, strong, nullable) NSDate *date;  // Default Value: now, Used by: DatePicker
@property (nonatomic, readonly, strong, nullable) id payloadValue;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithKeyDict:(NSDictionary *_Nonnull)keyDict
                      payloadCollection:(id<PFPPayloadCollection> _Nonnull)payloadCollection
                              viewModel:(PFPViewModel)viewModel
                       viewTypeDelegate:(id<PFPViewTypeDelegate> _Nonnull)viewTypeDelegate;

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
// - (BOOL)isExcluded;

@end

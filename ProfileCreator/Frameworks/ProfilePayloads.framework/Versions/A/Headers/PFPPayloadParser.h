//
//  PFPPayloadParser.h
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

#import <Cocoa/Cocoa.h>

@interface PFPPayloadParser : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (nonnull instancetype)sharedParser;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *_Nonnull)viewArrayFromPayloadCollectionSubkeys:(NSArray *_Nonnull)subkeys settings:(NSDictionary *_Nonnull)settings modifiedIdentifiers:(NSArray *_Nullable)modifiedIdentifiers;
- (id _Nullable)selectionForPayloadCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey viewType:(PFPViewType)viewType settings:(NSDictionary *_Nullable)settings;
- (BOOL)shouldExportPayloadCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey payloadSettings:(NSDictionary *_Nullable)payloadSettings;

@end

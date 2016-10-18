//
//  PFPPayloadCollections.h
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

#import "PFPPayloadCollection.h"
#import "PFPPayloadCollectionSet.h"
#import "PFPViewTypeDelegate.h"
#import <Foundation/Foundation.h>
@class PFPPayloadCollectionKey;

@interface PFPPayloadCollections : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithViewModel:(PFPViewModel)viewModel delegate:(id<PFPViewTypeDelegate> _Nullable)delegate;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id<PFPPayloadCollectionSet> _Nullable)setForCollection:(PFPCollectionSet)collectionSet;
- (id<PFPPayloadCollection> _Nullable)collectionWithIdentifier:(NSString *_Nonnull)collectionIdentifier;
- (void)updatePayloadSettings:(NSMutableDictionary *_Nullable)payloadSettings
           withUserChangeDict:(NSDictionary *_Nonnull)userChangeDict
         payloadCollectionKey:(PFPPayloadCollectionKey *_Nullable)payloadCollectionKey;
@end

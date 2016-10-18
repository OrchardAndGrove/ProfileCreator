//
//  PFPProfilePayloads.h
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
#import "PFPViewTypeDelegate.h"
#import <Foundation/Foundation.h>
@class PFPPayloadTypes;
@class PFPPayloadCollections;

@interface PFPProfilePayloads : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic) NSInteger viewWidth;
@property (nonatomic, strong, readonly, nullable) PFPPayloadTypes *payloadTypes;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (nonnull instancetype)sharedInstance;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

/*!
 @brief Returns a generated profile using passed parameters.
 @discussion FIXME
 @param  payloadSettings
 @param  baseIdentifier
 @param  scope
 @param  distribution
 @param  supervised
 @param  viewModel
 @param  error
 @return NSDictionary
 */
- (NSDictionary *_Nullable)profileWithSettings:(NSDictionary *_Nonnull)payloadSettings
                                baseIdentifier:(NSString *_Nonnull)baseIdentifier
                                         scope:(PFPScope)scope
                                  distribution:(PFPDistribution)distribution
                                    supervised:(BOOL)supervised
                                     viewModel:(PFPViewModel)viewModel
                                         error:(NSError *_Nullable *_Nullable)error;

@end

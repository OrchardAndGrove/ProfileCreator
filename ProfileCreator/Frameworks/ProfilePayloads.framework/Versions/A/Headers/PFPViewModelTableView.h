//
//  PFPViewModelTableView.h
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
#import <Cocoa/Cocoa.h>
@class PFPPayloadCollectionKey;
@class PFPPayloadSettings;

@interface PFPViewModelTableView : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@property (nonatomic) NSInteger tableViewWidth;
@property (nonatomic, readonly) NSInteger tableViewListCenteredIndent;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSTableCellView *_Nullable)viewForViewType:(PFPViewType)viewType
                         payloadCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey
                             payloadSettings:(PFPPayloadSettings *_Nonnull)payloadSettings;

@end

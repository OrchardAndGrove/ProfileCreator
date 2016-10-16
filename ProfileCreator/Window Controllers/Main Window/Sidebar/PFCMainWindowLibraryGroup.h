//
//  PFCMainWindowLibraryGroup.h
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

#import "PFCMainWindowOutlineViewChildProtocol.h"
#import "PFCMainWindowOutlineViewParentProtocol.h"
#import <Cocoa/Cocoa.h>

@interface PFCMainWindowLibraryGroup : NSObject <PFCMainWindowOutlineViewChild>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewChild Required
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) BOOL isEditable;
@property (nonatomic, readonly) BOOL isEditing;
@property (nonatomic, readonly, nonnull) NSString *title;
@property (nonatomic, readonly, nonnull) NSString *identifier;
@property (nonatomic, readonly, nonnull) NSArray *profileIdentifiers;
@property (nonatomic, readonly, nonnull) NSImage *icon;
@property (nonatomic, readonly, nonnull) NSMutableArray *children;
@property (nonatomic, nonnull) PFCMainWindowOutlineViewChildCellView *cellView;
- (nullable instancetype)initWithTitle:(NSString *_Nonnull)title identifier:(NSString *_Nullable)identifier parent:(id<PFCMainWindowOutlineViewParent> _Nonnull)parent;
- (void)addProfileIdentifiers:(NSArray *_Nonnull)identifiers;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewChild Optional
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)removeProfileIdentifiers:(NSArray *_Nonnull)identifiers;
- (void)removeProfileIdentifiersAtIndexes:(NSIndexSet *_Nonnull)indexSet;
- (BOOL)writeToDisk:(NSError *_Nullable *_Nullable)error;
- (BOOL)removeFromDisk:(NSError *_Nullable *_Nullable)error;
@end

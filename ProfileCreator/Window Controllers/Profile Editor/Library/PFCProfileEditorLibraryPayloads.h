//
//  PFCProfileEditorLibraryPayloads.h
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

#import "PFCConstants.h"
#import <Cocoa/Cocoa.h>
@class PFCProfileEditor;
@class PFCProfileEditorLibrarySplitView;

typedef NS_ENUM(NSUInteger, PFCLibraryTableView) { kPFCLibraryTableViewProfile, kPFCLibraryTableViewLibrary };

@interface PFCProfileEditorLibraryPayloads : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSDraggingSource, NSDraggingDestination>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) PFCPayloadLibrary selectedLibrary;
@property (nonatomic, strong, readonly, nonnull) NSDictionary *selectedPlaceholder;
@property (nonatomic, strong, readonly, nonnull) NSScrollView *scrollViewLibraryPayloads;
@property (nonatomic, strong, readonly, nonnull) NSScrollView *scrollViewProfilePayloads;
@property (nonatomic, strong, readonly, nonnull) NSTableView *tableViewProfilePayloads;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfileEditor:(PFCProfileEditor *_Nonnull)profileEditor
                profileEditorLibrarySplitView:(PFCProfileEditorLibrarySplitView *_Nonnull)profileEditorLibrarySplitView
                            selectionDelegate:(id _Nonnull)selectionDelegate;
- (void)selectLibrary:(PFCPayloadLibrary)library;
- (void)togglePayload:(NSButton *_Nonnull)sender;

@end

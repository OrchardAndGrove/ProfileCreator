//
//  PFCProfileEditorLibrarySplitView.h
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

#import <Cocoa/Cocoa.h>
@class PFCProfileEditorLibraryPayloads;
@class PFCProfileEditorLibraryNoPayloads;

@interface PFCProfileEditorLibrarySplitView : NSSplitView <NSSplitViewDelegate>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic) BOOL splitViewLibraryCollapsed;
@property (nonatomic) BOOL splitViewLibraryNoPayloads;
@property (nonatomic, strong, readonly, nonnull) PFCProfileEditorLibraryPayloads *libraryPayloads;
@property (nonatomic, strong, readonly, nonnull) PFCProfileEditorLibraryNoPayloads *libraryNoPayloads;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
- (nonnull instancetype)initWithProfileEditor:(PFCProfileEditor *_Nonnull)profileEditor
                       profileEditorSplitView:(PFCProfileEditorSplitView *_Nonnull)profileEditorSplitView
                            selectionDelegate:(id _Nonnull)selectionDelegate;
- (void)uncollapseLibraryView;
- (void)showLibraryNoProfiles:(BOOL)show;

@end

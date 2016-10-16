//
//  PFCMainWindowAllProfiles.m
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
#import "PFCMainWindowAllProfiles.h"
#import "PFCMainWindowAllProfilesGroup.h"
#import "PFCMainWindowOutlineViewParentCellView.h"
#import "PFCProfileController.h"

@interface PFCMainWindowAllProfiles ()
@property (nonatomic, readwrite) NSString *title;
@end

@implementation PFCMainWindowAllProfiles

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup properties
        // ---------------------------------------------------------------------
        _isEditable = NO;
        _title = PFCMainWindowOutlineViewParentTitleAllProfiles;
        _children = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        _cellView = [[PFCMainWindowOutlineViewParentCellView alloc] initWithParent:self];

        // ---------------------------------------------------------------------
        //  Setup the single outline view child group for this parent
        // ---------------------------------------------------------------------
        PFCMainWindowAllProfilesGroup *group = [[PFCMainWindowAllProfilesGroup alloc] initWithTitle:_title identifier:nil parent:self];
        [group addProfileIdentifiers:[[PFCProfileController sharedController] profileIdentifiers]];

        // ---------------------------------------------------------------------
        //  Add the group to this parent's childen
        // ---------------------------------------------------------------------
        [_children addObject:group];
    }
    return self;
}

@end

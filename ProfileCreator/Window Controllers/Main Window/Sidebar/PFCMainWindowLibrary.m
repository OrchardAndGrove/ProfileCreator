//
//  PFCMainWindowLibrary.m
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

#import "PFCAlert.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCMainWindowLibrary.h"
#import "PFCMainWindowLibraryGroup.h"
#import "PFCMainWindowOutlineViewParentCellView.h"
#import "PFCResources.h"

@interface PFCMainWindowLibrary ()
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, strong, nullable) PFCAlert *alert;
@end

@implementation PFCMainWindowLibrary

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
        _isEditable = YES;
        _title = PFCMainWindowOutlineViewParentTitleLibrary;
        _children = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        _cellView = [[PFCMainWindowOutlineViewParentCellView alloc] initWithParent:self];

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(addGroup:) name:PFCAddGroupNotification object:nil];
        [nc addObserver:self selector:@selector(removeProfiles:) name:PFCDidRemoveProfileNotification object:nil];

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        [self loadSavedGroups];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notifications
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCAddGroupNotification object:nil];
    [nc removeObserver:self name:PFCDidRemoveProfileNotification object:nil];
}

- (void)loadSavedGroups {

    NSError *error;

    // -------------------------------------------------------------------------
    //  Get path to save folder
    // -------------------------------------------------------------------------
    NSURL *groupFolder = [PFCResources folder:kPFCFolderGroupsLibrary];
    if (![groupFolder checkResourceIsReachableAndReturnError:&error]) {
        DDLogError(@"%@", error.localizedDescription);
        return;
    }

    // -------------------------------------------------------------------------
    //  Put all profile group plist URLs in an array
    // -------------------------------------------------------------------------
    NSArray *allGroupURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:groupFolder includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];

    // -------------------------------------------------------------------------
    //  Add all groups matching predicate with group template extension to group array
    // -------------------------------------------------------------------------
    NSPredicate *predicateManifestGroups = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.pathExtension == '%@'", PFCFileExtensionGroup]];
    NSArray *groupURLs = [allGroupURLs filteredArrayUsingPredicate:predicateManifestGroups];
    [groupURLs enumerateObjectsUsingBlock:^(NSURL *_Nonnull groupURL, NSUInteger idx, BOOL *_Nonnull stop) {

      // -----------------------------------------------------------------------
      //  Read the group template from disk
      // -----------------------------------------------------------------------
      NSDictionary *groupDict = [NSDictionary dictionaryWithContentsOfURL:groupURL];
      if (groupDict.count != 0) {

          // -------------------------------------------------------------------
          //  If title is set in the template and isn't empty, add the group
          // -------------------------------------------------------------------
          NSString *title = groupDict[PFCMainWindowGroupKeyTitle] ?: @"";
          if (title.length != 0) {
              [self addGroupWithTitle:title identifier:groupDict[PFCMainWindowGroupKeyIdentifier] ?: @"" profileIdentifiers:groupDict[PFCMainWindowGroupKeyProfileIdentifiers] ?: @[]];
          }
      }
    }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Add Group was initiated by user
// -----------------------------------------------------------------------------
- (void)addGroup:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Verify that addGroup was called for this group
    // -------------------------------------------------------------------------
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo[PFCNotificationUserInfoParentTitle] isEqualToString:self.title]) {

        // ---------------------------------------------------------------------
        //  Setup return block
        // ---------------------------------------------------------------------
        void (^returnValue)(NSString *_Nullable, NSInteger) = ^void(NSString *inputText, NSInteger returnCode) {

          // -----------------------------------------------------------------
          //  If user selected a valid name and clicked create, add group
          // -----------------------------------------------------------------
          if (returnCode == NSAlertFirstButtonReturn) {
              [self addGroupWithTitle:inputText identifier:nil profileIdentifiers:@[]];
          }
        };

        // ---------------------------------------------------------------------
        //  Show add group alert with text field to user
        // ---------------------------------------------------------------------
        [self setAlert:[[PFCAlert alloc] init]];
        [self.alert showAlertTextInputWithMessage:NSLocalizedString(@"New Library Group", @"Alert title when adding a new group to the main window library")
                                  informativeText:NSLocalizedString(@"Enter a name for new library group to be created.", @"Alert message when adding a new group to the main window library")
                                           window:[[NSApplication sharedApplication] mainWindow]
                                    defaultString:nil
                                placeholderString:nil
                                 firstButtonTitle:PFCButtonTitleOK
                                secondButtonTitle:PFCButtonTitleCancel
                                 thirdButtonTitle:nil
                          firstButtonInitialState:YES
                                           sender:self
                                      returnValue:returnValue];
    }
}

// -----------------------------------------------------------------------------
//  Remove profiles was initiated by user, after accepting warning
// -----------------------------------------------------------------------------
- (void)removeProfiles:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Get array of profile identifiers to remove
    // -------------------------------------------------------------------------
    NSDictionary *userInfo = notification.userInfo;
    NSArray *profileIdentifiersToRemove = userInfo[PFCNotificationUserInfoProfileIdentifiers];

    // -------------------------------------------------------------------------
    //  Loop through all child groups and remove profiles from those
    // -------------------------------------------------------------------------
    for (id<PFCMainWindowOutlineViewChild> child in self.children) {
        if ([child respondsToSelector:@selector(removeProfileIdentifiers:)]) {
            [child removeProfileIdentifiers:profileIdentifiersToRemove];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)addGroupWithTitle:(NSString *_Nonnull)title identifier:(NSString *_Nullable)identifier profileIdentifiers:(NSArray *_Nullable)profileIdentifiers {

    // -------------------------------------------------------------------------
    //  Instantiate a new group instance with passed parameters
    // -------------------------------------------------------------------------
    PFCMainWindowLibraryGroup *group = [[PFCMainWindowLibraryGroup alloc] initWithTitle:title identifier:identifier parent:self];
    [group addProfileIdentifiers:profileIdentifiers];

    // -------------------------------------------------------------------------
    //  Only if writing group template to disk, add it to children and post a notification that a new group was added
    // -------------------------------------------------------------------------
    if ([group writeToDisk:nil]) {
        [self.children addObject:group];
        [[NSNotificationCenter defaultCenter] postNotificationName:PFCDidAddGroupNotification object:self];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTextFieldDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Used when selecting a new group name to not allow duplicates
// -----------------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Get current text in the text field
    // -------------------------------------------------------------------------
    NSString *inputText = [[notification.userInfo valueForKey:@"NSFieldEditor"] string];

    // -------------------------------------------------------------------------
    //  Get names of all current groups
    // -------------------------------------------------------------------------
    NSArray *currentGroupTitles = [self.children valueForKey:@"title"];

    // -------------------------------------------------------------------------
    //  If current text in the text field is empty or matches an existing group, disable the OK button.
    // -------------------------------------------------------------------------
    if (self.alert.firstButton.enabled && (inputText.length == 0 || [currentGroupTitles containsObject:inputText])) {
        [self.alert.firstButton setEnabled:NO];
    } else {
        [self.alert.firstButton setEnabled:YES];
    }
}

@end

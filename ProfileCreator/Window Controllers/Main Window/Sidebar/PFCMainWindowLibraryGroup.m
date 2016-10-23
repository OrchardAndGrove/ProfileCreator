//
//  PFCMainWindowLibraryGroup.m
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
#import "PFCError.h"
#import "PFCLog.h"
#import "PFCMainWindowLibraryGroup.h"
#import "PFCMainWindowOutlineViewChildCellView.h"
#import "PFCProfile.h"
#import "PFCProfileController.h"
#import "PFCResources.h"

@interface PFCMainWindowLibraryGroup ()
@property (nonatomic, readwrite, nonnull) NSString *title;
@property (nonatomic, readwrite, nonnull) NSString *identifier;
@property (nonatomic, readwrite, nonnull) NSArray *profileIdentifiers;
@property (nonatomic, readwrite, nonnull) NSImage *icon;
@property (nonatomic, readwrite) BOOL isEditable;
@property (nonatomic, readwrite) BOOL isEditing;
@property (nonatomic, strong, nullable) PFCAlert *alert;
@end

@implementation PFCMainWindowLibraryGroup

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithTitle:(NSString *_Nonnull)title identifier:(NSString *_Nullable)identifier parent:(id<PFCMainWindowOutlineViewParent> _Nonnull)parent {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _children = [[NSMutableArray alloc] init];
        _profileIdentifiers = [[NSMutableArray alloc] init];

        _title = title;
        _isEditable = YES;
        _icon = [NSImage imageNamed:@"SidebarFolder"];
        if (identifier.length == 0) {
            _identifier = [[NSUUID UUID] UUIDString];
        } else {
            _identifier = identifier;
        }

        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        _cellView = [[PFCMainWindowOutlineViewChildCellView alloc] initWithChild:self];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewChild Required
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)addProfileIdentifiers:(NSArray *_Nonnull)identifiers {

    // -------------------------------------------------------------------------
    //  Add the passed identifiers
    // -------------------------------------------------------------------------
    NSMutableArray *profileIdentifiers = [self.profileIdentifiers mutableCopy];
    [identifiers enumerateObjectsUsingBlock:^(NSString *_Nonnull identifier, NSUInteger idx, BOOL *_Nonnull stop) {
      if (![profileIdentifiers containsObject:identifier]) {
          [profileIdentifiers addObject:identifier];
      }
    }];
    [self setProfileIdentifiers:[profileIdentifiers copy]];

    // -------------------------------------------------------------------------
    //  Save the new group contents to disk
    // -------------------------------------------------------------------------
    [self writeToDisk:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewChild Optional
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)removeProfileIdentifiers:(NSArray *_Nonnull)identifiers {

    // -------------------------------------------------------------------------
    //  Remove the passed identifiers
    // -------------------------------------------------------------------------
    NSMutableArray *profileIdentifiers = [self.profileIdentifiers mutableCopy];
    [identifiers enumerateObjectsUsingBlock:^(NSString *_Nonnull identifier, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([profileIdentifiers containsObject:identifier]) {
          [profileIdentifiers removeObject:identifier];
      }
    }];
    [self setProfileIdentifiers:[profileIdentifiers copy]];

    // -------------------------------------------------------------------------
    //  Save the new group contents to disk
    // -------------------------------------------------------------------------
    [self writeToDisk:nil];

    // -------------------------------------------------------------------------
    //  Post notificatio that grop has removed profiles
    // -------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCGroupDidRemoveProfileNotification object:self];
}

- (void)removeProfileIdentifiersAtIndexes:(NSIndexSet *_Nonnull)indexSet {

    // -------------------------------------------------------------------------
    //  Remove the identifiers at the passed indexes
    // -------------------------------------------------------------------------
    NSMutableArray *profileIdentifiers = [self.profileIdentifiers mutableCopy];
    [profileIdentifiers removeObjectsAtIndexes:indexSet];
    [self setProfileIdentifiers:[profileIdentifiers copy]];

    // -------------------------------------------------------------------------
    //  Save the new group contents to disk
    // -------------------------------------------------------------------------
    [self writeToDisk:nil];

    // -------------------------------------------------------------------------
    //  Post notificatio that grop has removed profiles
    // -------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCGroupDidRemoveProfileNotification object:self];
}

- (BOOL)writeToDisk:(NSError *_Nullable *_Nullable)error {
    return [self writeToDiskWithTitle:self.title error:error];
}

- (BOOL)removeFromDisk:(NSError *_Nullable *_Nullable)error {

    // -------------------------------------------------------------------------
    //  Get path to remove
    // -------------------------------------------------------------------------
    NSURL *groupURL = [self url:error];
    if (groupURL == nil) {
        return NO;
    }

    // -------------------------------------------------------------------------
    //  Try to remove path
    // -------------------------------------------------------------------------
    if ([groupURL checkResourceIsReachableAndReturnError:error]) {
        if (![[NSFileManager defaultManager] removeItemAtURL:groupURL error:error]) {

            DDLogError(@"%@", [*error localizedDescription]);

            // FIXME - Is this a good way, or use my own alertWithError?
            [[NSAlert alertWithError:*error] runModal];
            return NO;
        }
    }
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTextFieldDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)controlTextDidBeginEditing:(NSNotification *)notification {
    [self setIsEditing:YES];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSString *inputText = [[[notification userInfo] valueForKey:@"NSFieldEditor"] string];
    if (inputText.length != 0 && [self writeToDiskWithTitle:inputText error:nil]) {
        [self setTitle:[inputText copy]];
    }
    [self setIsEditing:NO];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSURL *)url:(NSError *_Nullable *_Nullable)error {

    // -------------------------------------------------------------------------
    //  Get path to save folder
    // -------------------------------------------------------------------------
    NSURL *groupFolder = [PFCResources folder:kPFCFolderGroupsLibrary];
    if (![groupFolder checkResourceIsReachableAndReturnError:error]) {

        // ---------------------------------------------------------------------
        //  Create save folder if it doesn't exist
        // ---------------------------------------------------------------------
        if (![[NSFileManager defaultManager] createDirectoryAtURL:groupFolder withIntermediateDirectories:YES attributes:nil error:error]) {

            DDLogError(@"%@", [*error localizedDescription]);

            // FIXME - Is this a good way, or use my own alertWithError?
            [[NSAlert alertWithError:*error] runModal];
            return nil;
        }
    }

    return [groupFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.identifier, PFCFileExtensionGroup]];
}

- (BOOL)writeToDiskWithTitle:(NSString *_Nonnull)title error:(NSError *_Nullable *_Nullable)error {

    NSMutableArray *identifiers = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Loop through all profile identifiers in group
    // -------------------------------------------------------------------------
    [self.profileIdentifiers enumerateObjectsUsingBlock:^(NSString *_Nonnull identifier, NSUInteger idx, BOOL *_Nonnull stop) {

      // -----------------------------------------------------------------------
      //  Get profile instance for current identifier
      // -----------------------------------------------------------------------
      PFCProfile *profile = [[PFCProfileController sharedController] profileWithIdentifier:identifier];

      // -----------------------------------------------------------------------
      //  Check if profile has been saved to disk at least once, else don't include in group template on disk
      // -----------------------------------------------------------------------
      if (profile && profile.url) {
          [identifiers addObject:profile.identifier];
      } else {
          DDLogDebug(@"Profile: %@ was not included when writing group: %@ to disk", profile.title, self.title);
          DDLogDebug(@"Profile URL: %@", profile.url);
      }
    }];

    // -------------------------------------------------------------------------
    //  Create dict to save
    // -------------------------------------------------------------------------
    NSDictionary *groupDict = @{PFCGroupTemplateKeyTitle : title ?: self.title, PFCGroupTemplateKeyIdentifier : self.identifier, PFCGroupTemplateKeyProfileIdentifiers : [identifiers copy]};

    // -------------------------------------------------------------------------
    //  Get path to save at
    // -------------------------------------------------------------------------
    NSURL *groupURL = [self url:error];
    if (groupURL == nil) {
        return NO;
    }

    // -------------------------------------------------------------------------
    //  Try to save group to disk
    // -------------------------------------------------------------------------
    if (![groupDict writeToURL:groupURL atomically:NO]) {

        // -------------------------------------------------------------------------
        //  If could not write to disk, show error to user
        // -------------------------------------------------------------------------

        // FIXME - This is just a placeholder error, should probably do a real check if the path has wrong permissions etc.
        *error = [PFCError errorWithDescription:NSLocalizedString(([NSString stringWithFormat:@"You don’t have permission to save the file \"%@\" in the folder \"%@\"", groupURL.lastPathComponent,
                                                                                              [[groupURL URLByDeletingLastPathComponent] lastPathComponent]]),
                                                                  @"")
                                  failureReason:NSLocalizedString(@"Permission denied", nil)
                                           code:-57];

        DDLogError(@"%@", [*error localizedDescription]);

        // FIXME - Is this a good way, or use my own alertWithError?
        [[NSAlert alertWithError:*error] runModal];
        return NO;
    }

    return YES;
}

@end

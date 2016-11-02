//
//  PFCProfileController.m
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
#import "PFCProfile.h"
#import "PFCProfileController.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExportAccessoryView.h"
#import "PFCResources.h"
#import <ProfilePayloads/ProfilePayloads.h>

@interface PFCProfileController ()
@property (nonatomic, strong, nonnull) NSMutableDictionary *profiles;
@property (nonatomic, strong, nullable) PFCAlert *alert;
@end

@implementation PFCProfileController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (nonnull id)sharedController {
    static PFCProfileController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedController = [[self alloc] init];
    });
    return sharedController;
} // sharedInstance

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init {
    self = [super init];
    if (self != nil) {

        _profiles = [[NSMutableDictionary alloc] init];

        // ---------------------------------------------------------------------
        //  Load all saved profiles from disk
        // ---------------------------------------------------------------------
        [self loadSavedProfiles];

        // ---------------------------------------------------------------------
        //  Register for notifications
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(windowWillCloseNotification:) name:NSWindowWillCloseNotification object:nil];
        [nc addObserver:self selector:@selector(addProfile:) name:PFCAddProfileNotification object:nil];
        [nc addObserver:self selector:@selector(removeProfiles:) name:PFCRemoveProfileNotification object:nil];
    }
    return self;
} // init

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notifications
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:NSWindowWillCloseNotification object:nil];
    [nc removeObserver:self name:PFCAddProfileNotification object:nil];
    [nc removeObserver:self name:PFCRemoveProfileNotification object:nil];
} // dealloc

- (void)loadSavedProfiles {

    NSError *error;

    // -------------------------------------------------------------------------
    //  Get path to save folder
    // -------------------------------------------------------------------------
    NSURL *profileFolder = [PFCResources folder:kPFCFolderProfiles];
    if (![profileFolder checkResourceIsReachableAndReturnError:&error]) {
        DDLogError(@"%@", error.localizedDescription);
        return;
    }

    // -------------------------------------------------------------------------
    //  Put all profile plist URLs in an array
    // -------------------------------------------------------------------------
    NSArray *allProfileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:profileFolder includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];

    // -------------------------------------------------------------------------
    //  Add all profiles matching predicate with profile template extension to profile array
    // -------------------------------------------------------------------------
    NSPredicate *predicateProfileManifest = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.pathExtension == '%@'", PFCFileExtensionProfile]];
    NSArray *profileURLs = [allProfileURLs filteredArrayUsingPredicate:predicateProfileManifest];
    [profileURLs enumerateObjectsUsingBlock:^(NSURL *_Nonnull profileURL, NSUInteger idx, BOOL *_Nonnull stop) {

      // -----------------------------------------------------------------------
      //  Read the profile template from disk
      // -----------------------------------------------------------------------
      NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
      if (profileDict.count != 0) {

          // -------------------------------------------------------------------
          //  If title is set in the template and isn't empty, add the profile
          // -------------------------------------------------------------------
          NSString *title = profileDict[PFCProfileKeyTitle] ?: @"";
          if (title.length != 0) {
              [self addProfileWithTitle:title
                  identifier:profileDict[PFCProfileKeyIdentifier] ?: @""
                  payloadSettings:profileDict[PFCProfileKeyPayloadSettings] ?: @{}
                  viewSettings:profileDict[PFCProfileKeyViewSettings] ?: @{}
                  url:profileURL];
          }
      } else {
          DDLogError(@"%s", __PRETTY_FUNCTION__);
          DDLogError(@"Failed reading profile from disk!");
      }
    }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Removes editor from profile when the editor window is closed
// -----------------------------------------------------------------------------
- (void)windowWillCloseNotification:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Get the profile editor instance that's being closed from notification
    // -------------------------------------------------------------------------
    NSWindow *window = notification.object;
    id windowController = window.windowController;
    if ([windowController isKindOfClass:[PFCProfileEditor class]]) {

        // ---------------------------------------------------------------------
        //  Get the profile instance from editor instance
        // ---------------------------------------------------------------------
        PFCProfile *profile = [(PFCProfileEditor *)windowController profile];
        if (profile) {

            // -----------------------------------------------------------------
            //  Remove and cleanup editor reference from profile
            // -----------------------------------------------------------------
            [profile removeEditor];

            // -----------------------------------------------------------------
            //  Check if profile has been saved to disk, else remove it here aswell
            // -----------------------------------------------------------------
            NSError *error;

            // FIXME - The check if the profile has been saved to disk is weak, should probably check the url and where it points aswell?
            if (!profile.url) {
                NSString *identifier = profile.identifier;
                if ([self removeProfileWithIdentifier:identifier error:&error]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PFCDidRemoveProfileNotification object:self userInfo:@{ PFCNotificationUserInfoProfileIdentifiers : @[ identifier ] }];
                } else {
                    // FIXME - Here an error message should be show indicating that something
                    // went wrong and the unsaved profile is a zombie profile that won't persist after a relaunch
                    DDLogError(@"%@", error.localizedDescription);
                }
            }
        }
    }
} // windowWillCloseNotification

// -----------------------------------------------------------------------------
//  Add an empty profile was initiated by user
// -----------------------------------------------------------------------------
- (void)addProfile:(NSNotification *)notification {
    [self addAndEditProfileWithTitle:PFCProfileDefaultName identifier:nil payloadSettings:nil viewSettings:nil url:nil];
} // addProfile

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
    //  Get index set (if available) for profiles to remove
    // -------------------------------------------------------------------------
    NSIndexSet *indexSet;
    __block NSMutableIndexSet *indexSetRemoved;
    if (userInfo[PFCNotificationUserInfoIndexSet] != nil) {
        indexSet = userInfo[PFCNotificationUserInfoIndexSet];
        indexSetRemoved = [[NSMutableIndexSet alloc] init];
    }

    __block NSError *error;
    __block NSMutableArray *removedProfileIdentifiers = [[NSMutableArray alloc] init];
    __block NSInteger indexValue = NSIntegerMin;

    // -------------------------------------------------------------------------
    //  Loop through all profile identifiers to remove
    // -------------------------------------------------------------------------
    [profileIdentifiersToRemove enumerateObjectsUsingBlock:^(NSString *_Nonnull profileIdentifier, NSUInteger idx, BOOL *_Nonnull stop) {

      // -----------------------------------------------------------------------
      //  Try to remove profile
      // -----------------------------------------------------------------------
      if ([self removeProfileWithIdentifier:profileIdentifier error:&error]) {

          // -------------------------------------------------------------------
          //  If profile was removed, add indetifier to new array of identifiers with profiles successfully removed
          // -------------------------------------------------------------------
          [removedProfileIdentifiers addObject:profileIdentifier];
          if (indexSet != nil) {

              // ---------------------------------------------------------------
              //  Calculate the index in the index set for the profile removed and add the index to new index set of profiles successfully removed
              // ---------------------------------------------------------------
              // FIXME - This way of calculating the index value for the current index in the index set seems clunky, don't want to do the NSIntegerMin check each pass
              if (indexValue == NSIntegerMin) {
                  indexValue = indexSet.firstIndex;
              } else {
                  indexValue = [indexSet indexGreaterThanIndex:indexValue];
              }
              [indexSetRemoved addIndex:indexValue];
          }
      } else {
          // FIXME - Removing profile failed, should notify user that something went wrong
          DDLogError(@"%@", error.localizedDescription);
      }
    }];

    // -------------------------------------------------------------------------
    //  If atleast one profile was successfully removed, post notification DidRemoveProfile
    //  passing identifiers and if available index set
    // -------------------------------------------------------------------------
    if (removedProfileIdentifiers.count != 0) {
        NSDictionary *errorUserInfo;
        if (indexSetRemoved) {
            errorUserInfo = @{PFCNotificationUserInfoProfileIdentifiers : removedProfileIdentifiers, PFCNotificationUserInfoIndexSet : [indexSetRemoved copy]};
        } else {
            errorUserInfo = @{PFCNotificationUserInfoProfileIdentifiers : removedProfileIdentifiers};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:PFCDidRemoveProfileNotification object:self userInfo:errorUserInfo];
    }
} // removeProfiles

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods for getting profiles and profile information
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *_Nullable)profileIdentifiers {

    // -------------------------------------------------------------------------
    //  Returns all available profile identifiers
    // -------------------------------------------------------------------------
    return [self.profiles allKeys];
} // profileIdentifiers

- (NSString *_Nullable)titleForProfileWithIdentifier:(NSString *_Nonnull)identifier {

    // -------------------------------------------------------------------------
    //  Convenience method for getting a profile title from it's identifier
    // -------------------------------------------------------------------------
    PFCProfile *profile = [self profileWithIdentifier:identifier];
    if (profile) {
        return profile.title;
    }

    // -------------------------------------------------------------------------
    //  Return the identifier if no profile was found
    // -------------------------------------------------------------------------
    return identifier;
} // titleForProfileWithIdentifier

- (PFCProfile *_Nullable)profileWithIdentifier:(NSString *_Nonnull)identifier {

    // -------------------------------------------------------------------------
    //  Convenience method for getting a profile from it's identifier
    // -------------------------------------------------------------------------
    if (identifier.length == 0) {
        DDLogError(@"%s", __PRETTY_FUNCTION__);
        DDLogError(@"No identifier passed to method");
        return nil;
    }
    return self.profiles[identifier];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods for interacting with profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)saveProfile:(PFCProfile *_Nonnull)profile error:(NSError *_Nullable *_Nullable)error {

    // -------------------------------------------------------------------------
    //  Get path to save folder
    // -------------------------------------------------------------------------
    NSURL *profileFolder = [PFCResources folder:kPFCFolderProfiles];

    // -------------------------------------------------------------------------
    //  Create save folder if it doesn't exist
    // -------------------------------------------------------------------------
    if (![profileFolder checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:profileFolder withIntermediateDirectories:YES attributes:@{} error:error]) {
            DDLogError(@"%@", [*error localizedDescription]);
            return NO;
        }
    }

    // -------------------------------------------------------------------------
    //  Get profile URL, if empty, create one from the profile's identifier
    // -------------------------------------------------------------------------
    NSURL *profileURL = profile.url;
    if (!profileURL) {
        NSString *profileFilename = [NSString stringWithFormat:@"%@.%@", profile.identifier, PFCFileExtensionProfile];
        profileURL = [profileFolder URLByAppendingPathComponent:profileFilename];
    }

    // -------------------------------------------------------------------------
    //  Create the profile template from the current settings:
    //     Title
    //     Identifier
    //     PayloadSettings
    //     ViewSettings
    // -------------------------------------------------------------------------
    NSMutableDictionary *profileDict = [[NSMutableDictionary alloc] init];
    profileDict[PFCProfileKeyTitle] = profile.title;
    profileDict[PFCProfileKeyIdentifier] = profile.identifier;
    profileDict[PFCProfileKeyPayloadSettings] = [profile.profilePayloads.settings copy];
    profileDict[PFCProfileKeyViewSettings] = [profile.viewSettings copy];

    // -------------------------------------------------------------------------
    //  Write the profile template to disk
    // -------------------------------------------------------------------------
    DDLogVerbose(@"Writing profile template to disk: %@", profileDict);
    if (![profileDict writeToURL:profileURL atomically:YES]) {
        // FIXME - Writing profile to file failed, should definitely notify user this failed!
        DDLogError(@"Writing profile template to disk failed!");
        return NO;
    }

    // -------------------------------------------------------------------------
    //  If save was successful, set the profile URL to the profile
    // -------------------------------------------------------------------------
    [profile setUrl:profileURL];

    return YES;
} // saveProfile:error

- (void)editProfileWithIdentifier:(NSString *_Nonnull)identifier {

    // -------------------------------------------------------------------------
    //  Get the profile instance for the identifier
    // -------------------------------------------------------------------------
    PFCProfile *profile = [self profileWithIdentifier:identifier];
    if (profile) {

        // ---------------------------------------------------------------------
        //  Get the current editor instance if one already exist for the profile,
        //  else create a new instance and add a reference of it to the profile
        // ---------------------------------------------------------------------
        PFCProfileEditor *profileEditor = profile.editor;
        if (!profileEditor) {
            profileEditor = [[PFCProfileEditor alloc] initWithProfile:profile];
            [profile setEditor:profileEditor];
        }

        // ---------------------------------------------------------------------
        //  Open the editor window and make it active
        // ---------------------------------------------------------------------
        [profileEditor.window makeKeyAndOrderFront:self];
    } else {
        DDLogError(@"%s", __PRETTY_FUNCTION__);
        DDLogError(@"No profile returned for identifier: %@", identifier);
        // FIXME - Should notify user that something went wrong
    }
} // editProfileWithIdentifier

- (void)exportProfileWithIdentifier:(NSString *_Nonnull)identifier sender:(id _Nonnull)sender {

    NSError *error;

    // -------------------------------------------------------------------------
    //  Get the profile instance for the identifier
    // -------------------------------------------------------------------------
    PFCProfile *profile = [self profileWithIdentifier:identifier];
    if (!profile) {
        DDLogError(@"%s", __PRETTY_FUNCTION__);
        DDLogError(@"No profile returned for identifier: %@", identifier);
        // FIXME - Should notify user that something went wrong
        return;
    }

    // -------------------------------------------------------------------------
    //  Get the payload settings enabled for export
    //  Verify that there is atleast one payload enabled for export (except for General)
    // -------------------------------------------------------------------------
    NSDictionary *payloadSettings = [profile payloadSettingsForExport:&error];

    // FIXME - This check is weak, should probably loop and verify.
    // Now just assumes that 2 == PayloadTypes and General
    if (payloadSettings.count <= 2) {
        if (error.code == -59) {
            // FIXME - Should specify the error codes in constants, this is just a test
            // Not Saved
        } else {
            error = [PFCError errorWithDescription:NSLocalizedString(@"No payload selected in profile.", @"")
                                     failureReason:NSLocalizedString(@"At least one payload must be included to export a profile.\n\nMove a payload from the library to the profile payloads list in the editor to include it in the profile.", @"")
                                              code:-60];
        }
        [self setAlert:[[PFCAlert alloc] init]];
        [self.alert showAlertErrorWithError:error window:[[NSApplication sharedApplication] mainWindow]];
        return;
    }

    // -------------------------------------------------------------------------
    //  Setup the accessory view to the save panel
    // -------------------------------------------------------------------------
    PFCProfileExportAccessoryView *accessoryView = [[PFCProfileExportAccessoryView alloc] initWithProfile:profile];

    // -------------------------------------------------------------------------
    //  Setup a save panel and present it to the user in the main window
    // -------------------------------------------------------------------------
    NSSavePanel *panel = [[NSSavePanel alloc] init];
    [panel setAccessoryView:accessoryView];
    [panel setAllowedFileTypes:@[ @"com.apple.mobileconfig" ]];
    [panel setCanCreateDirectories:YES];
    [panel setTitle:NSLocalizedString(@"Export Profile", @"")];
    [panel setPrompt:NSLocalizedString(@"Export", @"")];
    [panel setNameFieldStringValue:profile.title];
    [panel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                  completionHandler:^(NSInteger result) {

                    // ---------------------------------------------------------
                    //  If user selected to export profile, export it
                    // ---------------------------------------------------------
                    if (result == NSFileHandlingPanelOKButton) {
                        [self exportProfile:profile payloadSettings:payloadSettings url:panel.URL];
                    }
                  }];
} // exportProfileWithIdentifier:sender

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Convenience method for creating a new profile and immediately edit it
// -----------------------------------------------------------------------------
- (void)addAndEditProfileWithTitle:(NSString *_Nullable)title
                        identifier:(NSString *_Nullable)identifier
                   payloadSettings:(NSDictionary *_Nullable)payloadSettings
                      viewSettings:(NSDictionary *_Nullable)viewSettings
                               url:(NSURL *_Nullable)url {

    // -------------------------------------------------------------------------
    //  Create and add a new profile to the internal store
    // -------------------------------------------------------------------------
    PFCProfile *profile = [self addProfileWithTitle:title identifier:identifier payloadSettings:payloadSettings viewSettings:viewSettings url:url];

    // -------------------------------------------------------------------------
    //  Open a profile editor window for the newly created profile
    // -------------------------------------------------------------------------
    [self editProfileWithIdentifier:profile.identifier];
} // addAndEditProfileWithTitle:identifier:payloadSettings:viewSettings:url

// -----------------------------------------------------------------------------
//  Convenience method for creating a new profile and adding it to the internal store
// -----------------------------------------------------------------------------
- (PFCProfile *_Nonnull)addProfileWithTitle:(NSString *_Nullable)title
                                 identifier:(NSString *_Nullable)identifier
                            payloadSettings:(NSDictionary *_Nullable)payloadSettings
                               viewSettings:(NSDictionary *_Nullable)viewSettings
                                        url:(NSURL *_Nullable)url {

    // -------------------------------------------------------------------------
    //  Create and add a new profile to the internal store
    // -------------------------------------------------------------------------
    PFCProfile *profile = [[PFCProfile alloc] initWithTitle:title identifier:identifier payloadSettings:payloadSettings viewSettings:viewSettings url:url];
    self.profiles[profile.identifier] = profile;

    // -------------------------------------------------------------------------
    //  Notify all interested parties that a new profile has been added
    // -------------------------------------------------------------------------
    NSDictionary *userInfo = @{PFCNotificationUserInfoProfileIdentifier : profile.identifier};
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCDidAddProfileNotification object:self userInfo:userInfo];

    // -------------------------------------------------------------------------
    //  Return the newly created profile
    // -------------------------------------------------------------------------
    return profile;
} // addProfileWithTitle:identifier:payloadSettings:viewSettings:url

// -----------------------------------------------------------------------------
//  This method is called when basic export checks have passed and the user has chosen
//  the path to export the profile to. Here it just should export.
// -----------------------------------------------------------------------------
- (void)exportProfile:(PFCProfile *_Nonnull)profile payloadSettings:(NSDictionary *_Nonnull)payloadSettings url:(NSURL *_Nonnull)url {

    DDLogDebug(@"Exporting profile with settings: %@", payloadSettings);
    NSError *error;

    // -------------------------------------------------------------------------
    //  Ask the ProfilePayloads framework to generate the profile from the settings and selections:
    //      Scope
    //      Distribution
    //      Supervised
    //      PayloadSettings
    //      ViewModel
    // -------------------------------------------------------------------------
    PFPProfilePayloads *profilePayloads = profile.profilePayloads ?: [[PFPProfilePayloads alloc] initWithSettings:payloadSettings viewModel:kPFPViewModelTableView settingsDelegate:nil];
    NSDictionary *profileDict =
        [profilePayloads profileWithSettings:payloadSettings baseIdentifier:PFCBundleIdentifier scope:profile.scope distribution:profile.distribution supervised:profile.showSupervised error:&error];

    // -------------------------------------------------------------------------
    //  Sign Profile
    // -------------------------------------------------------------------------
    // FIXME - Not implemented yet, but here we have the finished profile before writing it to disk

    // -------------------------------------------------------------------------
    //  Verify a vaild profile was returned
    // -------------------------------------------------------------------------
    // FIXME - This check just cheks if a dict with content was returned or not
    //         This should be expanded
    if (profileDict.count == 0) {
        DDLogError(@"Generating a profile from current settings failed!");
        DDLogError(@"%@", error.localizedDescription);
        return;
    }

    // -------------------------------------------------------------------------
    //  Write the finished profile to disk
    // -------------------------------------------------------------------------
    DDLogDebug(@"Writing profile to disk: %@", profileDict);
    if (![profileDict writeToURL:url atomically:YES]) {
        // FIXME - Writing the profile to disk failed, this should be notified to the user
        DDLogError(@"Writing profile to disk failed!");
        return;
    }

    // -------------------------------------------------------------------------
    //  If export updated profile payloads dict, save changes to disk
    // -------------------------------------------------------------------------
    if (![payloadSettings isEqualToDictionary:profilePayloads.settings]) {
        if (!profile.profilePayloads) {
            [profile setProfilePayloads:profilePayloads];
        }

        if (![profile save]) {
            // FIXME - Show error that save failed!
        }

        [profile setProfilePayloads:nil];
    }

} // exportProfile:payloadSettings:url

// -----------------------------------------------------------------------------
//  This method is called when basic remove checks have passed and the user
//  has verified that the profile should be removed.
// -----------------------------------------------------------------------------
- (BOOL)removeProfileWithIdentifier:(NSString *_Nonnull)identifier error:(NSError *_Nullable *_Nullable)error {

    DDLogDebug(@"Removing profile with identifier: %@", identifier);

    // -------------------------------------------------------------------------
    //  Get the profile instance for the identifier
    // -------------------------------------------------------------------------
    PFCProfile *profile = [self profileWithIdentifier:identifier];
    if (profile) {

        // ---------------------------------------------------------------------
        //  Get and verify the profile url is pointing to a profile on disk
        // ---------------------------------------------------------------------
        NSURL *profileURL = profile.url;
        if (!profileURL || ![profileURL checkResourceIsReachableAndReturnError:nil]) {
            [self.profiles removeObjectForKey:identifier];
            return YES;
        }

        // ---------------------------------------------------------------------
        //  Try to remove the profile on disk, and return the result
        // ---------------------------------------------------------------------
        DDLogInfo(@"Removing profile at path: %@", profileURL.path);
        return [[NSFileManager defaultManager] removeItemAtURL:profileURL error:error];
    } else {
        DDLogError(@"%s", __PRETTY_FUNCTION__);
        DDLogError(@"No profile returned for identifier: %@", identifier);
        // FIXME - Should notify user that something went wrong
        return NO;
    }
} // removeProfileWithIdentifier

@end

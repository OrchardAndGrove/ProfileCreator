//
//  PFCConstants.h
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

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark Enums
////////////////////////////////////////////////////////////////////////////////

// PFCSessionTypes
typedef NS_ENUM(NSUInteger, PFCSessionType) {
    kPFCSessionTypeCLI = 0, // Command Line Session
    kPFCSessionTypeGUI      // GUI Session
};

// PFCPayloadLibrary
typedef NS_ENUM(NSUInteger, PFCPayloadLibrary) {
    kPFCPayloadLibraryAll = 0,
    kPFCPayloadLibraryApple,
    kPFCPayloadLibraryMCX,
    kPFCPayloadLibraryCustom,
    kPFCPayloadLibraryDeveloper,
    kPFCPayloadLibraryProfile,
    kPFCPayloadLibraryUserPreferences,
    kPFCPayloadLibraryLibraryPreferences,
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark Profile Creator
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCBundleIdentifier;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Error
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCErrorDomain;

////////////////////////////////////////////////////////////////////////////////
#pragma mark File Extensions
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCFileExtensionGroup;
extern NSString *const PFCFileExtensionProfile;

////////////////////////////////////////////////////////////////////////////////
#pragma mark MainWindow Group
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCMainWindowGroupLibrary;
extern NSString *const PFCMainWindowGroupLibraryTitle;
extern NSString *const PFCMainWindowGroupKeyTitle;
extern NSString *const PFCMainWindowGroupKeyIdentifier;
extern NSString *const PFCMainWindowGroupKeyProfileIdentifiers;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Profile Template Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCProfileKeyTitle;
extern NSString *const PFCProfileKeyIdentifier;
extern NSString *const PFCProfileKeyPayloadSettings;
extern NSString *const PFCProfileKeyViewSettings;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Group Template Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCGroupTemplateKeyTitle;
extern NSString *const PFCGroupTemplateKeyIdentifier;
extern NSString *const PFCGroupTemplateKeyProfileIdentifiers;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Unsorted
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCProfileDefaultName;
extern NSString *const PFCProfileDraggingType;
extern NSString *const PFCPayloadPlaceholderDraggingType;
extern NSString *const PFCMainWindowOutlineViewParentTitleAllProfiles;
extern NSString *const PFCMainWindowOutlineViewParentTitleLibrary;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Notification
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCAddGroupNotification;
extern NSString *const PFCDidAddGroupNotification;
extern NSString *const PFCAddProfileNotification;
extern NSString *const PFCDidAddProfileNotification;
extern NSString *const PFCRemoveProfileNotification;
extern NSString *const PFCDidRemoveProfileNotification;
extern NSString *const PFCDidSaveProfileNotification;
extern NSString *const PFCGroupDidRemoveProfileNotification;
extern NSString *const PFCExportProfileNotification;
extern NSString *const PFCProfileSelectionDidChangeNotification;
extern NSString *const PFCNoProfileConfiguredNotification;
extern NSString *const PFCSelectProfileSettingsNotification;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Notification User Info
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCNotificationUserInfoIndexSet;
extern NSString *const PFCNotificationUserInfoParentTitle;
extern NSString *const PFCNotificationUserInfoProfileIdentifier;
extern NSString *const PFCNotificationUserInfoProfileIdentifiers;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Button Titles
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCButtonTitleCancel;
extern NSString *const PFCButtonTitleClose;
extern NSString *const PFCButtonTitleDelete;
extern NSString *const PFCButtonTitleSave;
extern NSString *const PFCButtonTitleSaveAndClose;
extern NSString *const PFCButtonTitleOK;

////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCUserDefaultsDefaultOrganization;
extern NSString *const PFCUserDefaultsLogLevel;
extern NSString *const PFCUserDefaultsShowProfileCount;
extern NSString *const PFCUserDefaultsShowGroupIcons;
extern NSString *const PFCUserDefaultsShowPayloadLibraryApple;
extern NSString *const PFCUserDefaultsShowPayloadLibraryLocal;
extern NSString *const PFCUserDefaultsShowPayloadLibraryMCX;
extern NSString *const PFCUserDefaultsShowPayloadLibraryCustom;
extern NSString *const PFCUserDefaultsShowPayloadLibraryDeveloper;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ViewSettings Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCViewSettingsKeyScope;
extern NSString *const PFCViewSettingsKeyDistribution;
extern NSString *const PFCViewSettingsKeyShowDisabled;
extern NSString *const PFCViewSettingsKeyShowHidden;
extern NSString *const PFCViewSettingsKeyShowSupervised;

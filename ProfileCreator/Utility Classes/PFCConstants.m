//
//  PFCConstants.m
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark Profile Creator
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCBundleIdentifier = @"com.github.ProfileCreator";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Error
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCErrorDomain = @"com.github.ProfileCreator";

////////////////////////////////////////////////////////////////////////////////
#pragma mark File Extensions
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCFileExtensionGroup = @"pfcgrp";
NSString *const PFCFileExtensionProfile = @"pfcconf";

////////////////////////////////////////////////////////////////////////////////
#pragma mark MainWindow Group
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCMainWindowGroupLibrary = @"kGroupLibrary";
NSString *const PFCMainWindowGroupLibraryTitle = @"Library";
NSString *const PFCMainWindowGroupKeyTitle = @"Title";
NSString *const PFCMainWindowGroupKeyIdentifier = @"Identifier";
NSString *const PFCMainWindowGroupKeyProfileIdentifiers = @"ProfileIdentifiers";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Profile Template Keys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCProfileKeyTitle = @"Title";
NSString *const PFCProfileKeyIdentifier = @"Identifier";
NSString *const PFCProfileKeyPayloadSettings = @"PayloadSettings";
NSString *const PFCProfileKeyViewSettings = @"ViewSettings";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Group Template Keys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCGroupTemplateKeyTitle = @"Title";
NSString *const PFCGroupTemplateKeyIdentifier = @"Identifier";
NSString *const PFCGroupTemplateKeyProfileIdentifiers = @"ProfileIdentifiers";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Unsorted
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCProfileDefaultName = @"Untitled";
NSString *const PFCProfileDraggingType = @"PFCProfileDraggingType";
NSString *const PFCPayloadPlaceholderDraggingType = @"PFCPayloadPlaceholderDraggingType";
NSString *const PFCMainWindowOutlineViewParentTitleAllProfiles = @"All Profiles";
NSString *const PFCMainWindowOutlineViewParentTitleLibrary = @"Library";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Notification
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCAddGroupNotification = @"AddGroupNotification";
NSString *const PFCDidAddGroupNotification = @"DidAddGroupNotification";
NSString *const PFCAddProfileNotification = @"AddProfileNotification";
NSString *const PFCDidAddProfileNotification = @"DidAddProfileNotification";
NSString *const PFCRemoveProfileNotification = @"RemoveProfileNotification";
NSString *const PFCDidRemoveProfileNotification = @"DidRemoveProfileNotification";
NSString *const PFCDidSaveProfileNotification = @"DidSaveProfileNotification";
NSString *const PFCGroupDidRemoveProfileNotification = @"GroupDidRemoveProfileNotification";
NSString *const PFCExportProfileNotification = @"ExportProfileNotification";
NSString *const PFCProfileSelectionDidChangeNotification = @"ProfileSelectionDidChangeNotification";
NSString *const PFCNoProfileConfiguredNotification = @"NoProfileConfiguredNotification";
NSString *const PFCSelectProfileSettingsNotification = @"SelectProfileSettingsNotification";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Notification User Info
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCNotificationUserInfoIndexSet = @"IndexSet";
NSString *const PFCNotificationUserInfoParentTitle = @"ParentTitle";
NSString *const PFCNotificationUserInfoProfileIdentifier = @"ProfileIdentifier";
NSString *const PFCNotificationUserInfoProfileIdentifiers = @"ProfileIdentifiers";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Button Titles
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCButtonTitleCancel = @"Cancel";
NSString *const PFCButtonTitleClose = @"Close";
NSString *const PFCButtonTitleSave = @"Save";
NSString *const PFCButtonTitleSaveAndClose = @"Save & Close";
NSString *const PFCButtonTitleDelete = @"Delete";
NSString *const PFCButtonTitleOK = @"OK";

////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCUserDefaultsDefaultOrganization = @"DefaultOrganization";
NSString *const PFCUserDefaultsLogLevel = @"LogLevel";
NSString *const PFCUserDefaultsShowProfileCount = @"ShowProfileCount";
NSString *const PFCUserDefaultsShowGroupIcons = @"ShowGroupIcons";
NSString *const PFCUserDefaultsShowPayloadLibraryApple = @"ShowPayloadLibraryApple";
NSString *const PFCUserDefaultsShowPayloadLibraryLocal = @"ShowPayloadLibraryLocal";
NSString *const PFCUserDefaultsShowPayloadLibraryMCX = @"ShowPayloadLibraryMCX";
NSString *const PFCUserDefaultsShowPayloadLibraryCustom = @"ShowPayloadLibraryCustom";
NSString *const PFCUserDefaultsShowPayloadLibraryDeveloper = @"ShowPayloadLibraryDeveloper";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ViewSettings Keys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCViewSettingsKeyScope = @"Scope";
NSString *const PFCViewSettingsKeyDistribution = @"Distribution";
NSString *const PFCViewSettingsKeyShowDisabled = @"ShowDisabled";
NSString *const PFCViewSettingsKeyShowHidden = @"ShowHidden";
NSString *const PFCViewSettingsKeyShowSupervised = @"ShowSupervised";

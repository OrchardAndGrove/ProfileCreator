//
//  PFPConstants.h
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

#import <Foundation/Foundation.h>

// PFPValueType
typedef NS_ENUM(NSUInteger, PFPValueType) {
    kPFPValueTypeArray = 0,
    kPFPValueTypeBoolean,
    kPFPValueTypeData,
    kPFPValueTypeDate,
    kPFPValueTypeDict,
    kPFPValueTypeFloat,
    kPFPValueTypeInteger,
    kPFPValueTypeString,
    kPFPValueTypeUnknown
};

// PFPViewModel
typedef NS_ENUM(NSUInteger, PFPViewModel) { kPFPViewModelNone = 0, kPFPViewModelTableView };

// PFPViewType
typedef NS_ENUM(NSUInteger, PFPViewType) { kPFPViewTypeNone = 0, kPFPViewTypeUnknown, kPFPViewTypeDatePicker, kPFPViewTypeFile, kPFPViewTypeHostPort, kPFPViewTypePopUpButton, kPFPViewTypeTextField, kPFPViewTypeTextView, kPFPViewTypeCheckbox };

// PFPViewStyle
typedef NS_ENUM(NSUInteger, PFPViewStyle) { kPFPViewStyleDefault = 0, kPFPViewStyleList, kPFPViewStyleListCentered };

// PFPFontWeight
typedef NS_ENUM(NSUInteger, PFPFontWeight) { kPFPFontWeightRegular = 0, kPFPFontWeightBold };

// PFPCollectionSet
typedef NS_ENUM(NSUInteger, PFPCollectionSet) { kPFPCollectionSetApple = 0 };

// PFPOrientationAttribute
typedef NS_ENUM(NSUInteger, PFPOrientationAttribute) { kPFPOrientationAttributeAbove = 0, kPFPOrientationAttributeLeading, kPFPOrientationAttributeTrailing, kPFPOrientationAttributeBelow };

// PFPScope
typedef NS_OPTIONS(NSUInteger, PFPScope) {
    kPFPScopeSystem = (1 << 0), // => 00000001
    kPFPScopeUser = (1 << 1)    // => 00000010
};

// PFPNoticeIcon
typedef NS_OPTIONS(NSUInteger, PFPNoticeIcon) {
    kPFPNoticeIconError = (1 << 0),  // => 00000001
    kPFPNoticeIconWarning = (1 << 1) // => 00000010
};

// PFPDistribution
typedef NS_OPTIONS(NSUInteger, PFPDistribution) {
    kPFPDistributionManual = (1 << 0), // => 00000001
    kPFPDistributionPush = (1 << 1)    // => 00000010
};

// PFPOSPlatform
typedef NS_OPTIONS(NSUInteger, PFPOSPlatform) {
    kPFPPlatformiOS = (1 << 0),  // => 00000001
    kPFPPlatformmacOS = (1 << 1) // => 00000010

};

////////////////////////////////////////////////////////////////////////////////
#pragma mark Other
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPPayloadKeyPathDelimiter;
extern NSString *_Nonnull const PFPPayloadCollectionSetKeyCollections;

extern NSString *_Nonnull const PFPStringScopeUser;
extern NSString *_Nonnull const PFPStringScopeSystem;

extern NSString *_Nonnull const PFPStringDistributionManual;
extern NSString *_Nonnull const PFPStringDistributionPush;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Error
///////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPErrorDomain;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Placeholder Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPPlaceholderKeyCollectionSet;
extern NSString *_Nonnull const PFPPlaceholderKeyIcon;
extern NSString *_Nonnull const PFPPlaceholderKeyIdentifier;
extern NSString *_Nonnull const PFPPlaceholderKeyTitle;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Platform
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPPlatformiOS;           // String representing platform iOS.
extern NSString *_Nonnull const PFPPlatformmacOS;         // String representing platform macOS.
extern NSString *_Nonnull const PFPPlatformVersionLatest; // String representing whatever the latest version is.
extern NSString *_Nonnull const PFPPlatformVersionLatestiOS;
extern NSString *_Nonnull const PFPPlatformVersionLatestmacOS;
extern NSString *_Nonnull const PFPPlatformVersionMiniOS;   // String representing lowest supported iOS version.
extern NSString *_Nonnull const PFPPlatformVersionMinmacOS; // String representing lowest supported macOS version.

////////////////////////////////////////////////////////////////////////////////
#pragma mark Manifest Keys
////////////////////////////////////////////////////////////////////////////////
// Unsorted
extern NSString *_Nonnull const PFPManifestKeyDate;
extern NSString *_Nonnull const PFPManifestKeyDescription;
extern NSString *_Nonnull const PFPManifestKeyDomain;
extern NSString *_Nonnull const PFPManifestKeyExtendedDescription;
extern NSString *_Nonnull const PFPManifestKeyIcon;
extern NSString *_Nonnull const PFPManifestKeyIdentifier;
extern NSString *_Nonnull const PFPManifestKeyOptional;
extern NSString *_Nonnull const PFPManifestKeyRequired;
extern NSString *_Nonnull const PFPManifestKeySubkeys;
extern NSString *_Nonnull const PFPManifestKeySupervised;
extern NSString *_Nonnull const PFPManifestKeyTitle;
extern NSString *_Nonnull const PFPManifestKeyVisibleRows;
extern NSString *_Nonnull const PFPManifestKeyPopUpButtonWidth;
extern NSString *_Nonnull const PFPManifestKeyFilePrompt;
extern NSString *_Nonnull const PFPManifestKeyFileProcessor;
extern NSString *_Nonnull const PFPManifestKeyFileButtonTitle;
extern NSString *_Nonnull const PFPManifestKeyAllowedFileTypes;
extern NSString *_Nonnull const PFPManifestKeyAllowedFileExtensions;
extern NSString *_Nonnull const PFPManifestKeyNoTitle;
extern NSString *_Nonnull const PFPManifestKeyNoDescription;
extern NSString *_Nonnull const PFPManifestKeyHidden;
extern NSString *_Nonnull const PFPManifestKeyExclude;
extern NSString *_Nonnull const PFPManifestKeyShowDate;
extern NSString *_Nonnull const PFPManifestKeyShowDateTime;
extern NSString *_Nonnull const PFPManifestKeyShowDateInterval;
extern NSString *_Nonnull const PFPManifestKeySelectionDefault;

// Distribution
extern NSString *_Nonnull const PFPManifestKeyDistribution;
extern NSString *_Nonnull const PFPManifestKeyDistributionManual;
extern NSString *_Nonnull const PFPManifestKeyDistributionPush;

// Payload
extern NSString *_Nonnull const PFPManifestKeyPayloadKey;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeys;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPath;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathCheckbox;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathDatePicker;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathFile;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathHost;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathPort;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathPopUpButton;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathTextField;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathTextView;
extern NSString *_Nonnull const PFPManifestKeyPayloadType;
extern NSString *_Nonnull const PFPManifestKeyPayloadTypes;

// Platform
extern NSString *_Nonnull const PFPManifestKeyPlatform;
extern NSString *_Nonnull const PFPManifestKeyPlatformMinVersion;
extern NSString *_Nonnull const PFPManifestKeyPlatformMaxVersion;
extern NSString *_Nonnull const PFPManifestKeyPlatforms;

// Scope
extern NSString *_Nonnull const PFPManifestKeyScope;
extern NSString *_Nonnull const PFPManifestKeyScopeSystem;
extern NSString *_Nonnull const PFPManifestKeyScopeUser;

// Target
extern NSString *_Nonnull const PFPManifestKeyTarget;
extern NSString *_Nonnull const PFPManifestKeyTargetContainsAny;
extern NSString *_Nonnull const PFPManifestKeyTargetValue;

// Value
extern NSString *_Nonnull const PFPManifestKeyValue;
extern NSString *_Nonnull const PFPManifestKeyValueDefault;
extern NSString *_Nonnull const PFPManifestKeyValueDefaultKeyPath;
extern NSString *_Nonnull const PFPManifestKeyValueList;
extern NSString *_Nonnull const PFPManifestKeyValuePlaceholder;
extern NSString *_Nonnull const PFPManifestKeyValueMax;
extern NSString *_Nonnull const PFPManifestKeyValueMin;
extern NSString *_Nonnull const PFPManifestKeyValueMinOffsetDays;
extern NSString *_Nonnull const PFPManifestKeyValueMinOffsetHours;
extern NSString *_Nonnull const PFPManifestKeyValueMinOffsetMinutes;
extern NSString *_Nonnull const PFPManifestKeyValueType;
extern NSString *_Nonnull const PFPManifestKeyValueTitles;
extern NSString *_Nonnull const PFPManifestKeyValueSubkeys;
extern NSString *_Nonnull const PFPManifestKeyValueIsSensitive;

// Conditions
extern NSString *_Nonnull const PFPManifestKeyPayloadTypeConditions;
extern NSString *_Nonnull const PFPManifestKeyExcludeConditions;
extern NSString *_Nonnull const PFPManifestKeyHiddenConditions;
extern NSString *_Nonnull const PFPManifestKeyOptionalConditions;
extern NSString *_Nonnull const PFPManifestKeySupervisedConditions;
extern NSString *_Nonnull const PFPManifestKeyConditions;
extern NSString *_Nonnull const PFPManifestKeyValueKeyPath;
extern NSString *_Nonnull const PFPManifestKeyValueContains;
extern NSString *_Nonnull const PFPManifestKeyValueContainsAny;

// ViewType
extern NSString *_Nonnull const PFPManifestKeyViewType;

// ViewStyle
extern NSString *_Nonnull const PFPManifestKeyViewStyle;
extern NSString *_Nonnull const PFPViewStyleList;
extern NSString *_Nonnull const PFPViewStyleListCentered;

// ViewItem
extern NSString *_Nonnull const PFPViewItemDatePicker;
extern NSString *_Nonnull const PFPViewItemFile;
extern NSString *_Nonnull const PFPViewItemHost;
extern NSString *_Nonnull const PFPViewItemPort;
extern NSString *_Nonnull const PFPViewItemPopUpButton;
extern NSString *_Nonnull const PFPViewItemTextField;
extern NSString *_Nonnull const PFPViewItemTextView;
extern NSString *_Nonnull const PFPViewItemCheckbox;

// More

extern NSString *_Nonnull const PFPManifestKeyInputWidth;
extern NSString *_Nonnull const PFPManifestKeyShowStepper;

////////////////////////////////////////////////////////////////////////////////
#pragma mark PayloadValueTypes
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPValueTypeArray;
extern NSString *_Nonnull const PFPValueTypeBoolean;
extern NSString *_Nonnull const PFPValueTypeData;
extern NSString *_Nonnull const PFPValueTypeDate;
extern NSString *_Nonnull const PFPValueTypeDict;
extern NSString *_Nonnull const PFPValueTypeFloat;
extern NSString *_Nonnull const PFPValueTypeInteger;
extern NSString *_Nonnull const PFPValueTypeString;

////////////////////////////////////////////////////////////////////////////////
#pragma mark FileInfo Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPFileInfoKeyName;
extern NSString *_Nonnull const PFPFileInfoKeyType;

////////////////////////////////////////////////////////////////////////////////
#pragma mark FileDescription Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPFileDescriptionKeyTitle;
extern NSString *_Nonnull const PFPFileDescriptionKeyIcon;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionTop;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionTopError;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionTopLabel;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionCenter;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionCenterError;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionCenterLabel;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionBottom;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionBottomError;
extern NSString *_Nonnull const PFPFileDescriptionKeyDescriptionBottomLabel;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Settings Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPSettingsKeyEnabled;
extern NSString *_Nonnull const PFPSettingsKeyPayloadHash;
extern NSString *_Nonnull const PFPSettingsKeyPayloadUUID;
extern NSString *_Nonnull const PFPSettingsKeyPayloadType;
extern NSString *_Nonnull const PFPSettingsKeyPayloadVersion;
extern NSString *_Nonnull const PFPSettingsKeyValue;
extern NSString *_Nonnull const PFPSettingsKeyValueCheckbox;
extern NSString *_Nonnull const PFPSettingsKeyValueDatePicker;
extern NSString *_Nonnull const PFPSettingsKeyValueFile;
extern NSString *_Nonnull const PFPSettingsKeyValueFileInfo;
extern NSString *_Nonnull const PFPSettingsKeyValueHost;
extern NSString *_Nonnull const PFPSettingsKeyValuePort;
extern NSString *_Nonnull const PFPSettingsKeyValueKey;
extern NSString *_Nonnull const PFPSettingsKeyValueSelection;
extern NSString *_Nonnull const PFPSettingsKeyValueTextField;
extern NSString *_Nonnull const PFPSettingsKeyValueTextView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Payload Types
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPPayloadTypeConfiguration;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Profile Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPProfileKeyPayloadContent;
extern NSString *_Nonnull const PFPProfileKeyPayloadEnabled;
extern NSString *_Nonnull const PFPProfileKeyPayloadIdentifier;
extern NSString *_Nonnull const PFPProfileKeyPayloadScope;
extern NSString *_Nonnull const PFPProfileKeyPayloadType;
extern NSString *_Nonnull const PFPProfileKeyPayloadUUID;
extern NSString *_Nonnull const PFPProfileKeyPayloadVersion;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ViewType TableView
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPViewTypeCheckbox;
extern NSString *_Nonnull const PFPViewTypeDatePicker;
extern NSString *_Nonnull const PFPViewTypeFile;
extern NSString *_Nonnull const PFPViewTypeHostPort;
extern NSString *_Nonnull const PFPViewTypePopUpButton;
extern NSString *_Nonnull const PFPViewTypeTextField;
extern NSString *_Nonnull const PFPViewTypeTextView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark UserChange Keys
////////////////////////////////////////////////////////////////////////////////
extern NSString *_Nonnull const PFPUserChangeKeyCollectionIdentifier;
extern NSString *_Nonnull const PFPUserChangeKeyCollectionKeyIdentifier;
extern NSString *_Nonnull const PFPUserChangeKeyNotificationEvent;
extern NSString *_Nonnull const PFPUserChangeKeyValue;
extern NSString *_Nonnull const PFPUserChangeKeyValueKeyPath;

//
//  PFPConstants.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-14.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

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
typedef NS_ENUM(NSUInteger, PFPViewType) { kPFPViewTypeNone = 0, kPFPViewTypeUnknown, kPFPViewTypeDatePicker, kPFPViewTypeFile, kPFPViewTypePopUpButton, kPFPViewTypeTextField, kPFPViewTypeTextView };

// PFPFontWeight
typedef NS_ENUM(NSUInteger, PFPFontWeight) { kPFPFontWeightRegular = 0, kPFPFontWeightBold };

// PFPCollection
typedef NS_ENUM(NSUInteger, PFPCollectionSet) { kPFPCollectionSetProfileManager = 0 };

// PFPOrientationAttribute
typedef NS_ENUM(NSUInteger, PFPOrientationAttribute) { kPFPOrientationAttributeAbove = 0, kPFPOrientationAttributeLeading, kPFPOrientationAttributeTrailing, kPFPOrientationAttributeBelow };

// PFPScope
typedef NS_OPTIONS(NSUInteger, PFPScope) {
    kPFPScopeSystem = (1 << 0), // => 00000001
    kPFPScopeUser = (1 << 1)    // => 00000010
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
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPath;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathDatePicker;
extern NSString *_Nonnull const PFPManifestKeyPayloadKeyPathFile;
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
extern NSString *_Nonnull const PFPManifestKeyValueSubkeys;

// ViewType
extern NSString *_Nonnull const PFPManifestKeyViewType;

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
extern NSString *_Nonnull const PFPSettingsKeyValue;
extern NSString *_Nonnull const PFPSettingsKeyValueDatePicker;
extern NSString *_Nonnull const PFPSettingsKeyValueFile;
extern NSString *_Nonnull const PFPSettingsKeyValueFileInfo;
extern NSString *_Nonnull const PFPSettingsKeyValueKey;
extern NSString *_Nonnull const PFPSettingsKeyValuePopUpButton;
extern NSString *_Nonnull const PFPSettingsKeyValueTextField;
extern NSString *_Nonnull const PFPSettingsKeyValueTextView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ViewTypes
////////////////////////////////////////////////////////////////////////////////

extern NSString *_Nonnull const PFPViewTypeDatePicker;
extern NSString *_Nonnull const PFPViewTypeFile;
extern NSString *_Nonnull const PFPViewTypePopUpButton;
extern NSString *_Nonnull const PFPViewTypeTextField;
extern NSString *_Nonnull const PFPViewTypeTextView;

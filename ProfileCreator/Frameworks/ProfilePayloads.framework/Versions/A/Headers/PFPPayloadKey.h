//
//  PFPPayloadTypeKey.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-25.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#pragma once

@class PFPPayloadType;
@class PFPPlatform;
@class PFPPayloadTypeKey;

@protocol PFPPayloadKey <NSObject>

@required
@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly) PFPValueType valueType;
@property (nonatomic, weak, readonly, nullable) PFPPayloadType *payloadType;
@property (nonatomic, readonly, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, nonnull) NSArray<PFPPayloadTypeKey *> *subkeys;
@property (nonatomic, readonly, nonnull) NSDictionary *payloadKeyDict;
@property (nonatomic, readonly, nonnull) NSString *payloadKey;
@property (nonatomic, readonly, nonnull) NSString *payloadKeyPath;
@property (nonatomic, readonly, nonnull) NSString *payloadTypeString;
@property (nonatomic, readonly, nonnull) NSString *identifier;

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *descriptionString;
@property (nonatomic, readonly, nullable) NSString *extendedDescription;
@property (nonatomic, readonly, nullable) NSDictionary *excludeDict;
@property (nonatomic, readonly, nullable) NSArray *requiredArray;
@property (nonatomic, readonly) BOOL optional;
@property (nonatomic, readonly) BOOL supervised;

@property (nonatomic, readonly, nullable) id valueDefault;
@property (nonatomic, readonly, nullable) id valueMax;           // (Only used for Integer/Float and Date types)
@property (nonatomic, readonly, nullable) id valueMin;           // (Only used for Integer/Float and Date types)
@property (nonatomic, readonly, nullable) NSString *valueFormat; // Regex string the value need to conform to (Only used for String types)
@property (nonatomic, readonly, nullable) NSArray *valueList;    // List of selectable values
@property (nonatomic, readonly) BOOL valueInvert;                // (Only used for Boolean types)

@end

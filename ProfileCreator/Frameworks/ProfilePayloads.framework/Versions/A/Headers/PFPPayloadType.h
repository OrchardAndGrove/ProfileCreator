//
//  PFPPayloadType.h
//  ProfileKeys
//
//  Created by Erik Berglund on 2016-08-25.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPConstants.h"
#import <Foundation/Foundation.h>
@class PFPPayloadTypeKey;
@class PFPPlatform;

@interface PFPPayloadType : NSObject

@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, nonnull) NSString *payloadType;
@property (nonatomic, readonly, nonnull) NSArray<PFPPayloadTypeKey *> *subkeys;
@property (nonatomic, readonly, nonnull) NSDictionary *payloadKeyDict;
@property (nonatomic, readonly, nonnull) NSString *domain;
@property (nonatomic, readonly, nonnull) NSString *title;
@property (nonatomic, readonly, nonnull) NSString *descriptionString;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

/*!
 @brief Default `init` is not available
 */
- (nonnull instancetype)init NS_UNAVAILABLE;

/*!
 @brief Initializes class with required parameters.
 @discussion FIXME
 @param  manifestDict
 @return instancetype
 */
- (nullable instancetype)initWithManifest:(NSDictionary *_Nonnull)manifestDict;

// Access payload keys by identifier
/*
- (PFPPayloadTypeKey *_Nullable)payloadKeyWithIdentifier:(NSString *_Nonnull)identifier;
- (NSArray<PFPPayloadTypeKey *> *_Nullable)payloadKeysWithIdentifiers:(NSArray<NSString *> *_Nonnull)identifiers;
*/

// Access payload keys by payload key path
- (PFPPayloadTypeKey *_Nullable)payloadKeyForPayloadKeyPath:(NSString *_Nonnull)payloadKeyPath error:(NSError *_Nullable *_Nullable)error; // Only last key
@end

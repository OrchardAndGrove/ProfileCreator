//
//  PFPPayloadTypeKey.h
//  ProfileKeys
//
//  Created by Erik Berglund on 2016-08-23.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPConstants.h"
#import "PFPPayloadKey.h"
#import "PFPPayloadTypeKey.h"
#import <Foundation/Foundation.h>
@class PFPPayloadType;
@class PFPPlatform;
@class PFPSelection;

@interface PFPPayloadTypeKey : NSObject <PFPPayloadKey>

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
 @param  keyDict
 @param  payloadDict
 @return instancetype
 */
- (nullable instancetype)initWithKeyDict:(NSDictionary *_Nonnull)keyDict payloadType:(PFPPayloadType *_Nonnull)payloadType parentPayloadKey:(PFPPayloadTypeKey *_Nullable)parentPayloadKey;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Value
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

/*!
 @brief Returns if payload key is required supported in platform version.
 @discussion FIXME
 @param  version Platform version to check is supported.
 @param  platform Platform to check for support.
 @return BOOL
 */
- (BOOL)requiredForSelection:(PFPSelection *_Nullable)selection settings:(NSDictionary *_Nullable)settings inclusive:(BOOL)inclusive;

/*!
 @brief Returns YES if payload key is supported in platform version.
 @discussion FIXME
 @param  version Platform version to check is supported.
 @param  platform Platform to check for support.
 @return BOOL
 */
- (void)setValue:(id _Nullable)value;

- (BOOL)isRequired;

@end

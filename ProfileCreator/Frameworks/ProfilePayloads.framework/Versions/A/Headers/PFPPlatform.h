//
//  PFPPlatform.h
//  ProfileKeys
//
//  Created by Erik Berglund on 2016-08-25.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPConstants.h"
#import <Foundation/Foundation.h>
@class PFPPayloadType;

@interface PFPPlatform : NSObject

@property (nonatomic, readonly) PFPOSPlatform platforms; // Platforms this class represents. (No Default)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithPlatformArray:(NSArray<NSDictionary *> *_Nonnull)platformArray parent:(id _Nullable)parent;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (PFPOSPlatform)platformForString:(NSString *_Nonnull)platformString;
+ (NSString *_Nullable)minVersionForPlatform:(PFPOSPlatform)platform;
+ (NSString *_Nullable)maxVersionForPlatform:(PFPOSPlatform)platform;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSString *_Nullable)minVersionForPlatform:(PFPOSPlatform)platform;
- (NSString *_Nullable)maxVersionForPlatform:(PFPOSPlatform)platform;
- (BOOL)supportsPlatform:(PFPOSPlatform)platform;
- (BOOL)supportsVersion:(NSString *_Nonnull)version platform:(PFPOSPlatform)platform;
- (BOOL)supportsVersionsFrom:(NSString *_Nonnull)minVersion to:(NSString *_Nonnull)maxVersion platform:(PFPOSPlatform)platform inclusive:(BOOL)inclusive;

@end

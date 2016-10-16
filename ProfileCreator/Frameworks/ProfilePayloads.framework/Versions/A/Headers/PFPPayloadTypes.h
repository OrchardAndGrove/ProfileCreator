//
//  PFPPayloadTypes.h
//  ProfileKeys
//
//  Created by Erik Berglund on 2016-08-27.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFPPayloadType;
@class PFPPayloadTypeKey;

@interface PFPPayloadTypes : NSObject

@property (nonatomic, readonly, nullable) NSArray<NSString *> *domains;
@property (nonatomic, readonly, nullable) NSDictionary *domainsAndTitles;
@property (nonatomic, readonly, nullable) NSDictionary *payloadTypes;

- (nullable instancetype)init;

- (PFPPayloadTypeKey *_Nullable)payloadKeyForPayloadKeyPath:(NSString *_Nonnull)payloadKeyPath error:(NSError *_Nullable *_Nullable)error; // Only last key

@end

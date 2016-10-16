//
//  PFPPayloadCollection.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-14.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#pragma once

#import "PFPConstants.h"
#import <Foundation/Foundation.h>
@class PFPPlatform;
@class PFPPayloadCollectionKey;

@protocol PFPPayloadCollection <NSObject>

@required
@property (nonatomic, readonly) PFPViewModel viewModel;
@property (nonatomic, readonly) PFPCollectionSet collectionSet;
@property (nonatomic, readonly) PFPScope scope;
@property (nonatomic, readonly) PFPDistribution distribution;
@property (nonatomic, readonly, strong, nullable) PFPPlatform *platform;
@property (nonatomic, readonly, strong, nonnull) NSArray<PFPPayloadCollectionKey *> *subkeys;
@property (nonatomic, readonly, strong, nonnull) NSString *identifier;
@property (nonatomic, readonly, strong, nonnull) NSString *domain;
@property (nonatomic, readonly, strong, nonnull) NSString *title;
@property (nonatomic, readonly, strong, nonnull) NSString *descriptionString;
@property (nonatomic, readonly, strong, nonnull) NSImage *icon;
@property (nonatomic, readonly, strong, nullable) NSDictionary *payloadTypes;
@property (nonatomic, readonly, strong, nullable) NSString *payloadTypeString;
@property (nonatomic, readonly, strong, nullable) NSArray *payloadTypeConditions;

@end

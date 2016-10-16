//
//  PFPPayloadCollectionSet.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-16.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#pragma once

#import "PFPPayloadCollection.h"
#import "PFPViewTypeDelegate.h"
#import <Foundation/Foundation.h>

@protocol PFPPayloadCollectionSet <NSObject>

@property (nonatomic, readonly, nullable) NSArray<NSString *> *domains;
@property (nonatomic, readonly, nullable) NSArray<NSDictionary *> *placeholders;
@property (nonatomic, readonly, nullable) NSDictionary *payloadCollections;

- (nonnull instancetype)initWithViewModel:(PFPViewModel)viewModel delegate:(id<PFPViewTypeDelegate> _Nonnull)delegate;
- (id<PFPPayloadCollection> _Nullable)collectionWithIdentifier:(NSString *_Nonnull)identifier;

@end

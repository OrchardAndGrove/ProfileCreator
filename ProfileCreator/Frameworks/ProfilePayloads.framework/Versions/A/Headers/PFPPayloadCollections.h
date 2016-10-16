//
//  PFPPayloadCollections.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-14.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPPayloadCollection.h"
#import "PFPPayloadCollectionSet.h"
#import "PFPViewTypeDelegate.h"
#import <Foundation/Foundation.h>
@class PFPPayloadCollectionKey;

@interface PFPPayloadCollections : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithViewModel:(PFPViewModel)viewModel delegate:(id<PFPViewTypeDelegate> _Nullable)delegate;
- (id<PFPPayloadCollectionSet> _Nullable)setForCollection:(PFPCollectionSet)collectionSet;
- (id<PFPPayloadCollection> _Nullable)collectionWithIdentifier:(NSString *_Nonnull)collectionIdentifier;
- (void)updatePayloadSettings:(NSMutableDictionary *_Nullable)payloadSettings
           withUserChangeDict:(NSDictionary *_Nonnull)userChangeDict
         payloadCollectionKey:(PFPPayloadCollectionKey *_Nullable)payloadCollectionKey;
@end

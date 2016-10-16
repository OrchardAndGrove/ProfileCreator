//
//  PFPUtility.h
//  ProfileKeys
//
//  Created by Erik Berglund on 2016-08-26.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPConstants.h"
#import "PFPViewTypeTableView.h"
#import <Foundation/Foundation.h>
@class PFPPayloadType;
@class PFPPayloadCollectionKey;

@interface PFPUtility : NSObject

// -----------------------------------------------------------------------------
//  Distribution Methods
// -----------------------------------------------------------------------------
+ (PFPDistribution)distributionFromArray:(NSArray<NSString *> *_Nonnull)distributionArray payloadType:(PFPPayloadType *_Nullable)payloadType;
+ (PFPDistribution)distributionFromInteger:(NSUInteger)distributionInteger;
+ (NSString *_Nonnull)stringForDistribution:(PFPDistribution)distribution;

// -----------------------------------------------------------------------------
//  Scope Methods
// -----------------------------------------------------------------------------
+ (PFPScope)scopeFromArray:(NSArray<NSString *> *_Nonnull)scopeArray payloadType:(PFPPayloadType *_Nullable)payloadType;
+ (PFPScope)scopeFromInteger:(NSUInteger)scopeInteger;
+ (NSString *_Nonnull)stringForScope:(PFPScope)scope;

// -----------------------------------------------------------------------------
//  ValueType Methods
// -----------------------------------------------------------------------------
+ (PFPValueType)valueTypeForString:(NSString *_Nonnull)valueType;
+ (NSString *_Nonnull)stringForValueType:(PFPValueType)valueType;
+ (BOOL)verifyValue:(id _Nullable)value valueType:(PFPValueType)valueType;

// -----------------------------------------------------------------------------
//  ViewType Methods
// -----------------------------------------------------------------------------
+ (PFPViewType)viewTypeForString:(NSString *_Nonnull)viewType;
+ (NSString *_Nonnull)stringForViewType:(PFPViewType)viewType;
+ (NSDictionary *_Nonnull)viewTypeTableViewSettings:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey
                                              value:(id _Nonnull)value
                                           valueKey:(NSString *_Nonnull)valueKey
                                  notificationEvent:(NSString *_Nullable)notificationEvent
                                             sender:(id<PFPViewTypeTableView> _Nonnull)sender;

// -----------------------------------------------------------------------------
//  Other Methods
// -----------------------------------------------------------------------------
+ (NSDate *_Nonnull)dateAtMidnightForDate:(NSDate *_Nonnull)date;

@end

//
//  PFPPayloadExporter.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-10-04.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PFPPayloadCollections;

@interface PFPPayloadExporter : NSObject
- (nonnull instancetype)initWithPayloadCollections:(PFPPayloadCollections *_Nonnull)payloadCollections
                                    baseIdentifier:(NSString *_Nonnull)baseIdentifier
                                             scope:(PFPScope)scope
                                      distribution:(PFPDistribution)distribution
                                        supervised:(BOOL)supervised
                                       profileUUID:(NSString *_Nonnull)profileUUID
                                    profileVersion:(NSInteger)profileVersion;
- (NSMutableDictionary *_Nullable)profileRootFromPayloadConfiguration:(NSDictionary *_Nonnull)configurationDict
                                                      payloadSettings:(NSDictionary *_Nonnull)payloadSettings
                                                                error:(NSError *_Nullable *_Nullable)error;
- (NSArray *_Nullable)profilePayloadsFromPayloadSettings:(NSDictionary *_Nonnull)payloadSettings error:(NSError *_Nullable *_Nullable)error;
@end

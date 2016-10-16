//
//  PFPPayloadParser.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-29.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFPPayloadParser : NSObject

+ (nonnull instancetype)sharedParser;

- (NSArray *_Nonnull)viewArrayFromPayloadCollectionSubkeys:(NSArray *_Nonnull)subkeys settings:(NSDictionary *_Nonnull)settings modifiedIdentifiers:(NSArray *_Nullable)modifiedIdentifiers;

- (BOOL)shouldExportCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey payloadSettings:(NSDictionary *_Nullable)payloadSettings;
@end

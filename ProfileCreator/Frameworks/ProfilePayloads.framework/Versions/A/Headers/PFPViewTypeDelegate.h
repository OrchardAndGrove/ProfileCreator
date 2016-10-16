//
//  PFPViewTypeDelegate.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-28.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

@protocol PFPViewTypeDelegate <NSObject>

@required
- (void)userSettingsChanged:(NSDictionary *_Nonnull)changeDict payloadCollectionKey:(PFPPayloadCollectionKey *_Nullable)payloadCollectionKey sender:(id _Nonnull)sender;

@end

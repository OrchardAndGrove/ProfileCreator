//
//  PFPViewTypeTableView.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-23.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#pragma once

#import "PFPPayloadCollectionKey.h"
#import "PFPViewTypeDelegate.h"
#import <Cocoa/Cocoa.h>

@protocol PFPViewTypeTableView <NSObject>

@required

// Readwrite Properties
@property (nonatomic) NSInteger height;
@property (nonatomic, weak, nullable) id<PFPViewTypeDelegate> delegate;
@property (nonatomic, readonly) NSInteger row;

// Readonly Properties
@property (nonatomic, readonly, strong, nullable) NSTextField *textFieldTitle;
@property (nonatomic, readonly, strong, nullable) NSTextField *textFieldDescription;

// Instance Methods
- (nonnull instancetype)initWithPayloadCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey delegate:(id<PFPViewTypeDelegate> _Nullable)delegate;
- (void)updateSettings:(NSDictionary *_Nullable)settingsDict sender:(id _Nonnull)sender;

@optional
@end

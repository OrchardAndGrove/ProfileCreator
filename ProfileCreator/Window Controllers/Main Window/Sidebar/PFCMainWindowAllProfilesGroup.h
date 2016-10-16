//
//  PFCMainWindowAllProfilesGroup.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-09-11.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFCMainWindowOutlineViewChildProtocol.h"
#import "PFCMainWindowOutlineViewParentProtocol.h"
#import <Foundation/Foundation.h>

@interface PFCMainWindowAllProfilesGroup : NSObject <PFCMainWindowOutlineViewChild>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly) BOOL isEditable; // Allows adding and removing groups
@property (nonatomic, readonly) BOOL isEditing;
@property (nonatomic, readonly, nonnull) NSString *title;
@property (nonatomic, readonly, nonnull) NSString *identifier;
@property (nonatomic, readonly, nonnull) NSImage *icon;
@property (nonatomic, readonly, nonnull) NSMutableArray *children;
@property (nonatomic, nonnull) PFCMainWindowOutlineViewChildCellView *cellView;
@property (nonatomic, nonnull) NSMutableArray *profileIdentifiers;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithTitle:(NSString *_Nonnull)title identifier:(NSString *_Nullable)identifier parent:(id<PFCMainWindowOutlineViewParent> _Nonnull)parent;
- (void)addProfileIdentifiers:(NSArray *_Nonnull)identifiers;

@end

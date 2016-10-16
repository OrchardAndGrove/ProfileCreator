//
//  PFCMainWindowAllProfilesGroup.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-09-11.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFCAlert.h"
#import "PFCConstants.h"
#import "PFCMainWindowAllProfilesGroup.h"
#import "PFCMainWindowOutlineView.h"
#import "PFCMainWindowOutlineViewChildCellView.h"
#import "PFCProfileController.h"

@interface PFCMainWindowAllProfilesGroup ()
@property (nonatomic, readwrite, nonnull) NSString *title;
@property (nonatomic, readwrite, nonnull) NSString *identifier;
@property (nonatomic, readwrite, nonnull) NSImage *icon;
@property (nonatomic, readwrite) BOOL isEditable;
@property (nonatomic, readwrite) BOOL isEditing;
@property (nonatomic, strong, nullable) PFCAlert *alert;
@end

@implementation PFCMainWindowAllProfilesGroup

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nullable instancetype)initWithTitle:(NSString *_Nonnull)title identifier:(NSString *_Nullable)identifier parent:(id<PFCMainWindowOutlineViewParent> _Nonnull)parent {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _children = [[NSMutableArray alloc] init];
        _profileIdentifiers = [[NSMutableArray alloc] init];

        _title = title;
        _isEditable = NO;
        if (identifier.length == 0) {
            _identifier = [[NSUUID UUID] UUIDString];
        } else {
            _identifier = identifier;
        }

        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        _cellView = [[PFCMainWindowOutlineViewChildCellView alloc] initWithChild:self];

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(didRemoveProfiles:) name:PFCDidRemoveProfileNotification object:nil];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notifications
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCDidRemoveProfileNotification object:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)didRemoveProfiles:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Get profile identifiers for profiles that were removed
    // -------------------------------------------------------------------------
    NSDictionary *userInfo = [notification userInfo];
    NSArray *removedProfileIdentifiers = userInfo[PFCNotificationUserInfoProfileIdentifiers];

    // -------------------------------------------------------------------------
    //  Remove those from this group's profile identifiers
    // -------------------------------------------------------------------------
    NSMutableArray *profileIdentifiers = [self.profileIdentifiers mutableCopy];
    [profileIdentifiers removeObjectsInArray:removedProfileIdentifiers];
    [self setProfileIdentifiers:[profileIdentifiers copy]];

    // -------------------------------------------------------------------------
    //  Send notifications that we have removed them from the group
    // -------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCGroupDidRemoveProfileNotification object:self];
    if (self.profileIdentifiers.count == 0) {

        // ---------------------------------------------------------------------
        //  If no identifiers are left, send a notification that there are no profiles configured
        // ---------------------------------------------------------------------
        [[NSNotificationCenter defaultCenter] postNotificationName:PFCNoProfileConfiguredNotification object:self];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewChild Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)addProfileIdentifiers:(NSArray *_Nonnull)identifiers {
    NSMutableArray *profileIdentifiers = [self.profileIdentifiers mutableCopy];
    [identifiers enumerateObjectsUsingBlock:^(NSString *_Nonnull identifier, NSUInteger idx, BOOL *_Nonnull stop) {
      if (![profileIdentifiers containsObject:identifier]) {
          [profileIdentifiers addObject:identifier];
      }
    }];
    [self setProfileIdentifiers:[profileIdentifiers copy]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)removeProfileIdentifiersAtIndexes:(NSIndexSet *_Nonnull)indexSet {
    NSArray *profileIdentifiersToRemove = [self.profileIdentifiers objectsAtIndexes:indexSet];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCRemoveProfileNotification
                                                        object:self
                                                      userInfo:@{PFCNotificationUserInfoProfileIdentifiers : profileIdentifiersToRemove, PFCNotificationUserInfoIndexSet : indexSet}];
}

@end

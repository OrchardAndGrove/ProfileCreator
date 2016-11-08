//
//  PFCMainWindowSplitView.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PFCConstants.h"
#import "PFCMainWindowOutlineViewController.h"
#import "PFCMainWindowProfilePreviewController.h"
#import "PFCMainWindowSplitView.h"
#import "PFCMainWindowTableViewController.h"
#import "PFCMainWindowTableViewWelcome.h"
#import "PFCProfileController.h"
#import "NSSplitView+RestoreAutoSave.h"

@interface PFCMainWindowSplitView ()
@property (nonatomic, strong, nonnull) PFCMainWindowOutlineViewController *outlineViewController;
@property (nonatomic, strong, nonnull) PFCMainWindowTableViewController *tableViewController;
@property (nonatomic, strong, nonnull) PFCMainWindowProfilePreviewController *profilePreviewController;
@property (nonatomic, strong, nonnull) PFCMainWindowTableViewWelcome *tableViewWelcome;
@end

@implementation PFCMainWindowSplitView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Self
        // ---------------------------------------------------------------------
        [self setAutosaveName:@"MainWindowSplitView-AS"];
        [self setIdentifier:@"MainWindowSplitView-ID"];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setDividerStyle:NSSplitViewDividerStyleThin];
        [self setVertical:YES];
        [self setDelegate:self];
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(noProfileConfigured:) name:PFCNoProfileConfiguredNotification object:nil];
        [nc addObserver:self selector:@selector(didAddProfile:) name:PFCDidAddProfileNotification object:nil];

        // ---------------------------------------------------------------------
        //  Instantiate View Controllers
        // ---------------------------------------------------------------------
        _tableViewWelcome = [[PFCMainWindowTableViewWelcome alloc] init];
        _tableViewController = [[PFCMainWindowTableViewController alloc] init];
        _outlineViewController = [[PFCMainWindowOutlineViewController alloc] initWithSelectionDelegate:_tableViewController];
        _profilePreviewController = [[PFCMainWindowProfilePreviewController alloc] init];

        // ---------------------------------------------------------------------
        //  Setup views in splitview
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        [self setupSplitViewProfilePreview:constraints];
        [self setupSplitViewProfileList:constraints];
        [self setupSplitViewSidebar:constraints];
        [self setupSplitViewWelcome:constraints];

        // ---------------------------------------------------------------------
        //  Add views to splitview
        // ---------------------------------------------------------------------
        [self addSubview:_outlineViewController.scrollView];
        [self setHoldingPriority:(NSLayoutPriorityDefaultLow + 1) forSubviewAtIndex:0];
        [self addSubview:self.tableViewController.scrollView];
        [self setHoldingPriority:NSLayoutPriorityDefaultLow forSubviewAtIndex:1];
        [self addSubview:self.profilePreviewController.view];
        [self setHoldingPriority:(NSLayoutPriorityDefaultLow - 1) forSubviewAtIndex:2];

        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:constraints];

        // ---------------------------------------------------------------------
        //  If no profile identifiers are loaded, show welcome view
        // ---------------------------------------------------------------------
        if ([[[PFCProfileController sharedController] profileIdentifiers] count] == 0) {
            [self noProfileConfigured:nil];
        }
        
        // ---------------------------------------------------------------------
        //  Restore AutoSaved positions, as this isn't done automatically
        // ---------------------------------------------------------------------
        [self pfc_restoreAutosavedPositions];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notification
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCNoProfileConfiguredNotification object:nil];
    [nc removeObserver:self name:PFCDidAddProfileNotification object:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setupSplitViewSidebar:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Add constraints for Group Outline View
    // -------------------------------------------------------------------------

    // Min Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_outlineViewController.scrollView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:150]];

    // Max Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_outlineViewController.scrollView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:300]];
}

- (void)setupSplitViewProfileList:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Add constraints for Profile List View
    // -------------------------------------------------------------------------

    // Min Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_tableViewController.scrollView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:150]];

    // Max Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_tableViewController.scrollView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:300]];
}

- (void)setupSplitViewProfilePreview:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Add constraints for Profile Preview View
    // -------------------------------------------------------------------------

    // Min Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_profilePreviewController.view
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:260]];
}

- (void)setupSplitViewWelcome:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Add constraints for Welcome View
    // -------------------------------------------------------------------------

    // Minimum Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_tableViewWelcome.view
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:400]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)noProfileConfigured:(NSNotification *)notification {
    if (![self.subviews containsObject:self.tableViewWelcome.view]) {
        [self.tableViewController.scrollView removeFromSuperview];
        [self.profilePreviewController.view removeFromSuperview];
        [self addSubview:self.tableViewWelcome.view positioned:NSWindowAbove relativeTo:self.outlineViewController.scrollView];
        [self setHoldingPriority:NSLayoutPriorityDefaultLow forSubviewAtIndex:1];
    }
}

- (void)didAddProfile:(NSNotification *)notification {
    if (![self.subviews containsObject:self.tableViewController.scrollView]) {
        [self.tableViewWelcome.view removeFromSuperview];
        [self addSubview:self.tableViewController.scrollView];
        [self setHoldingPriority:NSLayoutPriorityDefaultLow forSubviewAtIndex:1];
        [self addSubview:self.profilePreviewController.view];
        [self setHoldingPriority:(NSLayoutPriorityDefaultLow - 1) forSubviewAtIndex:2];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSSPlitViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {

    // -------------------------------------------------------------------------
    //  Allow left view (SIDEBAR) to be collapsed
    // -------------------------------------------------------------------------
    if (subview == self.subviews.firstObject && [self.subviews containsObject:self.tableViewController.scrollView]) {
        return YES;
    }
    return NO;
} // splitView:canCollapseSubview

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {

    // -------------------------------------------------------------------------
    //  Hide left divider if left view is collapsed
    // -------------------------------------------------------------------------
    if (dividerIndex == 0) {
        return [self isSubviewCollapsed:self.subviews[0]]; //
    }
    return NO;
} // splitView:shouldHideDividerAtIndex

/*
 ///////////////////////////////////////////////////////////////////////////////
 ////////////                        WARNING                        ////////////
 ///////////////////////////////////////////////////////////////////////////////

  Don't use any of the following NSSPlitView delegate methods as they don't
  work with AutoLayout.

     splitView:constrainMinCoordinate:ofSubviewAt:
     splitView:constrainMaxCoordinate:ofSubviewAt:
     splitView:resizeSubviewsWithOldSize:
     splitView:shouldAdjustSizeOfSubview:

     https://developer.apple.com/library/mac/releasenotes/AppKit/RN-AppKitOlderNotes/#10_8AutoLayout
 */

@end

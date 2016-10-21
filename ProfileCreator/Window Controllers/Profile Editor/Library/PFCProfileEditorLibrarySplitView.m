//
//  PFCProfileEditorLibrarySplitView.m
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

#import "PFCProfileEditor.h"
#import "PFCProfileEditorLibraryFilter.h"
#import "PFCProfileEditorLibraryMenu.h"
#import "PFCProfileEditorLibraryNoPayloads.h"
#import "PFCProfileEditorLibraryPayloads.h"
#import "PFCProfileEditorLibrarySplitView.h"
#import "PFCProfileEditorSettings.h"
#import "PFCProfileEditorSplitView.h"

@interface PFCProfileEditorLibrarySplitView ()

@property (nonatomic, strong, nonnull) PFCProfileEditorLibraryMenu *libraryMenu;
@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorLibraryPayloads *libraryPayloads;
@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorLibraryNoPayloads *libraryNoPayloads;
@property (nonatomic, weak, nullable) PFCProfileEditor *profileEditor;
@property (nonatomic, weak, nullable) PFCProfileEditorSplitView *profileEditorSplitView;
@property (nonatomic, strong, nonnull) NSView *middleView;
@property (nonatomic, strong, nonnull) NSArray *constraintsLibraryMenu;
@property (nonatomic, strong, nonnull) NSArray *constraintsLibraryMenuFooter;

@property (nonatomic, strong, nonnull) NSArray *constraintsLibraryPayloads;
@property (nonatomic, strong, nonnull) NSArray *constraintsLibraryNoPayloads;

@end

@implementation PFCProfileEditorLibrarySplitView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfileEditor:(PFCProfileEditor *_Nonnull)profileEditor
                       profileEditorSplitView:(PFCProfileEditorSplitView *_Nonnull)profileEditorSplitView
                            selectionDelegate:(id _Nonnull)selectionDelegate {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profileEditor = profileEditor;
        _profileEditorSplitView = profileEditorSplitView;
        _libraryPayloads = [[PFCProfileEditorLibraryPayloads alloc] initWithProfileEditor:profileEditor profileEditorLibrarySplitView:self selectionDelegate:selectionDelegate];
        _libraryMenu = [[PFCProfileEditorLibraryMenu alloc] initWithLibraryPayloads:_libraryPayloads];
        _libraryNoPayloads = [[PFCProfileEditorLibraryNoPayloads alloc] initWithDraggingDelegate:_libraryPayloads];

        // ---------------------------------------------------------------------
        //  Setup Self (SplitView)
        // ---------------------------------------------------------------------
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setDividerStyle:NSSplitViewDividerStyleThin];
        [self setVertical:NO];
        [self setDelegate:self];

        NSMutableArray *constraints = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Setup views in splitview
        // ---------------------------------------------------------------------
        [self setupSplitViewProfilePayloads:constraints];
        [self setupSplitViewLibraryPayloads:constraints];

        // ---------------------------------------------------------------------
        //  Add views to splitview
        // ---------------------------------------------------------------------
        [self addSubview:_libraryPayloads.scrollViewProfilePayloads];
        [self setHoldingPriority:NSLayoutPriorityDefaultLow forSubviewAtIndex:0];
        [self addSubview:_middleView];
        [self setHoldingPriority:NSLayoutPriorityDefaultLow forSubviewAtIndex:1];

        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:constraints];

        // ---------------------------------------------------------------------
        //  If library payloads is empty, need to show "No Profiles" view
        // ---------------------------------------------------------------------
        if (self.libraryPayloads.libraryPayloads.count == 0) {
            [self showLibraryNoProfiles:YES];
        }
    }
    return self;
}

- (void)setupSplitViewProfilePayloads:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Setup constraints for Profile Payloads
    // -------------------------------------------------------------------------
    // Height
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_libraryPayloads.scrollViewProfilePayloads
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:96]];
}

- (void)setupSplitViewLibraryPayloads:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Create middle view (Library Payloads)
    // -------------------------------------------------------------------------
    _middleView = [[NSView alloc] init];
    [_middleView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // -------------------------------------------------------------------------
    //  Add Library Menu pinned to the top of middle subview
    // -------------------------------------------------------------------------
    [_middleView addSubview:_libraryMenu.stackView];

    // -------------------------------------------------------------------------
    //  Setup constraints for Library Menu
    // -------------------------------------------------------------------------
    NSMutableArray *constraintsLibraryMenu = [[NSMutableArray alloc] init];

    // Library Menu - Height
    [constraintsLibraryMenu addObject:[NSLayoutConstraint constraintWithItem:_libraryMenu.stackView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:27]];

    // Library Menu - Top
    [constraintsLibraryMenu addObject:[NSLayoutConstraint constraintWithItem:_libraryMenu.stackView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_middleView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0]];

    // Library Menu - Leading
    [constraintsLibraryMenu addObject:[NSLayoutConstraint constraintWithItem:_libraryMenu.stackView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_middleView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0
                                                                    constant:0]];

    // Library Menu - Trailing
    [constraintsLibraryMenu addObject:[NSLayoutConstraint constraintWithItem:_libraryMenu.stackView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_middleView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1.0
                                                                    constant:0]];

    // -------------------------------------------------------------------------
    //  Add Horizontal line between Library Payloads and Library Footer
    // -------------------------------------------------------------------------
    NSBox *line = [[NSBox alloc] init];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
    [line setBoxType:NSBoxSeparator];
    [_middleView addSubview:line];

    // -------------------------------------------------------------------------
    //  Setup constraints for separator line
    // -------------------------------------------------------------------------
    // Line - Top
    [constraintsLibraryMenu addObject:[NSLayoutConstraint constraintWithItem:_libraryMenu.stackView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:line
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0]];

    // Line - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:line
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_middleView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Line - Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:line
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_middleView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];

    // -------------------------------------------------------------------------
    //  Save constraints for Library Menu
    // -------------------------------------------------------------------------
    [constraints addObjectsFromArray:constraintsLibraryMenu];
    _constraintsLibraryMenu = [constraintsLibraryMenu copy];

    // -------------------------------------------------------------------------
    //  Add Library Payloads to fill the rest of the subview
    // -------------------------------------------------------------------------
    [_middleView addSubview:_libraryPayloads.scrollViewLibraryPayloads];

    // -------------------------------------------------------------------------
    //  Setup constraints for Library Payloads
    // -------------------------------------------------------------------------
    NSMutableArray *constraintsLibraryPayloads = [[NSMutableArray alloc] init];

    // Library Payloads - Top
    [constraintsLibraryPayloads addObject:[NSLayoutConstraint constraintWithItem:line
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_libraryPayloads.scrollViewLibraryPayloads
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:0]];

    // Library Payloads - Height
    [constraintsLibraryPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryPayloads.scrollViewLibraryPayloads
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:80]];

    // Library Payloads - Leading
    [constraintsLibraryPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryPayloads.scrollViewLibraryPayloads
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_middleView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.0
                                                                        constant:0]];

    // Library Payloads - Trailing
    [constraintsLibraryPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryPayloads.scrollViewLibraryPayloads
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_middleView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0
                                                                        constant:0]];

    // Library Payloads - Bottom
    [constraintsLibraryPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryPayloads.scrollViewLibraryPayloads
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_middleView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:0]];

    // -------------------------------------------------------------------------
    //  Save constraints for Library Payloads
    // -------------------------------------------------------------------------
    [constraints addObjectsFromArray:constraintsLibraryPayloads];
    _constraintsLibraryPayloads = constraintsLibraryPayloads;

    // -------------------------------------------------------------------------
    //  Setup constraints for Library NoPayloads
    // -------------------------------------------------------------------------
    NSMutableArray *constraintsLibraryNoPayloads = [[NSMutableArray alloc] init];

    // Library NoPayloads - Top
    [constraintsLibraryNoPayloads addObject:[NSLayoutConstraint constraintWithItem:line
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_libraryNoPayloads.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0]];

    // Library NoPayloads - Height
    [constraintsLibraryNoPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryNoPayloads.view
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:80]];

    // Library NoPayloads - Leading
    [constraintsLibraryNoPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryNoPayloads.view
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_middleView
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                          constant:0]];

    // Library NoPayloads - Trailing
    [constraintsLibraryNoPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryNoPayloads.view
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_middleView
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                          constant:0]];

    // Library NoPayloads - Bottom
    [constraintsLibraryNoPayloads addObject:[NSLayoutConstraint constraintWithItem:_libraryNoPayloads.view
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_middleView
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0]];

    // -------------------------------------------------------------------------
    //  Save constraints for Library Payloads
    // -------------------------------------------------------------------------
    _constraintsLibraryNoPayloads = constraintsLibraryNoPayloads;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSSPlitView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {

    // -------------------------------------------------------------------------
    //  Allow Library Payloads to be collapsed
    // -------------------------------------------------------------------------
    if (subview == self.subviews.lastObject) {
        return YES;
    }
    return NO;
} // splitView:canCollapseSubview

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    if (!self.splitViewLibraryCollapsed && [self isSubviewCollapsed:self.subviews[1]]) {
        [self showLibrarySearch:NO];
    } else if (self.splitViewLibraryCollapsed && ![self isSubviewCollapsed:self.subviews[1]]) {
        [self showLibrarySearch:YES];
    }
} // splitViewDidResizeSubviews

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showLibraryNoProfiles:(BOOL)show {
    if (show) {

        // -------------------------------------------------------------------------
        //  Update internal bool to easier query what view is currently shown
        //  FIXME - A check like that seems weak, and should probably check directly what view is currently in splitview
        // -------------------------------------------------------------------------
        [self setSplitViewLibraryNoPayloads:YES];

        // -------------------------------------------------------------------------
        //  Remove old view and add new view
        // -------------------------------------------------------------------------
        [self.libraryPayloads.scrollViewLibraryPayloads removeFromSuperview];
        [self.middleView addSubview:self.libraryNoPayloads.view];

        // -------------------------------------------------------------------------
        //  Activate new view saved Layout Constraints
        // -------------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:self.constraintsLibraryNoPayloads];
    } else {

        // -------------------------------------------------------------------------
        //  Update internal bool to easier query what view is currently shown
        //  FIXME - A check like that seems weak, and should probably check directly what view is currently in splitview
        // -------------------------------------------------------------------------
        [self setSplitViewLibraryNoPayloads:NO];

        // -------------------------------------------------------------------------
        //  Remove old view and add new view
        // -------------------------------------------------------------------------
        [self.libraryNoPayloads.view removeFromSuperview];
        [self.middleView addSubview:self.libraryPayloads.scrollViewLibraryPayloads];

        // -------------------------------------------------------------------------
        //  Activate new view saved Layout Constraints
        // -------------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:self.constraintsLibraryPayloads];
    }
}

- (void)uncollapseLibraryView {
    [self showLibrarySearch:YES];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showLibrarySearch:(BOOL)show {
    if (show) {

        // -------------------------------------------------------------------------
        //  Update internal bool to easier query what view is currently shown
        //  FIXME - A check like that seems weak, and should probably check directly what view is currently in splitview
        // -------------------------------------------------------------------------
        [self setSplitViewLibraryCollapsed:NO];

        // -------------------------------------------------------------------------
        //  Tell editor split view to remove Library Menu
        // -------------------------------------------------------------------------
        [self.profileEditorSplitView showLibraryMenu:self.libraryMenu.stackView inSearchView:NO];

        // -------------------------------------------------------------------------
        //  Insert Library Meny and activate saved Constraints
        // -------------------------------------------------------------------------
        [self.middleView addSubview:self.libraryMenu.stackView];
        [NSLayoutConstraint activateConstraints:self.constraintsLibraryMenu];

        // -------------------------------------------------------------------------
        //  Calculate the height and programmatically set the Library Profiles height when uncollapsing
        // -------------------------------------------------------------------------
        NSInteger libraryViewHeight = (self.libraryPayloads.scrollViewProfilePayloads.contentSize.height - 108);
        [self setPosition:libraryViewHeight ofDividerAtIndex:0];
    } else {

        // -------------------------------------------------------------------------
        //  Update internal bool to easier query what view is currently shown
        //  FIXME - A check like that seems weak, and should probably check directly what view is currently in splitview
        // -------------------------------------------------------------------------
        [self setSplitViewLibraryCollapsed:YES];

        // -------------------------------------------------------------------------
        //  Remove Library Meny
        // -------------------------------------------------------------------------
        [self.libraryMenu.stackView removeFromSuperview];

        // -------------------------------------------------------------------------
        //  Tell editor split view to add Library Menu in place of the Filter View
        // -------------------------------------------------------------------------
        [self.profileEditorSplitView showLibraryMenu:self.libraryMenu.stackView inSearchView:YES];
    }
}

@end

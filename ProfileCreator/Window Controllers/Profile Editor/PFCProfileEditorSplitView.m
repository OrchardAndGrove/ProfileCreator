//
//  PFCProfileEditorSplitView.m
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
#import "PFCProfileEditorFooter.h"
#import "PFCProfileEditorLibraryFilter.h"
#import "PFCProfileEditorLibraryPayloads.h"
#import "PFCProfileEditorLibrarySplitView.h"
#import "PFCProfileEditorSettings.h"
#import "PFCProfileEditorSettingsView.h"
#import "PFCProfileEditorSplitView.h"
#import "PFCProfileEditorTableViewController.h"

NSInteger const PFCWindowTitleBarHeight = 38;
NSInteger const PFCTitleViewHeight = 39;

@interface PFCProfileEditorSplitView ()

@property (nonatomic, strong, nonnull) PFCProfileEditorFooter *editorFooter;
@property (nonatomic, strong, nonnull) PFCProfileEditorLibraryFilter *libraryFilter;
@property (nonatomic, strong, nonnull) NSBox *libraryFilterTopLine;

@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorLibrarySplitView *librarySplitView;
@property (nonatomic, strong, readwrite, nonnull) PFCProfileEditorTableViewController *tableViewController;
@property (nonatomic, weak, nullable) PFCProfileEditorSettingsView *settingsView;
@property (nonatomic, weak, nullable) PFCProfileEditor *profileEditor;

@property (nonatomic, strong, nonnull) NSView *libraryView;
@property (nonatomic, strong, nonnull) NSView *editorView;

@property (nonatomic, strong, nonnull) NSArray *constraintsTableViewController;
@property (nonatomic, strong, nonnull) NSArray *constraintsSettingsView;
@property (nonatomic, strong, nonnull) NSArray *constraintsLibraryFilterView;
@property (nonatomic, strong, nonnull) NSArray *constraintsLibraryMenuView;

@end

@implementation PFCProfileEditorSplitView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (instancetype)initWithProfileEditor:(PFCProfileEditor *_Nonnull)profileEditor {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Self (SplitView)
        // ---------------------------------------------------------------------
        [self setIdentifier:@"ProfileEditorSplitView-ID"];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setDividerStyle:NSSplitViewDividerStyleThin];
        [self setVertical:YES];
        
        // ---------------------------------------------------------------------
        //  Register for notifications
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(showSettingsView:) name:PFCSelectProfileSettingsNotification object:nil];
        
        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profileEditor = profileEditor;
        _settingsView = _profileEditor.settings.settingsView;
        _editorFooter = [[PFCProfileEditorFooter alloc] initWithProfileEditor:profileEditor];
        _tableViewController = [[PFCProfileEditorTableViewController alloc] initWithProfile:_profileEditor.profile];
        _librarySplitView = [[PFCProfileEditorLibrarySplitView alloc] initWithProfileEditor:_profileEditor profileEditorSplitView:self selectionDelegate:_tableViewController];
        _libraryFilter = [[PFCProfileEditorLibraryFilter alloc] init];

        // ---------------------------------------------------------------------
        //  Setup views in splitview
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        [self setupSplitViewEditor:constraints];
        [self setupSplitViewLibrary:constraints];

        // ---------------------------------------------------------------------
        //  Add views to splitview
        // ---------------------------------------------------------------------
        // NOTE - This order is important, else they will appear flipped.
        // This should probably be a checked for current language direction but currently isn't
        [self addSubview:_libraryView];
        [self setHoldingPriority:(NSLayoutPriorityDefaultLow + 1) forSubviewAtIndex:0];
        [self addSubview:_editorView];
        [self setHoldingPriority:NSLayoutPriorityDefaultLow forSubviewAtIndex:1];

        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

- (void)setupSplitViewEditor:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Create editor view
    // -------------------------------------------------------------------------
    _editorView = [[NSView alloc] init];
    [_editorView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Editor View - Width Min
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_editorView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:550]];

    // -------------------------------------------------------------------------
    //  Add Editor TableView pinned to the top of editor view
    // -------------------------------------------------------------------------
    [_editorView addSubview:_tableViewController.scrollView];

    // -------------------------------------------------------------------------
    //  Setup constraints for Editor TableView
    // -------------------------------------------------------------------------
    NSMutableArray *constraintsTableViewController = [[NSMutableArray alloc] init];

    // Editor TableView - Top
    [constraintsTableViewController addObject:[NSLayoutConstraint constraintWithItem:_tableViewController.scrollView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_editorView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:PFCWindowTitleBarHeight]];

    // Editor TableView - Leading
    [constraintsTableViewController addObject:[NSLayoutConstraint constraintWithItem:_tableViewController.scrollView
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_editorView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.0
                                                                            constant:0]];

    // Editor TableView - Trailing
    [constraintsTableViewController addObject:[NSLayoutConstraint constraintWithItem:_tableViewController.scrollView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_editorView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1.0
                                                                            constant:0]];

    // -------------------------------------------------------------------------
    //  Setup constraints for Settings View
    // -------------------------------------------------------------------------
    NSMutableArray *constraintsSettingsView = [[NSMutableArray alloc] init];

    // Settings View - Width
    [constraintsSettingsView addObject:[NSLayoutConstraint constraintWithItem:_settingsView.view
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:500]];

    // Settings View - Top
    [constraintsSettingsView addObject:[NSLayoutConstraint constraintWithItem:_settingsView.view
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_editorView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:PFCWindowTitleBarHeight]];

    // Settings View - Center Vertically
    [constraintsSettingsView addObject:[NSLayoutConstraint constraintWithItem:_editorView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_settingsView.view
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:2]];

    // -------------------------------------------------------------------------
    //  Add Horizontal line between table view and footer
    // -------------------------------------------------------------------------
    NSBox *line = [[NSBox alloc] init];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
    [line setBoxType:NSBoxSeparator];
    [_editorView addSubview:line];

    // -------------------------------------------------------------------------
    //  Setup constraints for separator line
    // -------------------------------------------------------------------------
    // Line - Top (Editor TableView)
    [constraintsTableViewController addObject:[NSLayoutConstraint constraintWithItem:_tableViewController.scrollView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:line
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0]];
    // Line - Top (Settings View)
    [constraintsSettingsView addObject:[NSLayoutConstraint constraintWithItem:_settingsView.view
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
                                                           toItem:_editorView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Line - Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:line
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_editorView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];

    // -------------------------------------------------------------------------
    //  Save constraints for Editor TableView
    // -------------------------------------------------------------------------
    _constraintsTableViewController = [constraintsTableViewController copy];
    [constraints addObjectsFromArray:_constraintsTableViewController];

    // -------------------------------------------------------------------------
    //  Save constraints for Settings View
    // -------------------------------------------------------------------------
    _constraintsSettingsView = [constraintsSettingsView copy];

    // -------------------------------------------------------------------------
    //  Add Editor Footer pinned to the bottom of editor view
    // -------------------------------------------------------------------------
    [_editorView addSubview:_editorFooter.view];

    // -------------------------------------------------------------------------
    //  Setup constraints for Editor Footer
    // -------------------------------------------------------------------------
    // Editor Footer - Height
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_editorFooter.view
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:27]];

    // Editor Footer - Top
    [constraints addObject:[NSLayoutConstraint constraintWithItem:line
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_editorFooter.view
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0]];

    // Editor Footer - Bottom
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_editorFooter.view
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_editorView
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0]];

    // Editor Footer - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_editorFooter.view
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_editorView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Editor Footer - Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_editorFooter.view
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_editorView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];
}

- (void)setupSplitViewLibrary:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Create library view
    // -------------------------------------------------------------------------
    _libraryView = [[NSView alloc] init];
    [_libraryView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // -------------------------------------------------------------------------
    //  Setup constraints for Library View
    // -------------------------------------------------------------------------
    // Library View - Width Min
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_libraryView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:150]];

    // Library View - Width Max
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_libraryView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:300]];

    // -------------------------------------------------------------------------
    //  Add Library SplitView pinned to the top of library view
    // -------------------------------------------------------------------------
    [_libraryView addSubview:_librarySplitView];

    // -------------------------------------------------------------------------
    //  Setup constraints for Library SplitView
    // -------------------------------------------------------------------------
    // Library SplitView - Top
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_librarySplitView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_libraryView
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:PFCWindowTitleBarHeight]];

    // Library SplitView - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_librarySplitView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_libraryView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Library SplitView - Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_librarySplitView
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_libraryView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];

    // -------------------------------------------------------------------------
    //  Add Horizontal line between table view and footer
    // -------------------------------------------------------------------------
    _libraryFilterTopLine = [[NSBox alloc] init];
    [_libraryFilterTopLine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_libraryFilterTopLine setBoxType:NSBoxSeparator];
    [_libraryView addSubview:_libraryFilterTopLine];

    // -------------------------------------------------------------------------
    //  Setup constraints for Library Filter
    // -------------------------------------------------------------------------
    NSMutableArray *constraintsFilterView = [[NSMutableArray alloc] init];

    // Line - Top
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_librarySplitView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryFilterTopLine
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0]];

    // Line - Leading
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilterTopLine
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:0]];

    // Line - Trailing
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilterTopLine
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryView
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0]];

    // -------------------------------------------------------------------------
    //  Add Library Filter pinned to the bottom of library view
    // -------------------------------------------------------------------------
    [_libraryView addSubview:_libraryFilter.view];

    // Library Filter - Height
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilter.view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:27]];

    // Library Filter - Top
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilterTopLine
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryFilter.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0]];

    // Library Filter - Leading
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilter.view
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:0]];

    // Library Filter - Trailing
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilter.view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryView
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0]];

    // Library Filter - Bottom
    [constraintsFilterView addObject:[NSLayoutConstraint constraintWithItem:_libraryFilter.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_libraryView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0]];

    // -------------------------------------------------------------------------
    //  Save constraints for Library Filter
    // -------------------------------------------------------------------------
    [constraints addObjectsFromArray:constraintsFilterView];
    _constraintsLibraryFilterView = constraintsFilterView;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showSettingsView:(NSNotification *_Nullable)notification {
    if (notification.object == self.profileEditor && ![self.editorView.subviews containsObject:self.settingsView.view]) {
        [self.tableViewController.scrollView removeFromSuperview];
        [self.editorView addSubview:self.settingsView.view];

        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        [NSLayoutConstraint activateConstraints:self.constraintsSettingsView];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showEditorViewWithCollection:(id<PFPPayloadCollection> _Nullable)collection {
    [self.settingsView.view removeFromSuperview];
    [self.editorView addSubview:self.tableViewController.scrollView];

    // ---------------------------------------------------------------------
    //  Activate layout constraints
    // ---------------------------------------------------------------------
    [NSLayoutConstraint activateConstraints:self.constraintsTableViewController];
}

- (void)showLibraryMenu:(NSView *_Nullable)view inSearchView:(BOOL)show {
    if (show) {
        [self.libraryFilter.view removeFromSuperview];
        [self.libraryFilterTopLine removeFromSuperview];
        [self.libraryView addSubview:view];
        if (self.constraintsLibraryMenuView.count == 0) {
            [self setupLibraryMenuInFilterView:view];
            [NSLayoutConstraint activateConstraints:self.constraintsLibraryMenuView];
        } else {
            [NSLayoutConstraint activateConstraints:self.constraintsLibraryMenuView];
        }
    } else {
        [view removeFromSuperview];
        [self.libraryView addSubview:self.libraryFilter.view];
        [self.libraryView addSubview:self.libraryFilterTopLine];
        [NSLayoutConstraint activateConstraints:self.constraintsLibraryFilterView];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setupLibraryMenuInFilterView:(NSView *_Nonnull)menuView {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];

    // Library Filter - Height
    [constraints addObject:[NSLayoutConstraint constraintWithItem:menuView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:27]];

    // Library Filter - Top
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.librarySplitView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:menuView
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0]];

    // Library Filter - Leading
    [constraints addObject:[NSLayoutConstraint constraintWithItem:menuView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.libraryView
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0]];

    // Library Filter - Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:menuView
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.libraryView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0]];

    // Library Filter - Bottom
    [constraints addObject:[NSLayoutConstraint constraintWithItem:menuView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.libraryView
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0]];

    [self setConstraintsLibraryMenuView:[constraints copy]];
}

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

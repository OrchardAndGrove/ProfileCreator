//
//  PFCMainWindow.h
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

#import "PFCMainWindow.h"
#import "PFCMainWindowSplitView.h"
#import "PFCMainWindowToolbarItemAdd.h"
#import "PFCMainWindowToolbarItemExport.h"

@interface PFCMainWindow ()

@property (nonatomic, strong, nonnull) NSToolbar *toolbar;
@property (nonatomic, strong, nonnull) NSArray *toolbarItemIdentifiers;

@property (nonatomic, strong, nonnull) PFCMainWindowSplitView *splitView;
@property (nonatomic, strong, nonnull) PFCMainWindowToolbarItemAdd *toolbarItemAdd;
@property (nonatomic, strong, nonnull) PFCMainWindowToolbarItemExport *toolbarItemExport;
@end

@implementation PFCMainWindow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup main window
        // ---------------------------------------------------------------------
        NSRect frame = NSMakeRect(0, 0, 750, 550);
        NSWindow *mainWindow = [[NSWindow alloc]
            initWithContentRect:frame
                      styleMask:NSFullSizeContentViewWindowMask | NSTitledWindowMask | NSUnifiedTitleAndToolbarWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                        backing:NSBackingStoreBuffered
                          defer:NO];

        [mainWindow setTitleVisibility:NSWindowTitleHidden];
        [mainWindow setReleasedWhenClosed:NO];
        [mainWindow setRestorable:YES];
        [mainWindow setIdentifier:@"ProfileCreatorMainWindow"];
        [mainWindow setFrameAutosaveName:@"ProfileCreatorMainWindow"];
        [mainWindow setContentMinSize:NSMakeSize(600, 400)];
        [mainWindow center];

        // ---------------------------------------------------------------------
        //  Setup splitview
        // ---------------------------------------------------------------------
        _splitView = [[PFCMainWindowSplitView alloc] init];

        // ---------------------------------------------------------------------
        // Add splitview to window
        // ---------------------------------------------------------------------
        [mainWindow setContentView:_splitView];

        // ---------------------------------------------------------------------
        //  Setup toolbar
        // ---------------------------------------------------------------------
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainWindowToolbar"];
        [toolbar setVisible:YES];
        [toolbar setShowsBaselineSeparator:YES];
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:YES];
        [toolbar setSizeMode:NSToolbarSizeModeRegular];
        [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
        [toolbar setDelegate:self];

        _toolbar = toolbar;

        // ---------------------------------------------------------------------
        //  Setup toolbar items
        // ---------------------------------------------------------------------
        _toolbarItemIdentifiers = @[ PFCMainWindowToolbarItemIdentifierAdd, PFCMainWindowToolbarItemIdentifierExport, NSToolbarFlexibleSpaceItemIdentifier ];

        // ---------------------------------------------------------------------
        // Add toolbar to window
        // ---------------------------------------------------------------------
        [mainWindow setToolbar:_toolbar];

        self.window = mainWindow;
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSToolbarDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarItemIdentifiers;
} // toolbarAllowedItemIdentifiers

- (NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarItemIdentifiers;
} // toolbarDefaultItemIdentifiers

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    id toolbarItem = [self toolbarItemWithIdentifier:itemIdentifier];
    if (toolbarItem != nil) {
        return [toolbarItem toolbarItem];
    } else {
        return nil;
    }
} // toolbar:itemForItemIdentifier

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)toolbarItemWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:PFCMainWindowToolbarItemIdentifierAdd]) {
        if (!self.toolbarItemAdd) {
            [self setToolbarItemAdd:[[PFCMainWindowToolbarItemAdd alloc] init]];
        }
        return self.toolbarItemAdd;
    } else if ([identifier isEqualToString:PFCMainWindowToolbarItemIdentifierExport]) {
        if (!self.toolbarItemExport) {
            [self setToolbarItemExport:[[PFCMainWindowToolbarItemExport alloc] init]];
        }
        return self.toolbarItemExport;
    }
    return nil;
} // toolbarItemWithIdentifier

@end

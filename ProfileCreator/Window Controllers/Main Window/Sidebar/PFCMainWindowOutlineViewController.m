//
//  PFCMainWindowOutlineViewController.m
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

#import "PFCAlert.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCMainWindowAllProfiles.h"
#import "PFCMainWindowAllProfilesGroup.h"
#import "PFCMainWindowLibrary.h"
#import "PFCMainWindowOutlineView.h"
#import "PFCMainWindowOutlineViewChildProtocol.h"
#import "PFCMainWindowOutlineViewController.h"
#import "PFCMainWindowOutlineViewProtocol.h"
#import "PFCMainWindowTableViewController.h"

NSString *const PFCMainWindowOutlineViewTableColumnIdentifier = @"TableColumn";

@interface PFCMainWindowOutlineViewController ()

@property (nonatomic, nonnull) NSMutableArray *parents;
@property (nonatomic, nonnull) NSOutlineView *outlineView;
@property (nonatomic, readwrite, nonnull) NSScrollView *scrollView;
@property (nonatomic, weak, nullable) id selectionDelegate;
@property (nonatomic, nullable) id selectedItem;
@property (nonatomic, weak, nullable) PFCMainWindowAllProfilesGroup *allProfilesGroup;

@end

@implementation PFCMainWindowOutlineViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithSelectionDelegate:(id _Nonnull)selectionDelegate {
    self = [super init];
    if (self != nil) {

        _selectionDelegate = selectionDelegate;

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(didAddGroup:) name:PFCDidAddGroupNotification object:nil];
        [nc addObserver:self selector:@selector(didAddProfile:) name:PFCDidAddProfileNotification object:nil];
        [nc addObserver:self selector:@selector(didSaveProfile:) name:PFCDidSaveProfileNotification object:nil];
        [nc addObserver:self selector:@selector(groupDidRemoveProfiles:) name:PFCGroupDidRemoveProfileNotification object:nil];

        // ---------------------------------------------------------------------
        //  Create and setup PFCMainWindowOutlineView
        // ---------------------------------------------------------------------
        PFCMainWindowOutlineView *outlineView = [[PFCMainWindowOutlineView alloc] init];
        [outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
        [outlineView sizeLastColumnToFit];
        [outlineView setFloatsGroupRows:NO];
        [outlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
        [outlineView setHeaderView:nil];
        [outlineView setDataSource:self];
        [outlineView setDelegate:self];
        [outlineView registerForDraggedTypes:@[ PFCProfileDraggingType ]];
        _outlineView = outlineView;

        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:PFCMainWindowOutlineViewTableColumnIdentifier];
        [tableColumn setEditable:YES];
        [outlineView addTableColumn:tableColumn];

        NSScrollView *scrollView = [[NSScrollView alloc] init];
        [scrollView setDocumentView:outlineView];
        [scrollView setAutoresizesSubviews:YES];
        _scrollView = scrollView;

        // ---------------------------------------------------------------------
        //  Add all parent views to outline view
        // ---------------------------------------------------------------------
        [self addParents];

        // ---------------------------------------------------------------------
        //  Expand the first two parents (All Profiles & Library which can't show/hide later)
        // ---------------------------------------------------------------------
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0];
        [outlineView expandItem:self.parents[0] expandChildren:NO];
        [outlineView expandItem:self.parents[1] expandChildren:NO];
        [NSAnimationContext endGrouping];

        // ---------------------------------------------------------------------
        //  Select "All Profiles"
        // ---------------------------------------------------------------------
        [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notification
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCDidAddGroupNotification object:nil];
    [nc removeObserver:self name:PFCDidAddProfileNotification object:nil];
    [nc removeObserver:self name:PFCGroupDidRemoveProfileNotification object:nil];
}

- (void)addParents {
    _parents = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Add parent item: "All Profiles"
    // -------------------------------------------------------------------------
    PFCMainWindowAllProfiles *allProfiles = [[PFCMainWindowAllProfiles alloc] init];
    [_parents addObject:allProfiles];

    // -------------------------------------------------------------------------
    //  Add parent item: "Library"
    // -------------------------------------------------------------------------
    PFCMainWindowLibrary *library = [[PFCMainWindowLibrary alloc] init];
    [_parents addObject:library];

    // FIXME - Add more parent groups here like:
    //         JSS Profiles
    //         Local Profiles
    //         MCX from OD-server (if worh it)

    // -------------------------------------------------------------------------
    //  Store the "All Profiles" group in it's own instance variable for future use
    // -------------------------------------------------------------------------
    _allProfilesGroup = allProfiles.children.firstObject;

    // ---------------------------------------------------------------------
    //  Reload the outline view after adding items
    // ---------------------------------------------------------------------
    [_outlineView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notitfication Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -------------------------------------------------------------------------
//  When a profile was added, add it to the current selected group and group All Profiles
//  NOTE: If this notifications is implemented in the All Profiles group aswell,
//        then it might update after the outline view has reloaded and it won't
//        update the profile count or profile list.
// -------------------------------------------------------------------------
- (void)didAddProfile:(NSNotification *)notification {
    if (self.selectedItem) {
        if (self.allProfilesGroup) {
            [self.allProfilesGroup addProfileIdentifiers:@[ notification.userInfo[PFCNotificationUserInfoProfileIdentifier] ]];
        }
        if (![self.selectedItem isEqual:self.allProfilesGroup]) {
            [self.selectedItem addProfileIdentifiers:@[ notification.userInfo[PFCNotificationUserInfoProfileIdentifier] ]];
        }
        if (self.selectionDelegate != nil && [self.selectionDelegate respondsToSelector:@selector(childUpdated:sender:)]) {
            [self.selectionDelegate childUpdated:self.selectedItem sender:self];
        }
    }
}

// -------------------------------------------------------------------------
//  Reload outline view if sender was any of the outline view parents
// -------------------------------------------------------------------------
- (void)didAddGroup:(NSNotification *)notification {
    id notificationObject = notification.object;
    if ([self.parents containsObject:notificationObject]) {
        [self reloadData];

        // ---------------------------------------------------------------------
        //  If the parent the group was added to isn't expanded, expand it
        // ---------------------------------------------------------------------
        if (![self.outlineView isItemExpanded:notificationObject]) {
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0];
            [self.outlineView expandItem:notificationObject];
            [NSAnimationContext endGrouping];
        }
    }
}

// -----------------------------------------------------------------------------
//  Reload outline view when a profile was saved
// -----------------------------------------------------------------------------
- (void)didSaveProfile:(NSNotification *)notification {
    [self reloadData];
}

// -----------------------------------------------------------------------------
//  Reload outline view when a profile was removed
// -----------------------------------------------------------------------------
- (void)groupDidRemoveProfiles:(NSNotification *)notification {
    [self reloadData];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSOutlineViewDataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return !item ? self.parents.count : [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return !item ? self.parents[index] : [item children][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return !item ? YES : [[item children] count] != 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([tableColumn.identifier isEqualToString:PFCMainWindowOutlineViewTableColumnIdentifier]) {
        return [item title];
    }
    return @"-";
}

// -------------------------------------------------------------------------
//  Drag/Drop Support
// -------------------------------------------------------------------------
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewChild)]) {
        if ([(id<PFCMainWindowOutlineViewChild>)item isEditable]) {
            return (info.draggingSourceOperationMask == NSDragOperationCopy ? NSDragOperationCopy : NSDragOperationMove);
        }
    }
    return NSDragOperationNone;
}

// -------------------------------------------------------------------------
//  Drag/Drop Support
// -------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    NSData *draggingData = [[info draggingPasteboard] dataForType:PFCProfileDraggingType];
    NSArray *profileIdentifiers = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    [(id<PFCMainWindowOutlineViewChild>)item addProfileIdentifiers:profileIdentifiers];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSOutlineViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {

    // -------------------------------------------------------------------------
    //  Returns true for all items in the 'groups' array
    // -------------------------------------------------------------------------
    return [self.parents containsObject:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {

    // -------------------------------------------------------------------------
    //  Only allow group items to be selected (not the groups themselves).
    // -------------------------------------------------------------------------
    return ![self.parents containsObject:item];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Updates internal selection state and notifies delegate of the new selection
    // -------------------------------------------------------------------------
    NSInteger selectedRow = [self.outlineView selectedRow];
    if (selectedRow != -1) {
        id<PFCMainWindowOutlineViewChild> item = [self.outlineView itemAtRow:selectedRow];
        [self setSelectedItem:item];
        if (self.selectionDelegate != nil && [self.selectionDelegate respondsToSelector:@selector(childSelected:sender:)]) {
            [self.selectionDelegate childSelected:item sender:self];
        }
    }
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Selects the currently selected item if it exist in the expanding outlineview
    // -------------------------------------------------------------------------
    if (self.selectedItem != nil) {
        id object = [[notification userInfo] valueForKey:@"NSObject"];
        if ([object conformsToProtocol:@protocol(PFCMainWindowOutlineViewParent)]) {
            if ([[object children] containsObject:self.selectedItem]) {
                NSInteger selectionIndex = [self.outlineView rowForItem:self.selectedItem];
                [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionIndex] byExtendingSelection:NO];
            }
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {

    // -------------------------------------------------------------------------
    //  Hide the show/hide button for group 'Library'
    // -------------------------------------------------------------------------
    if ([[item class] isSubclassOfClass:[PFCMainWindowLibrary class]]) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewParent)]) {
        return (NSTableCellView *)[(id<PFCMainWindowOutlineViewParent>)item cellView];
    } else if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewChild)]) {
        return (NSTableCellView *)[(id<PFCMainWindowOutlineViewChild>)item cellView];
    }
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    if ([[item class] isSubclassOfClass:[PFCMainWindowAllProfiles class]]) {

        // -------------------------------------------------------------------------
        //  Ugly fix to hide the AllProfiles parent view, setting it's height to 0
        // -------------------------------------------------------------------------
        return 0;
    } else if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewParent)]) {
        return 18;
    } else if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewChild)]) {
        return 22;
    }
    return 22;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)shouldRemoveItemsAtIndexes:(NSIndexSet *_Nonnull)indexSet {

    // -------------------------------------------------------------------------
    //  Setup completion block
    // -------------------------------------------------------------------------
    void (^shouldDeleteBlock)(BOOL) = ^void(BOOL shouldDelete) {
      if (shouldDelete) {
          [self removeItemsAtIndexes:indexSet];
      }
    };

    NSString *alertMessage;

    // -------------------------------------------------------------------------
    //  Setup alert
    // -------------------------------------------------------------------------
    PFCAlert *alert = [[PFCAlert alloc] init];

    // -------------------------------------------------------------------------
    //  Setup alert message
    // -------------------------------------------------------------------------
    if (indexSet.count == 1) {
        id item = [self.outlineView itemAtRow:indexSet.firstIndex];
        if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewChild)] && ![item isEditing]) {
            alertMessage = [NSString
                stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the group: %@?", @"Alert title when asked to remove selected group from the main window sidebar"), [item title]];
        } else {
            return;
        }
    } else {
        NSMutableString *mutableAlertMessage = [[NSMutableString alloc]
            initWithString:NSLocalizedString(@"Are you sure you want to delete the following groups:\n", @"Alert title when asked to remove selected groups from the main window sidebar")];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *_Nonnull stop) {
          id item = [self.outlineView itemAtRow:idx];
          if ([item conformsToProtocol:@protocol(PFCMainWindowOutlineViewChild)] && ![item isEditing]) {
              [mutableAlertMessage appendString:[NSString stringWithFormat:@"%@\n", [item title]]];
          } else {
              return;
          }
        }];
        alertMessage = [mutableAlertMessage copy];
    }

    // -------------------------------------------------------------------------
    //  Setup alert informative text
    // -------------------------------------------------------------------------
    NSString *informativeText = NSLocalizedString(@"No profile will be removed.", @"Alert message when asked to remove selected group from the main window sidebar");

    // -------------------------------------------------------------------------
    //  Show alert to user
    // -------------------------------------------------------------------------
    [alert showAlertDeleteWithMessage:alertMessage informativeText:informativeText window:[[NSApplication sharedApplication] mainWindow] shouldDelete:shouldDeleteBlock];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Convenience method to reaload data in outline view and keep current selection
// -----------------------------------------------------------------------------
- (void)reloadData {

    // -------------------------------------------------------------------------
    //  Get selected row in outline view, reload to update item count
    // -------------------------------------------------------------------------
    NSIndexSet *selectedRowIndexes = [self.outlineView selectedRowIndexes];

    // -------------------------------------------------------------------------
    //  Reload outline view to update item count and restore previous selection
    // -------------------------------------------------------------------------
    [self.outlineView reloadData];
    [self.outlineView selectRowIndexes:selectedRowIndexes byExtendingSelection:NO];
}

- (void)removeItemsAtIndexes:(NSIndexSet *_Nonnull)indexSet {

    NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Add all objects for indexes in passed index set to itemsToRemove array
    // -------------------------------------------------------------------------
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *_Nonnull stop) {
      [itemsToRemove addObject:[self.outlineView itemAtRow:idx]];
    }];

    // -------------------------------------------------------------------------
    //  Get the outline view parent for the objects to remove
    // -------------------------------------------------------------------------
    id parent = [self.outlineView parentForItem:[self.outlineView itemAtRow:indexSet.firstIndex]];
    if (parent != nil && [parent conformsToProtocol:@protocol(PFCMainWindowOutlineViewParent)]) {

        // ---------------------------------------------------------------------
        //  Try to remove item from disk, if successful, add item to itemsRemoved array
        // ---------------------------------------------------------------------
        __block NSMutableArray *itemsRemoved = [[NSMutableArray alloc] init];
        [itemsToRemove enumerateObjectsUsingBlock:^(id _Nonnull child, NSUInteger idx, BOOL *_Nonnull stop) {
          if ([child removeFromDisk:nil]) {
              [itemsRemoved addObject:child];
          }
        }];

        // ---------------------------------------------------------------------
        //  For all items successfully removed from disk, tell parent to remove from itself
        // ---------------------------------------------------------------------
        if (itemsRemoved.count != 0) {
            if ([itemsRemoved containsObject:self.selectedItem]) {
                [self setSelectedItem:nil];
            }
            [[(id<PFCMainWindowOutlineViewParent>)parent children] removeObjectsInArray:itemsRemoved];
            [self reloadData];
        }
    }
}

@end

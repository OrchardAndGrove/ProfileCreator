//
//  PFCMainWindowTableViewController.m
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
#import "PFCMainWindowAllProfilesGroup.h"
#import "PFCMainWindowOutlineView.h"
#import "PFCMainWindowOutlineViewChildCellView.h"
#import "PFCMainWindowOutlineViewChildProtocol.h"
#import "PFCMainWindowTableView.h"
#import "PFCMainWindowTableViewController.h"
#import "PFCMainWindowTableViewItemCellView.h"
#import "PFCProfileController.h"

NSString *const PFCMainWindowTableViewTableColumnIdentifier = @"TableViewTableColumnIdentifier";

@interface PFCMainWindowTableViewController ()
@property (nonatomic, readwrite, nonnull) NSScrollView *scrollView;
@property (nonatomic, strong, nonnull) PFCMainWindowTableView *tableView;
@property (nonatomic, strong, nonnull) PFCMainWindowTableViewItemCellView *cellView;
@property (nonatomic, weak, nullable) id<PFCMainWindowOutlineViewChild> child;
@property (nonatomic, strong, nonnull) NSArray *selectedProfileIdentifiers;
@property (nonatomic, strong, nullable) PFCAlert *alert;
@end

@implementation PFCMainWindowTableViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(groupDidRemoveProfiles:) name:PFCGroupDidRemoveProfileNotification object:nil];
        [nc addObserver:self selector:@selector(exportProfile:) name:PFCExportProfileNotification object:nil];
        [nc addObserver:self selector:@selector(didSaveProfile:) name:PFCDidSaveProfileNotification object:nil];

        // ---------------------------------------------------------------------
        //  Setup CellView Class
        // ---------------------------------------------------------------------
        _cellView = [[PFCMainWindowTableViewItemCellView alloc] init];

        // ---------------------------------------------------------------------
        //  Add and setup TableView
        // ---------------------------------------------------------------------
        PFCMainWindowTableView *tableView = [[PFCMainWindowTableView alloc] init];
        [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [tableView sizeLastColumnToFit];
        [tableView setFloatsGroupRows:NO];
        [tableView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
        [tableView setHeaderView:nil];
        [tableView setDataSource:self];
        [tableView setDelegate:self];
        [tableView setTarget:self];
        [tableView setDoubleAction:@selector(editProfile:)];
        [tableView setAllowsMultipleSelection:YES];
        _tableView = tableView;

        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:PFCMainWindowTableViewTableColumnIdentifier];
        [tableColumn setEditable:NO];
        [tableView addTableColumn:tableColumn];

        NSScrollView *scrollView = [[NSScrollView alloc] init];
        [scrollView setDocumentView:tableView];
        [scrollView setAutoresizesSubviews:YES];
        _scrollView = scrollView;
    }
    return self;
} // initWithSelectionDelegate

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notification
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCGroupDidRemoveProfileNotification object:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowOutlineViewSelectionDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)childSelected:(id<PFCMainWindowOutlineViewChild> _Nonnull)child sender:(id _Nonnull)sender {
    if (!child) {
        [self setChild:nil];
    } else if (!self.child || ![self.child isEqual:child]) {
        [self setChild:child];
    }
    [self reloadData];
} // childSelected:sender

- (void)childUpdated:(id<PFCMainWindowOutlineViewChild> _Nonnull)child sender:(id _Nonnull)sender {
    if ([self.child isEqual:child]) {
        [self reloadData];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)groupDidRemoveProfiles:(NSNotification *)notification {

    [self.tableView reloadData];

    NSDictionary *userInfo = notification.userInfo;
    if (userInfo[PFCNotificationUserInfoIndexSet] != nil) {
        NSIndexSet *indexSet = userInfo[PFCNotificationUserInfoIndexSet];

        // ---------------------------------------------------------------------
        //  Get new index in table view and select it (if list isn't empty)
        // ---------------------------------------------------------------------
        if (self.child.profileIdentifiers.count != 0) {
            NSInteger newIndex = (indexSet.lastIndex - indexSet.count);
            if (newIndex < 0) {
                newIndex = 0;
            }
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)newIndex] byExtendingSelection:NO];
            return;
        }
    }
    [self tableViewSelectionDidChange:[NSNotification notificationWithName:@"EmptyNotification" object:nil]];
}

- (void)didSaveProfile:(NSNotification *)notification {
    [self reloadData];
}

- (void)exportProfile:(NSNotification *)notification {

    // FIXME - Currently only allow exporting one profile at a time
    if (self.selectedProfileIdentifiers.count != 1) {
        return;
    }

    [[PFCProfileController sharedController] exportProfileWithIdentifier:self.selectedProfileIdentifiers.firstObject sender:self];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Convenience method to reaload data in table view and keep current selection
// -----------------------------------------------------------------------------
- (void)reloadData {

    // -------------------------------------------------------------------------
    //  Reload data in TableView
    // -------------------------------------------------------------------------
    [self.tableView reloadData];

    // -------------------------------------------------------------------------
    //  Get indexes of selected profile identifiers
    // -------------------------------------------------------------------------
    NSIndexSet *indexSet = [self.child.profileIdentifiers indexesOfObjectsPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      return [self.selectedProfileIdentifiers ?: @[] containsObject:obj];
    }];

    // -------------------------------------------------------------------------
    //  Restore selection in table view if there was a selection
    // -------------------------------------------------------------------------
    if (indexSet.count != 0) {
        [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
} // reloadData

- (void)editProfile:(id)sender {
    NSInteger clickedRow = [sender clickedRow];
    if (0 <= clickedRow) {
        NSString *identifier = self.child.profileIdentifiers[clickedRow];
        [[PFCProfileController sharedController] editProfileWithIdentifier:identifier];

        // ---------------------------------------------------------------------
        //  Update curren selection with clicked row
        // ---------------------------------------------------------------------
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:clickedRow];
        [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
} // editProfile

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableViewDataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (self.child != nil) {
        return self.child.profileIdentifiers.count;
    }
    return 0;
} // numberOfRowsInTableView

- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
    NSData *draggingData = [draggingInfo.draggingPasteboard dataForType:PFCProfileDraggingType];
    NSArray *profileIdentifiers = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    draggingInfo.numberOfValidItemsForDrop = (NSInteger)profileIdentifiers.count;
} // tableView:updateDraggingItemsForDrag

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(nonnull NSIndexSet *)rowIndexes toPasteboard:(nonnull NSPasteboard *)pboard {
    NSMutableArray *selectedProfileIdentifiers = [[NSMutableArray alloc] init];
    NSArray *selectedProfiles = [self.child.profileIdentifiers objectsAtIndexes:rowIndexes];
    for (NSString *profileIdentifier in selectedProfiles) {
        [selectedProfileIdentifiers addObject:profileIdentifier];
    }

    [pboard clearContents];
    [pboard declareTypes:@[ PFCProfileDraggingType ] owner:nil];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[selectedProfileIdentifiers copy]] forType:PFCProfileDraggingType];
    return YES;
} // tableView:writeRowsWithIndexes:toPasteboard

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    if (operation == NSDragOperationMove && self.child != nil && self.child.isEditable) {
        NSData *draggingData = [[session draggingPasteboard] dataForType:PFCProfileDraggingType];
        NSArray *profileIdentifiers = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
        NSUInteger newIndex = ([self.child.profileIdentifiers indexOfObject:profileIdentifiers.lastObject] - profileIdentifiers.count);
        [self.child removeProfileIdentifiers:profileIdentifiers];
        [self.tableView reloadData];
        if (self.child.profileIdentifiers.count != 0) {
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
        } else {
            [self tableViewSelectionDidChange:[NSNotification notificationWithName:@"EmptyNotification" object:nil]];
        }
    }
} // tableView:draggingSession:endedAtPoint:operation

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 23;
} // tableView:heightOfRow

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (self.child != nil) {
        NSString *identifier = self.child.profileIdentifiers[row];
        return [PFCMainWindowTableViewItemCellView cellViewWithTitle:[[PFCProfileController sharedController] titleForProfileWithIdentifier:identifier]];
    }
    return nil;
} // tableView:viewForTableColumn:row

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSIndexSet *selectionIndexes = [self.tableView selectedRowIndexes];
    [self setSelectedProfileIdentifiers:[self.child.profileIdentifiers objectsAtIndexes:selectionIndexes]];
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCProfileSelectionDidChangeNotification
                                                        object:self
                                                      userInfo:@{
                                                          @"ProfileIdentifiers" : self.selectedProfileIdentifiers,
                                                          @"IndexSet" : selectionIndexes
                                                      }];
} // tableViewSelectionDidChange

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark FIXME - Delegate call from Table View when the delete key is pressed
#pragma mark Should possibly be replaced with notifications: should, do, did
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)shouldRemoveItemsAtIndexes:(NSIndexSet *_Nonnull)indexSet {
    if (self.child != nil && [self.child respondsToSelector:@selector(removeProfileIdentifiersAtIndexes:)]) {

        // ---------------------------------------------------------------------
        //  Setup completion block
        // ---------------------------------------------------------------------
        void (^shouldDeleteBlock)(BOOL) = ^void(BOOL shouldDelete) {
          [self setAlert:nil];
          if (shouldDelete) {
              [self removeItemsAtIndexes:indexSet];
          }
        };

        NSString *alertMessage;
        NSString *informativeText;

        // ---------------------------------------------------------------------
        //  Setup alert message
        // ---------------------------------------------------------------------
        if ([[self.child class] isSubclassOfClass:[PFCMainWindowAllProfilesGroup class]]) {
            if (indexSet.count <= 1) {
                NSString *identifier = self.child.profileIdentifiers[indexSet.firstIndex];
                alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the profile \"%@\"?", @""),
                                                          [[PFCProfileController sharedController] titleForProfileWithIdentifier:identifier]];
                informativeText = NSLocalizedString(@"This cannot be undone", @"Message when deleting profile from main window");
            } else {
                alertMessage = NSLocalizedString(@"Are you sure you want to delete the following profiles?", @"");
                NSMutableString *mutableInformativeText = [[NSMutableString alloc] init];
                [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *_Nonnull stop) {
                  NSString *identifier = self.child.profileIdentifiers[idx];
                  [mutableInformativeText appendString:[NSString stringWithFormat:@"  •  %@\n", [[PFCProfileController sharedController] titleForProfileWithIdentifier:identifier]]];
                }];
                informativeText = [NSString stringWithFormat:@"%@\n%@", [mutableInformativeText copy], NSLocalizedString(@"This cannot be undone", @"Message when deleting profile from main window")];
            }

        } else {
            if (indexSet.count <= 1) {
                NSString *identifier = self.child.profileIdentifiers[indexSet.firstIndex];
                alertMessage = [NSString stringWithFormat:@"Are you sure you want to remove the profile \"%@\" from group \"%@\"?",
                                                          [[PFCProfileController sharedController] titleForProfileWithIdentifier:identifier], self.child.title];
                informativeText = NSLocalizedString(@"The profile will still be available in \"All Profiles\"", @"Message when deleting profile from main window");
            } else {
                alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the following profiles from group \"%@\"?", @""), self.child.title];
                NSMutableString *mutableInformativeText = [[NSMutableString alloc] init];
                [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *_Nonnull stop) {
                  NSString *identifier = self.child.profileIdentifiers[idx];
                  [mutableInformativeText appendString:[NSString stringWithFormat:@"  •  %@\n", [[PFCProfileController sharedController] titleForProfileWithIdentifier:identifier]]];
                }];
                informativeText = [NSString stringWithFormat:@"%@\n%@", [mutableInformativeText copy],
                                                             NSLocalizedString(@"All profiles will still be available in \"All Profiles\"", @"Message when deleting profile from main window")];
            }
        }

        // ---------------------------------------------------------------------
        //  Show alert to user
        // ---------------------------------------------------------------------
        [self setAlert:[[PFCAlert alloc] init]];
        [self.alert showAlertDeleteWithMessage:alertMessage informativeText:informativeText window:[[NSApplication sharedApplication] mainWindow] shouldDelete:shouldDeleteBlock];
    }
} // shouldRemoveItemsAtIndexes

- (void)removeItemsAtIndexes:(NSIndexSet *_Nonnull)indexSet {
    if (self.child != nil) {

        // ---------------------------------------------------------------------
        //  Remove profiles from child and reload table view
        // ---------------------------------------------------------------------
        [self.child removeProfileIdentifiersAtIndexes:indexSet];
    }
} // removeItemsAtIndexes

@end

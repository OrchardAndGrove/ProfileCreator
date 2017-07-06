//
//  PFCProfileEditorLibraryPayloads.m
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

#import "PFCLog.h"
#import "PFCProfile.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorLibraryNoPayloads.h"
#import "PFCProfileEditorLibraryPayloads.h"
#import "PFCProfileEditorLibraryPayloadsCellViewLibrary.h"
#import "PFCProfileEditorLibraryPayloadsCellViewProfile.h"
#import "PFCProfileEditorLibrarySplitView.h"
#import "PFCProfileEditorSplitView.h"
#import "PFCProfileEditorTableViewController.h"
#import "PFCProfileEditorToolbarItemTitle.h"
#import <ProfilePayloads/ProfilePayloads.h>

NSString *const PFCProfileEditorLibraryTableColumnIdentifierPayloads = @"TableColumnPayloads";

@interface PFCProfileEditorLibraryPayloads ()

@property (nonatomic, readwrite) PFCPayloadLibrary selectedLibrary;
@property (nonatomic, strong, readwrite, nonnull) NSDictionary *selectedPlaceholder;

@property (nonatomic) BOOL allowEmptySelection; // Used when showing settings view;

@property (nonatomic, weak, nullable) id selectionDelegate;
@property (nonatomic, weak, nullable) PFCProfile *profile;
@property (nonatomic, weak, nullable) PFCProfileEditor *profileEditor;
@property (nonatomic, weak, nullable) PFCProfileEditorLibrarySplitView *profileEditorLibrarySplitView;
@property (nonatomic, strong, nonnull) PFPPayloadCollections *payloadCollections;
@property (nonatomic, strong, nullable) id<PFPPayloadCollectionSet> collectionApple;

@property (nonatomic, readwrite, strong, nonnull) NSMutableArray *libraryPayloads;
@property (nonatomic, strong, nonnull) NSMutableArray *profilePayloads;

@property (nonatomic, strong, nonnull) NSMutableArray *libraryProfileManager;

@property (nonatomic, strong, readwrite, nonnull) NSScrollView *scrollViewLibraryPayloads;
@property (nonatomic, strong, nonnull) NSTableView *tableViewLibraryPayloads;

@property (nonatomic, strong, readwrite, nonnull) NSScrollView *scrollViewProfilePayloads;
@property (nonatomic, strong, readwrite, nonnull) NSTableView *tableViewProfilePayloads;

@end

@implementation PFCProfileEditorLibraryPayloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfileEditor:(PFCProfileEditor *_Nonnull)profileEditor
                profileEditorLibrarySplitView:(PFCProfileEditorLibrarySplitView *_Nonnull)profileEditorLibrarySplitView
                            selectionDelegate:(id _Nonnull)selectionDelegate {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profileEditor = profileEditor;
        _profileEditorLibrarySplitView = profileEditorLibrarySplitView;
        _profile = _profileEditor.profile;
        _selectionDelegate = selectionDelegate;

        _libraryPayloads = [[NSMutableArray alloc] init];
        _profilePayloads = [[NSMutableArray alloc] init];
        _libraryProfileManager = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Instantiate Profile Payloads if not already instantiated in profile
        // ---------------------------------------------------------------------
        if (!_profile.profilePayloads) {
            [_profile setProfilePayloads:[[PFPProfilePayloads alloc] initWithSettings:_profile.savedPayloadSettings viewModel:kPFPViewModelTableView settingsDelegate:_profile]];
        }

        // ---------------------------------------------------------------------
        //  Register for notifications
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(showSettingsView:) name:PFCSelectProfileSettingsNotification object:nil];

        // ---------------------------------------------------------------------
        //  Instantiate and setup all Payload Collections to use in the editor
        // ---------------------------------------------------------------------
        // Currently only ProfileManager, add more here when available
        [self initializePayloadCollectionProfileManager];

        // ---------------------------------------------------------------------
        //  Setup views in splitview
        // ---------------------------------------------------------------------
        [self initializeTableViewProfilePayloads];
        [self initializeTableViewLibraryPayloads];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Remove self as DataSource
    // -------------------------------------------------------------------------
    [self.tableViewProfilePayloads setDataSource:nil];
    [self.tableViewLibraryPayloads setDataSource:nil];

    // -------------------------------------------------------------------------
    //  Remove self as Delegate
    // -------------------------------------------------------------------------
    [self.tableViewProfilePayloads setDelegate:nil];
    [self.tableViewLibraryPayloads setDelegate:nil];
}

- (void)initializePayloadCollectionProfileManager {

    // -------------------------------------------------------------------------
    //  Instantiate and set Payload Collection for Profile Manager
    // -------------------------------------------------------------------------
    _collectionApple = [_profile.profilePayloads collectionSet:kPFPCollectionSetApple];

    // -------------------------------------------------------------------------
    //  Add enabled profiles to the Profile Payloads library, all others to the Library Payloads library
    // -------------------------------------------------------------------------
    for (NSDictionary *placeholder in _collectionApple.placeholders) {
        if ([placeholder[PFPPlaceholderKeyIdentifier] isEqualToString:@"com.apple.general.pcmanifest"] ||
            [self.profile.profilePayloads.enabledCollectionIdentifiers containsObject:placeholder[PFPPlaceholderKeyIdentifier]]) {
            [_profilePayloads addObject:placeholder];
        } else {
            [_libraryProfileManager addObject:placeholder];
        }
    }
} // initializePayloadCollectionProfileManager

- (void)initializeTableViewProfilePayloads {

    // -------------------------------------------------------------------------
    //  Create and add TableView Profile Payloads
    // -------------------------------------------------------------------------
    _tableViewProfilePayloads = [[NSTableView alloc] init];
    [_tableViewProfilePayloads setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_tableViewProfilePayloads setFocusRingType:NSFocusRingTypeNone];
    [_tableViewProfilePayloads sizeLastColumnToFit];
    [_tableViewProfilePayloads setFloatsGroupRows:NO];
    [_tableViewProfilePayloads setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    [_tableViewProfilePayloads setHeaderView:nil];
    [_tableViewProfilePayloads setDataSource:self];
    [_tableViewProfilePayloads setDelegate:self];
    [_tableViewProfilePayloads setTarget:self];
    [_tableViewProfilePayloads setAllowsMultipleSelection:NO];
    [_tableViewProfilePayloads setTag:kPFCLibraryTableViewProfile];
    [_tableViewProfilePayloads setIntercellSpacing:NSMakeSize(0, 0)];
    [_tableViewProfilePayloads registerForDraggedTypes:@[ PFCPayloadPlaceholderDraggingType ]];

    NSTableColumn *tableColumnPayloads = [[NSTableColumn alloc] initWithIdentifier:PFCProfileEditorLibraryTableColumnIdentifierPayloads];
    [tableColumnPayloads setEditable:NO];
    [_tableViewProfilePayloads addTableColumn:tableColumnPayloads];

    _scrollViewProfilePayloads = [[RFOverlayScrollView alloc] init];
    [_scrollViewProfilePayloads setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scrollViewProfilePayloads setDocumentView:_tableViewProfilePayloads];
    [_scrollViewProfilePayloads setVerticalScroller:[[RFOverlayScroller alloc] init]];
    [_scrollViewProfilePayloads setHasVerticalScroller:YES];
    [_scrollViewProfilePayloads setAutoresizesSubviews:YES];
} // initializeTableViewProfilePayloads

- (void)initializeTableViewLibraryPayloads {

    // -------------------------------------------------------------------------
    //  Create and add TableView Library Payloads
    // -------------------------------------------------------------------------
    _tableViewLibraryPayloads = [[NSTableView alloc] init];
    [_tableViewLibraryPayloads setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_tableViewLibraryPayloads setFocusRingType:NSFocusRingTypeNone];
    [_tableViewLibraryPayloads sizeLastColumnToFit];
    [_tableViewLibraryPayloads setFloatsGroupRows:NO];
    [_tableViewLibraryPayloads setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    [_tableViewLibraryPayloads setHeaderView:nil];
    [_tableViewLibraryPayloads setDataSource:self];
    [_tableViewLibraryPayloads setDelegate:self];
    [_tableViewLibraryPayloads setTarget:self];
    [_tableViewLibraryPayloads setAllowsMultipleSelection:NO];
    [_tableViewLibraryPayloads setTag:kPFCLibraryTableViewLibrary];
    [_tableViewLibraryPayloads setIntercellSpacing:NSMakeSize(0, 0)];
    [_tableViewLibraryPayloads registerForDraggedTypes:@[ PFCPayloadPlaceholderDraggingType ]];

    NSTableColumn *tableColumnPayloads = [[NSTableColumn alloc] initWithIdentifier:PFCProfileEditorLibraryTableColumnIdentifierPayloads];
    [tableColumnPayloads setEditable:NO];
    [_tableViewLibraryPayloads addTableColumn:tableColumnPayloads];

    _scrollViewLibraryPayloads = [[RFOverlayScrollView alloc] init];
    [_scrollViewLibraryPayloads setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scrollViewLibraryPayloads setDocumentView:_tableViewLibraryPayloads];
    [_scrollViewLibraryPayloads setVerticalScroller:[[RFOverlayScroller alloc] init]];
    [_scrollViewLibraryPayloads setHasVerticalScroller:YES];
    [_scrollViewLibraryPayloads setAutoresizesSubviews:YES];
} // initializeTableViewLibraryPayloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableViewDataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView.tag == kPFCLibraryTableViewProfile) {
        return self.profilePayloads.count;
    } else if (tableView.tag == kPFCLibraryTableViewLibrary) {
        return self.libraryPayloads.count;
    }
    return 0;
} // numberOfRowsInTableView

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(nonnull NSIndexSet *)rowIndexes toPasteboard:(nonnull NSPasteboard *)pboard {
    if ([tableView isEqualTo:self.tableViewProfilePayloads] && [rowIndexes containsIndex:0]) {
        // Don't allow to drag & drop General settings
        return NO;
    } else {
        NSArray *selectedPlaceholders;
        if ([tableView isEqualTo:self.tableViewLibraryPayloads]) {
            selectedPlaceholders = [self.libraryPayloads objectsAtIndexes:rowIndexes];
        } else if ([tableView isEqualTo:self.tableViewProfilePayloads]) {
            selectedPlaceholders = [self.profilePayloads objectsAtIndexes:rowIndexes];
        }

        [pboard clearContents];
        [pboard declareTypes:@[ PFCPayloadPlaceholderDraggingType ] owner:nil];
        [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[selectedPlaceholders copy]] forType:PFCPayloadPlaceholderDraggingType];
        return YES;
    }
} // tableView:writeRowsWithIndexes:toPasteboard

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (tableView == info.draggingSource || dropOperation == NSTableViewDropOn || ([tableView isEqualTo:self.tableViewProfilePayloads] && row == 0)) {
        return NSDragOperationNone;
    } else {
        [tableView setDropRow:-1 dropOperation:NSTableViewDropOn];
        return NSDragOperationCopy;
    }
} // tableView:validateDrop:proposedRow:proposedDropOperation

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(nonnull id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSData *draggingData = [[info draggingPasteboard] dataForType:PFCPayloadPlaceholderDraggingType];
    NSArray *placeholders = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    if ([tableView isEqualTo:self.tableViewProfilePayloads]) {
        [self movePlaceholders:placeholders fromTableViewArray:self.libraryPayloads toTableViewArray:self.profilePayloads];
    } else if ([tableView isEqualTo:self.tableViewLibraryPayloads]) {
        [self movePlaceholders:placeholders fromTableViewArray:self.profilePayloads toTableViewArray:self.libraryPayloads];
    }
    return YES;
} // tableView:acceptDrop:row:dropOperation

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView.tag == kPFCLibraryTableViewProfile) {
        return 40;
    } else if (tableView.tag == kPFCLibraryTableViewLibrary) {
        return 32;
    }
    return 1;
} // tableView:heightOfRow

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView.tag == kPFCLibraryTableViewProfile) {
        NSDictionary *placeholder = self.profilePayloads[row];
        return [[PFCProfileEditorLibraryPayloadsCellViewProfile alloc]
            initWithTitle:placeholder[PFPPlaceholderKeyTitle]
              description:([placeholder[PFPPlaceholderKeyIdentifier] isEqualToString:@"com.apple.general.pcmanifest"]) ? @"Mandatory" : @"1 Payload"
                     icon:placeholder[PFPPlaceholderKeyIcon]
                      row:row
                   sender:self];
    } else if (tableView.tag == kPFCLibraryTableViewLibrary) {
        NSDictionary *placeholder = self.libraryPayloads[row];
        return [[PFCProfileEditorLibraryPayloadsCellViewLibrary alloc] initWithTitle:placeholder[PFPPlaceholderKeyTitle] icon:placeholder[PFPPlaceholderKeyIcon] row:row sender:self];
    }
    return nil;
} // tableView:viewForTableColumn:row

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    if (0 <= tableView.clickedRow || self.allowEmptySelection) {
        return YES;
    } else {
        if (tableView.tag == kPFCLibraryTableViewProfile) {
            return (0 <= self.tableViewLibraryPayloads.selectedRow);
        } else if (tableView.tag == kPFCLibraryTableViewLibrary) {
            return (0 <= self.tableViewProfilePayloads.selectedRow);
        }
        return YES;
    }
} // selectionShouldChangeInTableView

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSIndexSet *selectionIndexes = [tableView selectedRowIndexes];
    if (selectionIndexes.count != 0) {
        if (tableView.tag == kPFCLibraryTableViewProfile) {
            [self.tableViewLibraryPayloads deselectAll:self];
            [self selectPlaceholder:self.profilePayloads[tableView.selectedRow] inTableView:tableView];
        } else if (tableView.tag == kPFCLibraryTableViewLibrary) {
            [self.tableViewProfilePayloads deselectAll:self];
            [self selectPlaceholder:self.libraryPayloads[tableView.selectedRow] inTableView:tableView];
        }
    }
} // tableViewSelectionDidChange

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSDraggingSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy;
} // draggingSession:sourceOperationMaskForDraggingContext

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSDraggingDestionation Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    // FIXME - Here forcing a focus ring would fit, haven't looked into how to yet.
    // NSView *noPayloadsView = self.profileEditorLibrarySplitView.libraryNoPayloads.view;
    //[[noPayloadsView window] makeFirstResponder:noPayloadsView];
    return NSDragOperationCopy;
} // draggingEntered

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
} // prepareForDragOperation

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSData *draggingData = [[sender draggingPasteboard] dataForType:PFCPayloadPlaceholderDraggingType];
    NSArray *placeholders = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    [self movePlaceholders:placeholders fromTableViewArray:self.profilePayloads toTableViewArray:self.libraryPayloads];
    return YES;
} // performDragOperation

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showSettingsView:(NSNotification *_Nullable)notification {
    if (notification.object == self.profileEditor) {
        [self setAllowEmptySelection:YES];
        [self.tableViewLibraryPayloads deselectAll:self];
        [self.tableViewProfilePayloads deselectAll:self];
        [self setSelectedPlaceholder:@{}];
        [self.profileEditor.toolbarItemTitle setSelectionTitle:@"Settings"];
        [self setAllowEmptySelection:NO];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Called when user clicked a button in the Library Menu
// -----------------------------------------------------------------------------
- (void)selectLibrary:(PFCPayloadLibrary)library {
    switch (library) {
    case kPFCPayloadLibraryApple:
        [self setSelectedLibrary:library];
        [self setLibraryPayloads:self.libraryProfileManager];
        break;
    case kPFCPayloadLibraryAll:
    case kPFCPayloadLibraryMCX:
    case kPFCPayloadLibraryCustom:
    case kPFCPayloadLibraryProfile:
    case kPFCPayloadLibraryDeveloper:
    case kPFCPayloadLibraryUserPreferences:
    case kPFCPayloadLibraryLibraryPreferences:
        return;
        break;
    }

    // -------------------------------------------------------------------------
    //  If the Library SplitView is collapsed, uncollapse it
    // -------------------------------------------------------------------------
    if (self.profileEditorLibrarySplitView.splitViewLibraryCollapsed) {
        [self.profileEditorLibrarySplitView uncollapseLibraryView];
    }

    // -------------------------------------------------------------------------
    //  Reload TableView to show the new selection
    // -------------------------------------------------------------------------
    [self reloadData];
} // selectLibrary

// -----------------------------------------------------------------------------
//  Called when user clicked the + or - button on a placeholder view
// -----------------------------------------------------------------------------
- (void)togglePayload:(NSButton *_Nonnull)sender {

    // -------------------------------------------------------------------------
    //  Get the TableView the placeholder was clicked in
    // -------------------------------------------------------------------------
    id view = [sender superview];
    while (view && [view isKindOfClass:[NSTableView class]] == NO) {
        view = [view superview];
    }

    // -------------------------------------------------------------------------
    //  Depending on the table view, either enable or disable the payload
    // -------------------------------------------------------------------------
    if ([view isEqual:self.tableViewProfilePayloads]) {
        NSDictionary *placeholder = self.profilePayloads[sender.tag];
        [self movePlaceholders:@[ placeholder ] fromTableViewArray:self.profilePayloads toTableViewArray:self.libraryPayloads];
    } else if ([view isEqual:self.tableViewLibraryPayloads]) {
        NSDictionary *placeholder = self.libraryPayloads[sender.tag];
        [self movePlaceholders:@[ placeholder ] fromTableViewArray:self.libraryPayloads toTableViewArray:self.profilePayloads];
    }
} // togglePayload

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// -----------------------------------------------------------------------------
//  Convenience method to reaload data in both table views and keep current selection
//  Even if the current selection has changed table view
// -----------------------------------------------------------------------------
- (void)reloadData {

    // -------------------------------------------------------------------------
    //  Sort both library and profile arrays alphabetically
    // -------------------------------------------------------------------------
    NSSortDescriptor *sortDescriptorTitle = [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES];
    [self.libraryPayloads sortUsingDescriptors:@[ sortDescriptorTitle ]];
    [self.profilePayloads sortUsingDescriptors:@[ sortDescriptorTitle ]];
    
    // -------------------------------------------------------------------------
    //  Verify "General" settings always are at the top of the profile payloads
    // -------------------------------------------------------------------------
    NSUInteger indexPayloadGeneral = [self.profilePayloads indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull placeholder, NSUInteger idx, BOOL * _Nonnull stop) {
        return [placeholder[PFPPlaceholderKeyIdentifier] isEqualToString:@"com.apple.general.pcmanifest"];
    }];
    if ( 0 != indexPayloadGeneral ) {
        NSDictionary *payloadGeneral = self.profilePayloads[indexPayloadGeneral];
        [self.profilePayloads removeObject:payloadGeneral];
        [self.profilePayloads insertObject:payloadGeneral atIndex:0];
    }
    
    // -------------------------------------------------------------------------
    //  Reload both table views
    // -------------------------------------------------------------------------
    [self.tableViewLibraryPayloads reloadData];
    [self.tableViewProfilePayloads reloadData];

    // -------------------------------------------------------------------------
    //  Check which table view holds the current selection, and mark it selected
    //  This is different from - (void)selectPlaceholder which also updates editor etc.
    // -------------------------------------------------------------------------
    if ([self.profilePayloads containsObject:self.selectedPlaceholder]) {
        NSInteger index = [self.profilePayloads indexOfObject:self.selectedPlaceholder];
        [self.tableViewProfilePayloads selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    } else if ([self.libraryPayloads containsObject:self.selectedPlaceholder]) {
        NSInteger index = [self.libraryPayloads indexOfObject:self.selectedPlaceholder];
        [self.tableViewLibraryPayloads selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
} // reloadData

- (void)selectPlaceholder:(NSDictionary *_Nonnull)placeholder inTableView:(NSTableView *_Nonnull)tableView {

    // -------------------------------------------------------------------------
    //  Update stored selection with placeholder
    // -------------------------------------------------------------------------
    [self setSelectedPlaceholder:placeholder];

    // -------------------------------------------------------------------------
    //  Pass selection to selection delegate (Editor View)
    // -------------------------------------------------------------------------
    if (self.selectionDelegate != nil && [self.selectionDelegate respondsToSelector:@selector(payloadCollectionSelected:sender:)]) {

        // ---------------------------------------------------------------------
        //  Get the collection the placeholder belongs to
        // ---------------------------------------------------------------------
        id<PFPPayloadCollection> collection = [self collectionForPlaceholder:self.selectedPlaceholder];

        // ---------------------------------------------------------------------
        //  Tell selection delegate to show the placeholder's collection keys
        // ---------------------------------------------------------------------
        [self.selectionDelegate payloadCollectionSelected:collection sender:self];

        // ---------------------------------------------------------------------
        //  Tell selection delegate to show the placeholder's collection keys
        // ---------------------------------------------------------------------
        [self.profileEditor.splitView showEditorViewWithCollection:collection];
        [self.profileEditor.toolbarItemTitle setSelectionTitle:placeholder[PFPPlaceholderKeyTitle]];
    }
} // selectPlaceholder

- (id<PFPPayloadCollection>)collectionForPlaceholder:(NSDictionary *_Nonnull)placeholder {
    PFPCollectionSet collectionSet = [placeholder[PFPPlaceholderKeyCollectionSet] integerValue];
    switch (collectionSet) {
    case kPFPCollectionSetApple:
        return [_collectionApple collectionWithIdentifier:placeholder[PFPPlaceholderKeyIdentifier]];
        break;
    }
} // collectionForPlaceholder

// -----------------------------------------------------------------------------
//  Method for moving a placeholder between the Library and Profile TableViews
// -----------------------------------------------------------------------------
- (void)movePlaceholders:(NSArray *_Nonnull)placeholders fromTableViewArray:(NSMutableArray *_Nonnull)fromArray toTableViewArray:(NSMutableArray *_Nonnull)toArray {

    // -------------------------------------------------------------------------
    //  Set whether to enable or disable the payload
    // -------------------------------------------------------------------------
    BOOL enablePayloads = NO;
    if ([toArray isEqualToArray:self.libraryPayloads]) {
        enablePayloads = NO;
    } else if ([toArray isEqualToArray:self.profilePayloads]) {
        enablePayloads = YES;
    }

    // -------------------------------------------------------------------------
    //  Loop through all placeholders to move
    // -------------------------------------------------------------------------
    for (NSDictionary *placeholder in placeholders) {

        // ---------------------------------------------------------------------
        //  Get index of current placehoder in fromArray, and verify a valid index was returned
        //  NOTE: This is needed as
        // ---------------------------------------------------------------------
        NSUInteger placeholderIndex = [fromArray indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull profilePlaceholder, NSUInteger idx, BOOL *_Nonnull stop) {
          return [placeholder[PFPPlaceholderKeyIdentifier] isEqualToString:profilePlaceholder[PFPPlaceholderKeyIdentifier]];
        }];

        if (placeholderIndex == NSNotFound) {
            DDLogError(@"No index found in TableViewProfile for placeholder: %@", placeholder);
            continue;
        }

        NSDictionary *profilePlaceholder = fromArray[placeholderIndex];
        [fromArray removeObject:profilePlaceholder];
        [toArray addObject:profilePlaceholder];
        [self.profile.profilePayloads enablePayloadCollection:enablePayloads withIdentifier:profilePlaceholder[PFPPlaceholderKeyIdentifier]];
    }

    // -------------------------------------------------------------------------
    //  Check if any library is empty, then show "No Payloads" view
    // -------------------------------------------------------------------------
    if (self.libraryPayloads.count == 0 && !self.profileEditorLibrarySplitView.splitViewLibraryNoPayloads) {
        [self.profileEditorLibrarySplitView showLibraryNoProfiles:YES];
    } else if (self.libraryPayloads.count != 0 && self.profileEditorLibrarySplitView.splitViewLibraryNoPayloads) {
        [self.profileEditorLibrarySplitView showLibraryNoProfiles:NO];
    }

    // -------------------------------------------------------------------------
    //  Reload both TableViews
    // -------------------------------------------------------------------------
    [self reloadData];
} // movePlaceholders:fromTableViewArray:toTableViewArray

@end

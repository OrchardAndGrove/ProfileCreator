//
//  PFCProfileEditorTableViewController.m
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

#import "PFCProfile.h"
#import "PFCProfileEditorTableViewController.h"
#import <ProfilePayloads/ProfilePayloads.h>

NSString *const PFCProfileEditorTableColumnPaddingIdentifier = @"PFCProfileEditorTableColumnPaddingIdentifier";
NSString *const PFCProfileEditorTableColumnPayloadIdentifier = @"PFCProfileEditorTableColumnPayloadsIdentifier";

@interface PFCProfileEditorTableViewController ()
@property (nonatomic, strong, readwrite, nonnull) RFOverlayScrollView *scrollView;
@property (nonatomic, strong, nonnull) NSTableView *tableView;
@property (nonatomic, weak, nullable) PFCProfile *profile;
@property (nonatomic, strong, nullable) id<PFPPayloadCollection> payloadCollection;
@property (nonatomic, strong, readwrite, nonnull) NSMutableArray *payloadKeys;
@end

@implementation PFCProfileEditorTableViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithProfile:(PFCProfile *_Nonnull)profile {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Properties
        // ---------------------------------------------------------------------
        _profile = profile;
        _payloadKeys = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Add reference to self as view delegate in profile
        // ---------------------------------------------------------------------
        [_profile setViewDelegate:self];

        // ---------------------------------------------------------------------
        //  Create TableView
        // ---------------------------------------------------------------------
        _tableView = [[NSTableView alloc] init];
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_tableView sizeLastColumnToFit];
        [_tableView setFloatsGroupRows:NO];
        [_tableView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
        [_tableView setHeaderView:nil];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setTarget:self];
        [_tableView setAllowsMultipleSelection:YES];
        [_tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
        [_tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];

        // ---------------------------------------------------------------------
        //  Add TableColumn Padding
        // ---------------------------------------------------------------------
        NSTableColumn *tableColumnPaddingLeading = [[NSTableColumn alloc] initWithIdentifier:PFCProfileEditorTableColumnPaddingIdentifier];
        [tableColumnPaddingLeading setEditable:NO];
        [tableColumnPaddingLeading setMinWidth:24];
        [tableColumnPaddingLeading setWidth:24];
        [_tableView addTableColumn:tableColumnPaddingLeading];

        // ---------------------------------------------------------------------
        //  Add TableColumn Payload Settings
        // ---------------------------------------------------------------------
        NSTableColumn *tableColumnPayload = [[NSTableColumn alloc] initWithIdentifier:PFCProfileEditorTableColumnPayloadIdentifier];
        [tableColumnPayload setEditable:NO];
        [tableColumnPayload setWidth:500];
        [tableColumnPayload setMinWidth:500];
        [tableColumnPayload setMaxWidth:500];
        [_tableView addTableColumn:tableColumnPayload];

        // ---------------------------------------------------------------------
        //  Add TableColumn Padding
        // ---------------------------------------------------------------------
        NSTableColumn *tableColumnPaddingTrailing = [[NSTableColumn alloc] initWithIdentifier:PFCProfileEditorTableColumnPaddingIdentifier];
        [tableColumnPaddingTrailing setEditable:NO];
        [tableColumnPaddingTrailing setMinWidth:24];
        [tableColumnPaddingTrailing setWidth:24];
        [_tableView addTableColumn:tableColumnPaddingTrailing];

        // ---------------------------------------------------------------------
        //  Create ScrollView and add TableView as Document View
        // ---------------------------------------------------------------------
        _scrollView = [[RFOverlayScrollView alloc] init];
        [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_scrollView setDocumentView:_tableView];
        [_scrollView setVerticalScroller:[[RFOverlayScroller alloc] init]];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setAutoresizesSubviews:YES];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Remove self as DataSource
    // -------------------------------------------------------------------------
    [self.tableView setDataSource:nil];

    // -------------------------------------------------------------------------
    //  Remove self as Delegate
    // -------------------------------------------------------------------------
    [self.tableView setDelegate:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableViewDataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.payloadKeys.count;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    id<PFPViewTypeTableView> view = self.payloadKeys[row];
    return view.height ?: 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:PFCProfileEditorTableColumnPayloadIdentifier]) {
        return self.payloadKeys[row];
    }
    return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)reloadDataWithForcedReload:(BOOL)forceReload {

    // -------------------------------------------------------------------------
    //  Call PFPPayloadParser to return an array of payload keys for current settings to view
    // -------------------------------------------------------------------------
    NSMutableArray *payloadKeys = [[[PFPPayloadParser sharedParser] viewArrayFromPayloadCollectionSubkeys:self.payloadCollection.subkeys
                                                                                                 settings:self.profile.profilePayloads.settings
                                                                                      modifiedIdentifiers:(forceReload) ? @[ @"UpdateAll" ] : self.profile.modifiedIdentifiers] mutableCopy];

    // -------------------------------------------------------------------------
    //  Add padding above and below if any payload keys were returned
    // -------------------------------------------------------------------------
    if (payloadKeys.count != 0) {
        [payloadKeys insertObject:[[PFPViewTypeTableViewPadding alloc] init] atIndex:0];
        [payloadKeys addObject:[[PFPViewTypeTableViewPadding alloc] init]];
    }

    [self setPayloadKeys:payloadKeys];
    [self.tableView reloadData];
}

- (void)payloadCollectionSelected:(id<PFPPayloadCollection> _Nullable)payloadCollection sender:(id _Nonnull)sender {
    if (payloadCollection) {
        _payloadCollection = payloadCollection;
    }

    [self reloadDataWithForcedReload:YES];
}

@end

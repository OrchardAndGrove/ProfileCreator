//
//  PFPViewModelTableView.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-25.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPConstants.h"
#import "PFPViewTypeDelegate.h"
#import <Cocoa/Cocoa.h>
@class PFPPayloadCOllectionKey;

@interface PFPViewModelTableView : NSObject

- (NSTableCellView *_Nullable)viewForViewType:(PFPViewType)viewType payloadCollectionKey:(PFPPayloadCollectionKey *_Nonnull)payloadCollectionKey delegate:(id<PFPViewTypeDelegate> _Nonnull)delegate;

@end

//
//  PFPViewTypeTableViewPadding.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-10-01.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFPViewTypeTableViewPadding : NSTableCellView
@property (nonatomic) NSInteger height;
- (nonnull instancetype)initWithHeight:(NSInteger)height;
@end

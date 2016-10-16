//
//  PFPViewTypeTableViewTextField.h
//  ProfilePayloads
//
//  Created by Erik Berglund on 2016-09-23.
//  Copyright © 2016 ProfileCreator. All rights reserved.
//

#import "PFPViewTypeTableView.h"
#import <Cocoa/Cocoa.h>

@interface PFPViewTypeTableViewTextField : NSTableCellView <PFPViewTypeTableView, NSTextFieldDelegate>
@property (nonatomic, readonly) NSInteger row;
@property (nonatomic) NSInteger height;
@property (nonatomic, weak, nullable) id delegate;
@property (nonatomic, readonly, strong, nullable) NSTextField *textFieldInput;
@end

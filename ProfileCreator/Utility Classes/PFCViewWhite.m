//
//  PFCViewWhite.m
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

#import "PFCConstants.h"
#import "PFCViewWhite.h"

@interface PFCViewWhite ()
@property (nonatomic, weak, nullable) id<NSDraggingDestination> draggingDelegate;
@end

@implementation PFCViewWhite

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithDraggingDelegate:(id<NSDraggingDestination> _Nonnull)draggingDelegate {
    self = [super init];
    if (self != nil) {
        _draggingDelegate = draggingDelegate;
        [self registerForDraggedTypes:@[ PFCPayloadPlaceholderDraggingType ]];
        [self setFocusRingType:NSFocusRingTypeDefault];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSDraggingDestination Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSDragOperation result = NSDragOperationNone;
    if (self.draggingDelegate && [self.draggingDelegate respondsToSelector:_cmd]) {
        result = [self.draggingDelegate draggingEntered:sender];
    }
    return (result);
} // draggingEntered

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    if (self.draggingDelegate && [self.draggingDelegate respondsToSelector:_cmd]) {
        [self.draggingDelegate draggingExited:sender];
    }
} // draggingExited

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    BOOL result = NO;
    if (self.draggingDelegate && [self.draggingDelegate respondsToSelector:_cmd]) {
        result = [self.draggingDelegate prepareForDragOperation:sender];
    }
    return (result);
} // prepareForDragOperation

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    BOOL result = NO;
    if (self.draggingDelegate && [self.draggingDelegate respondsToSelector:_cmd]) {
        result = [self.draggingDelegate performDragOperation:sender];
    }
    return (result);
} // performDragOperation

@end

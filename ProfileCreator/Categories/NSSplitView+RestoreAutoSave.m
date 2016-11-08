//
//  NSSplitView+RestoreAutoSave.m
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

// From: http://stackoverflow.com/a/28318277

#import "NSSplitView+RestoreAutoSave.h"

@implementation NSSplitView (RestoreAutoSave)

- (void)pfc_restoreAutosavedPositions {
    NSString *key = [NSString stringWithFormat:@"NSSplitView Subview Frames %@", self.autosaveName];
    NSArray *subviewFrames = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    
    // the last frame is skipped because I have one less divider than I have frames
    for ( NSUInteger i = 0; i < subviewFrames.count; i++ ) {
        
        if( i < self.subviews.count ) { // safety-check (in case number of views have been removed while dev)
            
            // this is the saved frame data - it's an NSString
            NSString *frameString = subviewFrames[i];
            NSArray *components = [frameString componentsSeparatedByString:@", "];
            
            // Manage the 'hidden state' per view
            BOOL hidden = [components[4] boolValue];
            NSView* subView =[self subviews][i];
            [subView setHidden: hidden];
            
            // Set height (horizontal) or width (vertical)
            if( !self.vertical ) {
                
                CGFloat height = [components[3] floatValue];
                [subView setFrameSize: NSMakeSize( subView.frame.size.width, height ) ];
            }
            else {
                
                CGFloat width = [components[2] floatValue];
                [subView setFrameSize: NSMakeSize( width, subView.frame.size.height ) ];
            }
        }
    }
}

@end

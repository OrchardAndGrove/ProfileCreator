//
//  PFCAppDelegate.m
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

#import "PFCAppDelegate.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCMainWindow.h"
#import "PFCPreferences.h"

@interface PFCAppDelegate ()
@property (nonatomic, strong, nonnull) PFCMainWindow *mainWindowController;
@property (nonatomic, strong, nullable) PFCPreferences *preferences;
@end

@implementation PFCAppDelegate

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSApplicationDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillFinishLaunching:(NSNotification *)notification {

    // -------------------------------------------------------------------------
    //  Register user defaults
    // -------------------------------------------------------------------------
    NSError *error;
    NSURL *defaultSettingsPath = [[NSBundle mainBundle] URLForResource:@"Defaults" withExtension:@"plist"];
    if ([defaultSettingsPath checkResourceIsReachableAndReturnError:&error]) {
        NSDictionary *defaultSettingsDict = [NSDictionary dictionaryWithContentsOfURL:defaultSettingsPath];
        if (defaultSettingsDict.count != 0) {
            [NSUserDefaults.standardUserDefaults registerDefaults:defaultSettingsDict];
        }
    } else {
        // Use NSLog as CocoaLumberjack isn't available yet
        NSLog(@"%@", error.localizedDescription);
    }

    // -------------------------------------------------------------------------
    //  Initialize logging
    // -------------------------------------------------------------------------
    [PFCLog configureLoggingForSession:kPFCSessionTypeGUI];

    // -------------------------------------------------------------------------
    //  Initialize main window
    // -------------------------------------------------------------------------
    [self setMainWindowController:[[PFCMainWindow alloc] init]];

    // -------------------------------------------------------------------------
    //  Initialize application menus
    // -------------------------------------------------------------------------
    [self setMenuItemActions];

    // -------------------------------------------------------------------------
    //  Show main window
    // -------------------------------------------------------------------------
    [_mainWindowController.window makeKeyAndOrderFront:self];
} // applicationWillFinishLaunching

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MenuItem Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setMenuItemActions {

    // -------------------------------------------------------------------------
    //  Get main menu
    // -------------------------------------------------------------------------
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];

    // -------------------------------------------------------------------------
    //  Get application menu item submenu
    // -------------------------------------------------------------------------
    NSMenu *applicationMenu = [[mainMenu itemAtIndex:0] submenu];

    // -------------------------------------------------------------------------
    //  Set action for menu item "Preferences…"
    // -------------------------------------------------------------------------
    NSString *preferencesTitle = [NSString stringWithFormat:@"Preferences%C", (unichar)0x2026];
    NSMenuItem *preferencesMenuItem = [applicationMenu itemWithTitle:preferencesTitle];
    if (preferencesMenuItem) {
        [preferencesMenuItem setTarget:self];
        [preferencesMenuItem setAction:@selector(menuItemPreferences:)];
    }

    // -------------------------------------------------------------------------
    //  Get window menu item submenu
    // -------------------------------------------------------------------------
    NSMenu *windowMenu = [[mainMenu itemAtIndex:5] submenu];

    // -------------------------------------------------------------------------
    //  Set action for menu item "Main Window"
    // -------------------------------------------------------------------------
    NSMenuItem *mainWindowMenuItem = [windowMenu itemWithTitle:@"Main Window"];
    if (mainWindowMenuItem) {
        [mainWindowMenuItem setTarget:self];
        [mainWindowMenuItem setAction:@selector(menuItemMainWindow:)];
    }

} // setMenuItemActions

- (void)menuItemPreferences:(id)sender {
    if (!self.preferences) {
        [self setPreferences:[[PFCPreferences alloc] init]];
    }

    [self.preferences.window makeKeyAndOrderFront:self];
} // menuItemPreferences

- (void)menuItemMainWindow:(id)sender {
    if (self.mainWindowController) {
        [self.mainWindowController.window makeKeyAndOrderFront:self];
    }
} // menuItemMainWindow

@end

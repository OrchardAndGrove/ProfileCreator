//
//  PFCMainWindowToolbarItemExport.m
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
#import "PFCMainWindowToolbarItemExport.h"

NSString *_Nonnull const PFCMainWindowToolbarItemIdentifierExport = @"Export";

@interface PFCMainWindowToolbarItemExport ()
@property (nonatomic, strong, readwrite, nonnull) NSToolbarItem *toolbarItem;
@property (nonatomic, strong, nonnull) NSImageView *disclosureTriangle;
@end

@implementation PFCMainWindowToolbarItemExport

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init {
    self = [super init];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Create the size of the toolbar item
        // ---------------------------------------------------------------------
        NSRect toolbarItemRect = NSMakeRect(0.0, 0.0, 40.0, 32.0);
        [self setFrame:toolbarItemRect];

        // ---------------------------------------------------------------------
        //  Create the button instance and add it to the toolbar item view
        // ---------------------------------------------------------------------
        PFCMainWindowToolbarItemExportButton *button = [[PFCMainWindowToolbarItemExportButton alloc] initWithFrame:toolbarItemRect];
        [self addSubview:button];

        // ---------------------------------------------------------------------
        //  Create the disclosure triangle overlay and add it to the toolbar item view
        // ---------------------------------------------------------------------
        NSImageView *disclosureTriangle = [[NSImageView alloc] init];
        [disclosureTriangle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [disclosureTriangle setImage:[NSImage imageNamed:@"downarrow"]];
        [disclosureTriangle setImageScaling:NSImageScaleProportionallyUpOrDown];
        [disclosureTriangle.widthAnchor constraintEqualToConstant:3];
        [disclosureTriangle.heightAnchor constraintEqualToConstant:3];
        [disclosureTriangle setHidden:YES];
        _disclosureTriangle = disclosureTriangle;

        // ---------------------------------------------------------------------
        //  Add disclosure triangle to button view
        // ---------------------------------------------------------------------
        [self addSubview:disclosureTriangle];

        // ---------------------------------------------------------------------
        //  Setup the disclosure triangle view
        // ---------------------------------------------------------------------
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        [self setupDisclosureTriangle:constraints];
        [NSLayoutConstraint activateConstraints:constraints];

        // ---------------------------------------------------------------------
        //  Create the actual toolbar item and set it's view
        // ---------------------------------------------------------------------
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PFCMainWindowToolbarItemIdentifierExport];
        [toolbarItem setToolTip:NSLocalizedString(@"Export profile", @"")];
        [toolbarItem setView:self];
        _toolbarItem = toolbarItem;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setupDisclosureTriangle:(NSMutableArray *_Nonnull)constraints {

    // -------------------------------------------------------------------------
    //  Add constraints for Disclosure Triangle View
    // -------------------------------------------------------------------------

    // Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_disclosureTriangle
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:6]];

    // Height == Width
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_disclosureTriangle
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_disclosureTriangle
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0]];

    // Bottom
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_disclosureTriangle
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:5]];

    // Trailing
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_disclosureTriangle
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:3]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showDisclosureTriangle:(id _Nonnull)sender {
    [self.disclosureTriangle setHidden:NO];
}
- (void)hideDisclosureTriangle:(id _Nonnull)sender {
    [self.disclosureTriangle setHidden:YES];
}

@end

@interface PFCMainWindowToolbarItemExportButton ()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong, nonnull) NSMenu *buttonMenu;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL mouseIsDown;
@property (nonatomic) BOOL menuWasShownForLastMouseDown;
@property int mouseDownUniquenessCounter;
@end

@implementation PFCMainWindowToolbarItemExportButton

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(profileSelectionDidChange:) name:PFCProfileSelectionDidChangeNotification object:nil];

        // ---------------------------------------------------------------------
        //  Setup Self (Toolbar Item)
        // ---------------------------------------------------------------------
        [self setBezelStyle:NSTexturedRoundedBezelStyle];
        [self setImage:[NSImage imageNamed:NSImageNameShareTemplate]];
        [self setTarget:self];
        [self setAction:@selector(buttonClicked:)];
        [[self cell] setImageScaling:NSImageScaleProportionallyDown];
        [self setImagePosition:NSImageOnly];
        [self setEnabled:NO];
        _isEnabled = NO;

        // ---------------------------------------------------------------------
        //  Setup the button menu
        // ---------------------------------------------------------------------
        [self setupMenu];
    }
    return self;
}

- (void)dealloc {

    // -------------------------------------------------------------------------
    //  Deregister for notification
    // -------------------------------------------------------------------------
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PFCProfileSelectionDidChangeNotification object:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Menu Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setupMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu setDelegate:self];

    // -------------------------------------------------------------------------
    //  Add item: "Export Profile"
    // -------------------------------------------------------------------------
    NSMenuItem *menuItemNewProfile = [[NSMenuItem alloc] init];
    [menuItemNewProfile setTitle:NSLocalizedString(@"Export Profile", @"")];
    [menuItemNewProfile setEnabled:YES];
    [menuItemNewProfile setTarget:self];
    [menuItemNewProfile setAction:@selector(exportProfile)];
    [menu addItem:menuItemNewProfile];

    _buttonMenu = menu;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)profileSelectionDidChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *profileIdentifiers = userInfo[PFCNotificationUserInfoProfileIdentifiers];

    // FIXME - Did a quick test of binding to self and isEnabled, but didn't work.
    // Maybe need to expose bindings? this works for now
    if (profileIdentifiers.count == 1) {
        [self setIsEnabled:YES];
        [self setEnabled:YES];
    } else {
        [self setIsEnabled:NO];
        [self setEnabled:NO];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)exportProfile {
    [[NSNotificationCenter defaultCenter] postNotificationName:PFCExportProfileNotification object:self userInfo:@{PFCNotificationUserInfoParentTitle : PFCMainWindowOutlineViewParentTitleLibrary}];
}

- (void)buttonClicked:(NSButton *)button {
    if (self.isEnabled) {

        // -------------------------------------------------------------------------
        //  If the button is clicked (without the context menu), send exportProfile
        // -------------------------------------------------------------------------
        [self exportProfile];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSControl/NSResponder Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)mouseEntered:(NSEvent *)theEvent {
    if (self.isEnabled) {
        [(PFCMainWindowToolbarItemExport *)self.superview showDisclosureTriangle:self];
    }
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    if (!self.mouseIsDown) {
        [(PFCMainWindowToolbarItemExport *)self.superview hideDisclosureTriangle:self];
    }
} // mouseExited

- (void)mouseDown:(NSEvent *)theEvent {

    // -------------------------------------------------------------------------
    //  Reset variables
    // -------------------------------------------------------------------------
    [self setMouseIsDown:YES];
    [self setMenuWasShownForLastMouseDown:NO];
    self.mouseDownUniquenessCounter++;
    int mouseDownUniquenessCounterCopy = self.mouseDownUniquenessCounter;

    // -------------------------------------------------------------------------
    //  Show the button is being pressed
    // -------------------------------------------------------------------------
    [self highlight:YES];

    // -------------------------------------------------------------------------
    //  Wait 'delayInSeconds' before showing the context menu
    //  If button has been released before time runs out, it's considered a normal button press
    // -------------------------------------------------------------------------
    float delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
      if (self.mouseIsDown && mouseDownUniquenessCounterCopy == self.mouseDownUniquenessCounter) {
          [self setMenuWasShownForLastMouseDown:YES];
          NSRect frame = [self frame];
          NSPoint menuOrigin = [[self superview] convertPoint:NSMakePoint(frame.origin.x + frame.size.width - 16, frame.origin.y + 2) toView:nil];
          NSEvent *event = [NSEvent mouseEventWithType:theEvent.type
                                              location:menuOrigin
                                         modifierFlags:theEvent.modifierFlags
                                             timestamp:theEvent.timestamp
                                          windowNumber:theEvent.windowNumber
                                               context:theEvent.context
                                           eventNumber:theEvent.eventNumber
                                            clickCount:theEvent.clickCount
                                              pressure:theEvent.pressure];

          [NSMenu popUpContextMenu:self.buttonMenu withEvent:event forView:self];
      }
    });

} // mouseDown

- (void)mouseUp:(NSEvent *)theEvent {
    [self setMouseIsDown:NO];

    if (!self.menuWasShownForLastMouseDown) {
        [(PFCMainWindowToolbarItemExport *)self.superview hideDisclosureTriangle:self];
        [self sendAction:self.action to:self.target];
    }

    [self highlight:NO];
} // mouseUp

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updateTrackingAreas {
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }

    NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil]];
    [self addTrackingArea:self.trackingArea];
} // updateTrackingAreas

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSMenuDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)menuDidClose:(NSMenu *)menu {

    [self setMouseIsDown:NO];
    [self setMenuWasShownForLastMouseDown:NO];

    // -------------------------------------------------------------------------
    //  Turn of highlighting and disclosure triangle when the menu closes
    // -------------------------------------------------------------------------
    [self highlight:NO];
    [(PFCMainWindowToolbarItemExport *)self.superview hideDisclosureTriangle:self];
} // menuDidClose

@end

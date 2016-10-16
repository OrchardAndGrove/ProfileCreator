//
//  PFCAlert.m
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

@interface PFCAlert ()
@property (nonatomic, strong, nullable) NSAlert *alert;
@property (nonatomic, readwrite, strong, nullable) NSTextField *textFieldInput;
@property (nonatomic, readwrite, strong, nullable) NSButton *firstButton;
@property (nonatomic, readwrite, strong, nullable) NSButton *secondButton;
@property (nonatomic, readwrite, strong, nullable) NSButton *thirdButton;
@end

@implementation PFCAlert

- (void)showAlertDeleteWithMessage:(NSString *_Nonnull)message
                   informativeText:(NSString *_Nullable)informativeText
                            window:(NSWindow *_Nonnull)window
                      shouldDelete:(void (^_Nonnull)(BOOL))shouldDelete {

    // -------------------------------------------------------------------------
    //  Create alert
    // -------------------------------------------------------------------------
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];

    // -------------------------------------------------------------------------
    //  Add buttons
    // -------------------------------------------------------------------------
    // NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleCancel];

    // NSAlertSecondButton
    [alert addButtonWithTitle:PFCButtonTitleDelete];

    // -------------------------------------------------------------------------
    //  Add message
    // -------------------------------------------------------------------------
    [alert setMessageText:message];
    if (informativeText.length != 0) {
        [alert setInformativeText:informativeText];
    }

    // -------------------------------------------------------------------------
    //  Set instance variables for alert
    // -------------------------------------------------------------------------
    [self setAlert:alert];
    [self setFirstButton:alert.buttons.firstObject];
    [self setSecondButton:alert.buttons.lastObject];

    // -------------------------------------------------------------------------
    //  Show modal alert in window
    // -------------------------------------------------------------------------
    [self.alert beginSheetModalForWindow:window
                       completionHandler:^(NSInteger returnCode) {
                         if (returnCode == NSAlertSecondButtonReturn) {
                             shouldDelete(YES);
                         } else {
                             shouldDelete(NO);
                         }
                       }];
} // showAlertDeleteWithMessage:informativeText:window:shouldDelete

- (void)showAlertErrorWithError:(NSError *_Nonnull)error window:(NSWindow *_Nonnull)window {

    // -------------------------------------------------------------------------
    //  Create alert
    // -------------------------------------------------------------------------
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];

    // -------------------------------------------------------------------------
    //  Add buttons
    // -------------------------------------------------------------------------
    // NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleOK];

    // -------------------------------------------------------------------------
    //  Add message
    // -------------------------------------------------------------------------
    if (error.localizedDescription.length != 0) {
        [alert setMessageText:error.localizedDescription];
    }
    if (error.localizedFailureReason.length != 0) {
        [alert setInformativeText:error.localizedFailureReason];
    }

    // -------------------------------------------------------------------------
    //  Set instance variables for alert
    // -------------------------------------------------------------------------
    [self setAlert:alert];
    [self setFirstButton:alert.buttons.firstObject];

    // -------------------------------------------------------------------------
    //  Show modal alert in window
    // -------------------------------------------------------------------------
    [self.alert beginSheetModalForWindow:window
                       completionHandler:^(NSInteger returnCode){
                           // Unused
                       }];
} // showAlertErrorWithError:window

- (void)showAlertTextInputWithMessage:(NSString *_Nonnull)message
                      informativeText:(NSString *_Nullable)informativeText
                               window:(NSWindow *_Nonnull)window
                        defaultString:(NSString *_Nullable)defaultString
                    placeholderString:(NSString *_Nullable)placeholderString
                     firstButtonTitle:(NSString *_Nonnull)firstButtonTitle
                    secondButtonTitle:(NSString *_Nullable)secondButtonTitle
                     thirdButtonTitle:(NSString *_Nullable)thirdButtonTitle
              firstButtonInitialState:(BOOL)firstButtonInitialState
                               sender:(id<NSTextFieldDelegate> _Nonnull)sender
                          returnValue:(void (^_Nonnull)(NSString *_Nullable, NSInteger))returnValue {

    // -------------------------------------------------------------------------
    //  Create alert
    // -------------------------------------------------------------------------
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];

    // -------------------------------------------------------------------------
    //  Add buttons
    // -------------------------------------------------------------------------
    // NSAlertFirstButton
    [alert addButtonWithTitle:firstButtonTitle];
    [self setFirstButton:alert.buttons.firstObject];
    [self.firstButton setEnabled:firstButtonInitialState];

    // NSAlertSecondButton
    if (secondButtonTitle.length != 0) {
        [alert addButtonWithTitle:secondButtonTitle];
        [self setSecondButton:alert.buttons[1]];
    }

    // NSAlertThirdButton
    if (secondButtonTitle.length != 0 && thirdButtonTitle.length != 0) {
        [alert addButtonWithTitle:thirdButtonTitle];
        [self setThirdButton:alert.buttons[2]];
    }

    // -------------------------------------------------------------------------
    //  Add message
    // -------------------------------------------------------------------------
    [alert setMessageText:message];
    if (informativeText.length != 0) {
        [alert setInformativeText:informativeText];
    }

    // -------------------------------------------------------------------------
    //  Add accessory view TextField
    // -------------------------------------------------------------------------
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 292, 22)];
    if (sender != nil) {
        [textField setDelegate:sender];
    }

    if (defaultString.length != 0) {
        [textField setStringValue:defaultString];
    } else if (textField.delegate != nil) {
        [alert.buttons.firstObject setEnabled:NO];
    }

    if (placeholderString.length != 0) {
        [textField setPlaceholderString:placeholderString];
    }

    [alert setAccessoryView:textField];

    // -------------------------------------------------------------------------
    //  Set instance variables for alert
    // -------------------------------------------------------------------------
    [self setAlert:alert];
    [self setTextFieldInput:textField];

    // -------------------------------------------------------------------------
    //  Show modal alert in window
    // -------------------------------------------------------------------------
    [self.alert beginSheetModalForWindow:window
                       completionHandler:^(NSInteger returnCode) {
                         returnValue([textField stringValue], returnCode);
                       }];
} // showAlertTextInputWithMessage:informativeText:window:defaultString:placeholderString:firstButtonTitle:secondButtonTitle:thirdButtonTitle:firstButtonInitialState:sender:returnValue

- (void)showAlertUnsavedChangesWithMessage:(NSString *_Nonnull)message
                           informativeText:(NSString *_Nullable)informativeText
                                    window:(NSWindow *_Nonnull)window
                                returnCode:(void (^_Nonnull)(NSInteger))returnCode {

    // -------------------------------------------------------------------------
    //  Create alert
    // -------------------------------------------------------------------------
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];

    // -------------------------------------------------------------------------
    //  Add buttons
    // -------------------------------------------------------------------------
    // NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleSaveAndClose];

    // NSAlertSecondButton
    [alert addButtonWithTitle:PFCButtonTitleClose];

    // NSAlertThirdButton
    [alert addButtonWithTitle:PFCButtonTitleCancel];

    // -------------------------------------------------------------------------
    //  Add message
    // -------------------------------------------------------------------------
    [alert setMessageText:message];
    if (informativeText.length != 0) {
        [alert setInformativeText:informativeText];
    }

    // -------------------------------------------------------------------------
    //  Set instance variables for alert
    // -------------------------------------------------------------------------
    [self setAlert:alert];
    [self setFirstButton:alert.buttons.firstObject];
    [self setSecondButton:alert.buttons[1]];
    [self setThirdButton:alert.buttons[2]];

    // -------------------------------------------------------------------------
    //  Show modal alert in window
    // -------------------------------------------------------------------------
    [self.alert beginSheetModalForWindow:window
                       completionHandler:^(NSInteger buttonReturnCode) {
                         returnCode(buttonReturnCode);
                       }];
} // showAlertUnsavedChangesWithMessage:informativeText:window:returnCode

@end

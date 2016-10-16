//
//  PFCAlert.h
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

#import <Cocoa/Cocoa.h>

@interface PFCAlert : NSObject <NSTextFieldDelegate>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, readonly, strong, nullable) NSAlert *alert;
@property (nonatomic, readonly, strong, nullable) NSTextField *textFieldInput;
@property (nonatomic, readonly, strong, nullable) NSButton *firstButton;
@property (nonatomic, readonly, strong, nullable) NSButton *secondButton;
@property (nonatomic, readonly, strong, nullable) NSButton *thirdButton;
@property (nonatomic, copy, nullable) NSArray *textInputUnallowedStrings;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showAlertDeleteWithMessage:(NSString *_Nonnull)message informativeText:(NSString *_Nullable)informativeText window:(NSWindow *_Nonnull)window shouldDelete:(void (^_Nonnull)(BOOL))shouldDelete;

- (void)showAlertErrorWithError:(NSError *_Nonnull)error window:(NSWindow *_Nonnull)window;

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
                          returnValue:(void (^_Nonnull)(NSString *_Nullable, NSInteger))returnValue;

- (void)showAlertUnsavedChangesWithMessage:(NSString *_Nonnull)message
                           informativeText:(NSString *_Nullable)informativeText
                                    window:(NSWindow *_Nonnull)window
                                returnCode:(void (^_Nonnull)(NSInteger))returnCode;

@end

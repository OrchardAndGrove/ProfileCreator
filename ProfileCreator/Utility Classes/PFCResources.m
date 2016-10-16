//
//  PFCResources.m
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

#import "PFCResources.h"

@implementation PFCResources

+ (NSURL *)folder:(PFCFolder)folder {
    if (folder == NSNotFound) {
        return nil;
    }

    switch (folder) {
    case kPFCFolderUserApplicationSupport: {
        NSURL *userApplicationSupport = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        return [userApplicationSupport URLByAppendingPathComponent:@"ProfileCreator"];
    } break;

    case kPFCFolderProfiles: {
        return [[self.class folder:kPFCFolderUserApplicationSupport] URLByAppendingPathComponent:@"Profiles"];
    } break;

    case kPFCFolderGroups: {
        return [[self.class folder:kPFCFolderUserApplicationSupport] URLByAppendingPathComponent:@"Groups"];
    } break;

    case kPFCFolderGroupsLibrary: {
        return [[self.class folder:kPFCFolderGroups] URLByAppendingPathComponent:@"Library"];
    } break;

    case kPFCFolderGroupsSmartGroups: {
        return [[self.class folder:kPFCFolderGroups] URLByAppendingPathComponent:@"SmartGroups"];
    } break;
    }
}

@end

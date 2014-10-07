//
//  AppDelegate.m
//  imgurshot
//
//  Created by Nick Kezhaya on 10/7/14.
//  Copyright (c) 2014 WPC. All rights reserved.
//

#import "AppDelegate.h"
#import "DDHotKeyCenter.h"
#import "MLIMGURUploader.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.pasteboard = [NSPasteboard generalPasteboard];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:nil];
    [self.statusItem setImage:[NSImage imageNamed:@"Icon"]];
    [self.statusItem setHighlightMode:YES];
    
    // Command + Shift + 5
    DDHotKeyCenter *center = [DDHotKeyCenter sharedHotKeyCenter];
    [center registerHotKeyWithKeyCode:0x17 modifierFlags:(NSCommandKeyMask | NSShiftKeyMask) target:self action:@selector(beginScreenCapture) object:nil];
}

- (void)beginScreenCapture
{
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/screencapture"
                              arguments:[NSArray arrayWithObjects:@"-ic", nil]] waitUntilExit];
    
    NSData *image = [[NSPasteboard generalPasteboard] dataForType:NSPasteboardTypePNG];
    
    [MLIMGURUploader uploadPhoto:image
                           title:nil
                     description:nil
                   imgurClientID:@"32ea9cecdcd5fda"
                 completionBlock:^(NSString *result) {
                     [self writeToPasteBoard:result];
                     [NSTask launchedTaskWithLaunchPath:@"/usr/bin/afplay" arguments:@[@"/System/Library/Sounds/Ping.aiff"]];
                 }
                    failureBlock:nil];
}

- (BOOL)writeToPasteBoard:(NSString *)stringToWrite
{
    [self.pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    return [self.pasteboard setString:stringToWrite forType:NSStringPboardType];
}

@end

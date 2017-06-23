//
//  AppDelegate.m
//  imgurshot
//
//  Created by Nick Kezhaya on 10/7/14.
//  Copyright (c) 2014 WPC. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "AppDelegate.h"
#import "DDHotKeyCenter.h"
#import "MLIMGURUploader.h"

#define MODE_KEY @"MODE"

#define MODE_CLIPBOARD_ONLY 0
#define MODE_UPLOAD_IMGUR 1

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.pasteboard = [NSPasteboard generalPasteboard];

    NSImage *icon = [NSImage imageNamed:@"Icon"];
    [icon setTemplate:YES];

    [[self.statusMenu.itemArray objectAtIndex:2] setAction:@selector(copyLowWidthSpace)];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:nil];
    [self.statusItem setImage:icon];
    [self.statusItem setHighlightMode:YES];

    [self setMenuState];

    // Command + Shift + 5
    DDHotKeyCenter *center = [DDHotKeyCenter sharedHotKeyCenter];
    [center registerHotKeyWithKeyCode:kVK_ANSI_5 modifierFlags:(NSCommandKeyMask | NSShiftKeyMask) target:self action:@selector(beginScreenCapture) object:nil];
    [center registerHotKeyWithKeyCode:kVK_ANSI_6 modifierFlags:(NSCommandKeyMask | NSShiftKeyMask) target:self action:@selector(copyLowWidthSpace) object:nil];
}

- (void)beginScreenCapture
{
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/screencapture"
                              arguments:[NSArray arrayWithObjects:@"-ic", nil]] waitUntilExit];

    if (![self shouldUpload]) {
        [self playSound];
        return;
    }

    NSData *image = [[NSPasteboard generalPasteboard] dataForType:NSPasteboardTypePNG];
    
    [MLIMGURUploader uploadPhoto:image
                           title:nil
                     description:nil
                   imgurClientID:@"32ea9cecdcd5fda"
                 completionBlock:^(NSString *result) {
                     [self writeToPasteBoard:[result stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
                     [self playSound];
                 }
                    failureBlock:nil];
}

- (void)playSound
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/afplay" arguments:@[@"/System/Library/Sounds/Ping.aiff"]];
}

- (void)copyLowWidthSpace
{
    [self.pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [self.pasteboard setString:@" " forType:NSStringPboardType];
}

- (BOOL)writeToPasteBoard:(NSString *)stringToWrite
{
    [self.pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    return [self.pasteboard setString:stringToWrite forType:NSStringPboardType];
}

- (IBAction)copyToClipboardSelected:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:MODE_CLIPBOARD_ONLY forKey:MODE_KEY];
    [self setMenuState];
}

- (IBAction)uploadToImgurSelected:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:MODE_UPLOAD_IMGUR forKey:MODE_KEY];
    [self setMenuState];
}

- (void)setMenuState {
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:MODE_KEY];

    switch (mode) {
        case MODE_CLIPBOARD_ONLY:
            [[self.statusMenu itemWithTag:2] setState:1];
            [[self.statusMenu itemWithTag:3] setState:0];
            break;
        case MODE_UPLOAD_IMGUR:
            [[self.statusMenu itemWithTag:2] setState:0];
            [[self.statusMenu itemWithTag:3] setState:1];
            break;
        default:
            break;
    }
}

- (BOOL)shouldUpload
{
    return [self.statusMenu itemWithTag:3].state == 1;
}

@end

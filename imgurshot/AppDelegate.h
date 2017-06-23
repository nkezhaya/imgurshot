//
//  AppDelegate.h
//  imgurshot
//
//  Created by Nick Kezhaya on 10/7/14.
//  Copyright (c) 2014 WPC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSPasteboard *pasteboard;

@end

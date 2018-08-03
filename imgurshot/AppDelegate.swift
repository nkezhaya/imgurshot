//
//  AppDelegate.swift
//  imgurshot
//
//  Created by Nick Kezhaya on 8/3/18.
//  Copyright © 2018 WPC. All rights reserved.
//

import Foundation
import Carbon

let MODE_KEY = "MODE"
let MODE_CLIPBOARD_ONLY = 0
let MODE_UPLOAD_IMGUR = 1

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var statusMenu: NSMenu!
    var statusItem: NSStatusItem!
    var pasteboard: NSPasteboard = NSPasteboard.general()

    var currentMode: Int? {
        get {
            return UserDefaults.standard.integer(forKey: MODE_KEY)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: MODE_KEY)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: "Icon")
        icon?.isTemplate = true
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.menu = statusMenu
        statusItem.title = nil
        statusItem.image = icon
        statusItem.highlightMode = true
        setMenuState()
        registerKeyListener()
    }

    // MARK: Mode menu

    @IBAction func setModeCopyToClipboard(_ sender: Any) {
        currentMode = MODE_CLIPBOARD_ONLY
        setMenuState()
        registerKeyListener()
    }

    @IBAction func setModeUploadToImgur(_ sender: Any) {
        currentMode = MODE_UPLOAD_IMGUR
        setMenuState()
        registerKeyListener()
    }

    // MARK: Convenience actions

    @IBAction func copyZeroWidthSpace(_ sender: Any) {
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(" ", forType: NSPasteboardTypeString)
    }

    @IBAction func copyLowWidthSpace(_ sender: Any) {
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(" ", forType: NSPasteboardTypeString)
    }

    @IBAction func killallDock(_ sender: Any) {
        Process.launchedProcess(launchPath: "/usr/bin/killall", arguments: ["Dock"])
    }
}

// MARK - Helpers

private extension AppDelegate {
    @objc func beginScreenCapture() {
        switch currentMode {
        case MODE_CLIPBOARD_ONLY:
            Process.launchedProcess(launchPath: "/usr/sbin/screencapture", arguments: ["-ic"]).waitUntilExit()
            playSound()
        case MODE_UPLOAD_IMGUR:
            Process.launchedProcess(launchPath: "/usr/sbin/screencapture", arguments: ["-ic"]).waitUntilExit()
            let image: Data? = NSPasteboard.general().data(forType: NSPasteboardTypePNG)
            MLIMGURUploader.uploadPhoto(image, title: nil, description: nil, imgurClientID: "32ea9cecdcd5fda", completionBlock: { result in
                self.write(toPasteBoard: result?.replacingOccurrences(of: "http://", with: "https://"))
                self.playSound()
            }, failureBlock: nil)
        default:
            break
        }
    }

    func playSound() {
        Process.launchedProcess(launchPath: "/usr/bin/afplay", arguments: ["/System/Library/Sounds/Ping.aiff"])
    }

    @discardableResult
    func write(toPasteBoard stringToWrite: String?) -> Bool {
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        return pasteboard.setString(stringToWrite ?? "", forType: NSPasteboardTypeString)
    }

    func setMenuState() {
        switch currentMode {
        case MODE_CLIPBOARD_ONLY:
            statusMenu.item(withTag: 3)?.state = 1
            statusMenu.item(withTag: 4)?.state = 0
        case MODE_UPLOAD_IMGUR:
            statusMenu.item(withTag: 3)?.state = 0
            statusMenu.item(withTag: 4)?.state = 1
        default:
            break
        }
    }

    func shouldUpload() -> Bool {
        return currentMode == MODE_UPLOAD_IMGUR
    }

    func registerKeyListener() {
        // Command + Shift + 2
        _ = DDHotKeyCenter.shared()?.registerHotKey(withKeyCode: UInt16(kVK_ANSI_2),
                                                    modifierFlags: NSCommandKeyMask.rawValue | NSShiftKeyMask.rawValue,
                                                    target: self,
                                                    action: #selector(beginScreenCapture),
                                                    object: nil)
    }
}

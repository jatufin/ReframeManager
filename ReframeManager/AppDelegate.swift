//
//  AppDelegate.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 6.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import Cocoa
import SwiftUI

let DEFAULT_WIDTH = 800
let DEFAULT_HEIGHT = 600

let MIN_WIDTH: CGFloat = 600
let MIN_HEIGHT: CGFloat = 300

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var directory = Directory()
    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(directory: directory)
            .frame(minWidth: MIN_WIDTH, minHeight: MIN_HEIGHT)
        
        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: DEFAULT_WIDTH, height: DEFAULT_HEIGHT),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    @IBAction func Open(_ sender: Any) {
        DirectorySelectorView.openWorkDir(directory)
    }
    
    @IBAction func selectPlayer(_ sender: Any) {
        DirectorySelectorView.openPlayerDir(directory)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


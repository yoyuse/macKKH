//
//  AppDelegate.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/02.
//

import Cocoa
import InputMethodKit

// MARK: - global var

private var server: IMKServer?

// MARK: - main

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        guard let name = Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String else { return }
        server = IMKServer(name: name, bundleIdentifier: Bundle.main.bundleIdentifier)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}


//
//  AppDelegate.swift
//  ImageUtilNew
//
//  Created by Juergen Baumann on 27.12.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
    // set default timezone
    NSTimeZone.default = TimeZone(secondsFromGMT: +0)!
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
  
  func applicationShouldHandleReopen(theApplication: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      for window: AnyObject in theApplication.windows {
        window.makeKeyAndOrderFront(self)
      }
    }
    return true
  }

}


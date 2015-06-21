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

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
    // set default timezone
    NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: +0))
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

}


//
//  AppDelegate.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 14.09.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var debugLog: NSTextField!
  var imageFolder : NSURL?


  func applicationDidFinishLaunching(aNotification: NSNotification?) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(aNotification: NSNotification?) {
    // Insert code here to tear down your application
  }

  @IBAction func selectImageFolder(sender: NSButton) {
    var openPanel = NSOpenPanel()
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false
    
    if openPanel.runModal() == NSOKButton
    {
      imageFolder = openPanel.URLs[0] as? NSURL
      println("openPanel: \(openPanel.URLs)")
    }
    debugLog.stringValue = imageFolder?.description
  }

}


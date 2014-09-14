//
//  AppDelegate.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 14.09.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

  var imageFolder : NSURL?
  let fm = NSFileManager.defaultManager()
  
  
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var debugLog: NSTextField!
  @IBOutlet weak var fileListTableView: NSTableView!
 

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
      let x : NSURL = openPanel.directoryURL
      println("openPanel: \(openPanel.URLs)")
      println("imageFolder: \(imageFolder)")
      readMetaDataOfFilesInDirectory(imageFolder!)
      
    }
    debugLog.stringValue = imageFolder?.description
  }
  
  func numberOfRowsInTableView(aTableView: NSTableView!) -> Int
  {
    //let numberOfRows:Int = 20
    let numberOfRows:Int = getDataArray().count
    return numberOfRows
  }
  
  func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
    let identifier = viewForTableColumn.identifier
    var cell = fileListTableView.makeViewWithIdentifier(identifier, owner: self) as NSTableCellView
    cell.textField.stringValue = getDataArray().objectAtIndex(row).objectForKey(identifier) as String
    return cell;
  }
  
  func getDataArray () -> NSArray {
    var dataArray:[NSDictionary] = [["FileName": "Debasis", "Date": "Das"],
      ["FileName": "Nishant", "Date": "Singh"],
      ["FileName": "John", "Date": "Doe"],
      ["FileName": "Jane", "Date": "Doe"],
      ["FileName": "Mary", "Date": "Jane"]]
    return dataArray
  }
  
  func readMetaDataOfFilesInDirectory(dir:NSURL) {
    let contents : NSArray = fm.contentsOfDirectoryAtURL(imageFolder!, includingPropertiesForKeys: nil, options: nil, error: nil)!
    for content in contents {
      println("\(content)")
    }

  }
  
  func parse(dateStr:String, format:String="yyyy-MM-dd") -> NSDate {
    var dateFmt = NSDateFormatter()
    dateFmt.timeZone = NSTimeZone.defaultTimeZone()
    dateFmt.dateFormat = format
    return dateFmt.dateFromString(dateStr)!
  }
  
  func getDateTime(imageSource:CGImageSource) -> NSDate {
    let uint:UInt = UInt.min
    let metadataAtIndex = CGImageSourceCopyMetadataAtIndex(imageSource, uint, nil)
    var imageDict : Dictionary  = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
    let tiff : AnyObject = imageDict["{TIFF}"]!
    let dateTime : String = tiff["DateTime"] as String
    println("TypeName of dateTime = \(_stdlib_getTypeName(dateTime))")
    println("dateTime:\(dateTime)")
    return parse(dateTime, format:"yyyy:MM:dd HH:mm:ss")
    
  }

}


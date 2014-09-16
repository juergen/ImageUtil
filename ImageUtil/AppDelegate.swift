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
  var imageFileData : [NSDictionary] = []
  let fm = NSFileManager.defaultManager()
  
  
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var debugLog: NSTextField!
  @IBOutlet weak var fileListTableView: NSTableView!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
 

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
    
    if openPanel.runModal() == NSOKButton    {
      imageFolder = openPanel.URLs[0] as? NSURL
      let x : NSURL = openPanel.directoryURL
      println("openPanel: \(openPanel.URLs)")
      println("imageFolder: \(imageFolder)")
      readMetaDataOfFilesInDirectory(imageFolder!)
      fileListTableView.reloadData()
      
    }
    debugLog.stringValue = imageFolder?.description
  }
  
  func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
    return imageFileData.count
  }
  
  func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
    let identifier = viewForTableColumn.identifier
    var cell = fileListTableView.makeViewWithIdentifier(identifier, owner: self) as NSTableCellView
    var value = imageFileData[row].objectForKey(identifier) as? String
    if (value == nil) {
      value = "./."
    }
    cell.textField.stringValue = value
    return cell;
  }
  
  func readMetaDataOfFilesInDirectory(dir:NSURL) {
    //
    progressIndicator.doubleValue = 1
    progressIndicator.startAnimation(self)
    //
    self.progressIndicator.startAnimation(self)
    let contents : [NSURL] = fm.contentsOfDirectoryAtURL(imageFolder!,
      includingPropertiesForKeys: [NSURLCreationDateKey],
      options: .SkipsHiddenFiles,
      error: nil) as [NSURL]
    //
    let count = contents.count
    imageFileData = []
    for (index, content : NSURL) in enumerate(contents) {
      let progress : Double = 100 * (Double(index + 1) / Double(count))
      println("progress: \(progress)")
      progressIndicator.doubleValue = progress
      println("nsurl: \(content.path)")
      let cachedValues : Dictionary = content.resourceValuesForKeys([NSURLCreationDateKey], error: nil)!
      let fileCreateDate : NSDate = cachedValues[NSURLCreationDateKey] as NSDate
      let source = CGImageSourceCreateWithURL(content, nil)
      if (nil == source) { continue }
      imageFileData.append([
        "FileName": content.lastPathComponent,
        "ImageDate": getDateTime(source).description,
        "FileDate": fileCreateDate.description
        ]
      )
    }
    progressIndicator.stopAnimation(self)

  }
  
  func parse(dateStr:String, format:String="yyyy-MM-dd") -> NSDate {
    var dateFmt = NSDateFormatter()
    dateFmt.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    dateFmt.dateFormat = format
    let date = dateFmt.dateFromString(dateStr)!
    //println("\(dateStr) -> \(date)")
    return date
  }
  
  func getDateTime(imageSource:CGImageSource) -> NSDate {
    // return parse("2000:01:01 00:00:00", format:"yyyy:MM:dd HH:mm:ss")
    let uint:UInt = UInt.min
    let metadataAtIndex = CGImageSourceCopyMetadataAtIndex(imageSource, uint, nil)
    var imageDict : Dictionary  = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
//    for value in imageDict.keys {
//      println("value: \(value)")
//    }
    var tiff : AnyObject = imageDict["{TIFF}"]! // __NSCFDictionary
    println("TypeName of tiff = \(_stdlib_getTypeName(tiff))")
    //
    let dateTime : String = tiff["DateTime"] as String!
    return parse(dateTime, format:"yyyy:MM:dd HH:mm:ss")
  }

}


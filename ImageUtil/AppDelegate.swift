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
	@IBOutlet weak var dateFromSelector: NSMatrix!
	@IBOutlet weak var useNewStartDate: NSButton!
	@IBOutlet weak var newStartDate: NSDatePicker!
	@IBOutlet weak var hours: NSTextField!
	@IBOutlet weak var postfix: NSTextField!
	@IBOutlet weak var appendOriginalName: NSButton!
	
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
		let path : String! = imageFolder?.path!
		debugLog.stringValue = "Pfad: \(path)"
	}
	
	func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
		return imageFileData.count
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
		let identifier = viewForTableColumn.identifier
		var cell = fileListTableView.makeViewWithIdentifier(identifier, owner: self) as NSTableCellView
		var value: AnyObject? = imageFileData[row].objectForKey(identifier)
		if (value! is NSDate) {
			let x = value as NSDate
			cell.textField.stringValue = x.description
		} else if (value is String) {
			cell.textField.stringValue = value as String
		} else {
			cell.textField.stringValue = "./."
		}
		return cell;
	}
	
	@IBAction func rename(sender: NSButton) {
		println("dateFromSelector: \(dateFromSelector.selectedRow)")
		println("useNewStartDate: \(useNewStartDate.state)")
		println("newStartDate: \(newStartDate.dateValue)")
		println("hours: \(hours.stringValue)")
		println("postfix: \(postfix.stringValue)")
		println("appendOriginalName: \(appendOriginalName.state)")
		
		let useImageDate : Bool = (dateFromSelector.selectedRow < 1)
		var dateStrings : Array<String> = []
		for image in imageFileData {
			var counter : Int = 1
			let date : NSDate = image["ImageDate"] as NSDate
			var dateString : String = "\(stringFromDate(date))_\(counter++)"
			while (contains(dateStrings, dateString)) {
				dateString = "\(stringFromDate(date))_\(counter++)"
			}
			dateStrings.append(dateString)
			println("\(dateString)")
		}
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
		imageFileData = [] // used to avoid duplicate new file names
		for (index, url : NSURL) in enumerate(contents) {
			// do we have an image?
			if (!contains(["jped", "jpg"], (url.pathExtension as NSString).lowercaseString)) {
				continue
			}
			println("\(url.pathExtension)")
			let progress : Double = 100 * (Double(index + 1) / Double(count))
			//println("progress: \(progress)")
			progressIndicator.doubleValue = progress
			//println("nsurl: \(url.path)")
			let cachedValues : Dictionary = url.resourceValuesForKeys([NSURLCreationDateKey], error: nil)!
			let fileCreateDate : NSDate = cachedValues[NSURLCreationDateKey] as NSDate
			let source = CGImageSourceCreateWithURL(url, nil)
			if (nil == source) { continue }
			imageFileData.append([
				"FileName": url.lastPathComponent,
				"ImageDate": getDateTime(source),
				"FileDate": fileCreateDate
				]
			)
			if (index < 10) {
				fileListTableView.reloadData()
			}
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
	
	func stringFromDate(date:NSDate) -> String {
		let dateStringFormatter = NSDateFormatter()
		dateStringFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
		return dateStringFormatter.stringFromDate(date)
	}
	
	func getDateTime(imageSource:CGImageSource) -> NSDate {
		let uint:UInt = UInt.min
		let metadataAtIndex = CGImageSourceCopyMetadataAtIndex(imageSource, uint, nil)
		if let imageDict : Dictionary  = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) {
			var tiff : AnyObject = imageDict["{TIFF}"]! // __NSCFDictionary
			if let dt = tiff["DateTime"] as? String {
				return parse(dt, format:"yyyy:MM:dd HH:mm:ss")
			}
		}
		return parse("2000:01:01 00:00:00", format:"yyyy:MM:dd HH:mm:ss")
	}
	
}


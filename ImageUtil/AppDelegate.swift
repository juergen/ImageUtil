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
			cell.textField.stringValue = stringFromDate(value as NSDate)
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
		//
		println("hours.floatValue: \(hours.floatValue)")
		println("hours as float: \((hours.stringValue as NSString).floatValue)")
		//
		let useImageDate : Bool = (dateFromSelector.selectedRow < 1)
		let dateKey:String = useImageDate ? "ImageDate" : "FileDate"
		// hours based offset
		var offset : Double = Double(60 * 60) * Double(hours.floatValue)
		// add new start date based offset
		if (useNewStartDate.state == 1 && imageFileData.count > 0) {
			println("we have a newStartDate!")
			let dateFirstImage: NSDate = imageFileData[0][dateKey] as NSDate
			println("dateFirstImage: \(dateFirstImage)")
			offset += newStartDate.dateValue.timeIntervalSinceDate(dateFirstImage)
		}
		//
		var dateStrings : Array<String> = []
		var renamedImageFileData : [NSDictionary] = []
		// iterate over images
		for image in imageFileData {
			var counter : Int = 1
			var baseDate: NSDate = image[dateKey] as NSDate
			var date = baseDate.dateByAddingTimeInterval(offset)
			// add postfix
			var baseName = stringFromDate(date)
			if (postfix.stringValue != "") {
				baseName += "_\(postfix.stringValue)"
			}
			// ensure name is unique if we have files with same date
			var newFileName = "\(baseName)_\(counter++)"
			while (contains(dateStrings, newFileName)) {
				newFileName = "\(baseName)_\(counter++)"
			}
			dateStrings.append(newFileName)
			// append original name
			if (appendOriginalName.state == 1) {
				var nameWOExtension : String! = image["URL"]?.lastPathComponent
				nameWOExtension = (nameWOExtension as NSString).stringByDeletingPathExtension
				// remove potential previous original file name
				let start = nameWOExtension.startIndex
				if let end = find(nameWOExtension, "(") {
					nameWOExtension = nameWOExtension[start..<end]
				}
				newFileName += "(\(nameWOExtension))"
			}
			// add file extension
			var ext : String! = image["FileName"]?.pathExtension
			ext = (ext as NSString).lowercaseString
			newFileName = "\(newFileName).\(ext)"
			// rename
			let oldPath : String! = image["URL"]?.path
			println("path: \(oldPath)")
			let basePath : String! = (oldPath as NSString).stringByDeletingLastPathComponent
			let newPath : String = basePath.stringByAppendingPathComponent(newFileName)
			println("newPath: \(newPath)")
			fm.moveItemAtPath(oldPath, toPath: newPath, error: nil)
			println("renamed to: \(newFileName)")
		}
		imageFileData = []
		fileListTableView.reloadData()
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
				"FileExtension": url.pathExtension,
				"ImageDate": getDateTime(source),
				"FileDate": fileCreateDate,
				"URL": url
				]
			)
			if (index < 10) {
				fileListTableView.reloadData()
			}
		}
		progressIndicator.stopAnimation(self)
		
	}
	
	func parseImageDate(dateStr:String, format:String="yyyy-MM-dd") -> NSDate {
		var dateFmt = NSDateFormatter()
		dateFmt.timeZone = NSTimeZone()
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
				return parseImageDate(dt, format:"yyyy:MM:dd HH:mm:ss")
			}
		}
		return parseImageDate("2000:01:01 00:00:00", format:"yyyy:MM:dd HH:mm:ss")
	}
	
}


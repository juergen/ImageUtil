//
//  ViewController.swift
//  ImageUtilNew
//
//  Created by Juergen Baumann on 27.12.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
			println("in representedObject")
		}
	}
	
	var imageFolder : NSURL?
	var imageFileData = [[String: AnyObject]]()
	let fm = NSFileManager.defaultManager()
	
	//@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var pathTextField: NSTextField!
	@IBOutlet weak var fileListTableView: NSTableView!
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	@IBOutlet weak var dateFromSelector: NSMatrix!
	@IBOutlet weak var useNewStartDate: NSButton!
	@IBOutlet weak var newStartDate: NSDatePicker!
	@IBOutlet weak var hours: NSTextField!
	@IBOutlet weak var postfix: NSTextField!
	@IBOutlet weak var appendOriginalName: NSButton!
	@IBOutlet weak var openRecentMenu: NSMenu!
	
	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		// Insert code here to initialize your application
	}
	
	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
	}
	
	@IBAction func openDocumentMenu(sender: NSMenuItem) {
		selectFolder()
	}
	
	@IBAction func selectImageFolder(sender: NSButton) {
		selectFolder()
	}
	
	func selectFolder() {
		var openPanel = NSOpenPanel()
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.canCreateDirectories = false
		openPanel.allowsMultipleSelection = false
		//
		var pathString : String! = ""
		if openPanel.runModal() == NSOKButton    {
			imageFolder = openPanel.URLs[0] as? NSURL
			readMetaDataOfFilesInDirectory(imageFolder!)
			fileListTableView.reloadData()
			pathString = imageFolder?.path!
		} else {
			pathString = ""
			clearTable()
		}
		pathTextField.stringValue = NSLocalizedString("Path: ", comment:"Path label") + pathString
	}
	
	func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
		return imageFileData.count
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
		let identifier = viewForTableColumn.identifier
		let cell = fileListTableView.makeViewWithIdentifier(identifier, owner: self) as NSTableCellView
		let value: AnyObject? = imageFileData[row][identifier]
		var stringValue: String
		if (value! is NSDate) {
			stringValue = (value as NSDate).formattedString()
		} else if (value is String) {
			stringValue = value as String
		} else {
			stringValue = "./."
		}
		cell.textField >>- { $0.stringValue = stringValue }
		return cell;
	}
	
	@IBAction func rename(sender: NSButton) {
		//
		progressIndicator.doubleValue = 1
		progressIndicator.startAnimation(self)
		//
		println("dateFromSelector: \(dateFromSelector.selectedRow)")
		println("useNewStartDate: \(useNewStartDate.state)")
		println("newStartDate: \(newStartDate.dateValue)")
		println("hours: \(hours.stringValue)")
		println("postfix: \(postfix.stringValue)")
		println("appendOriginalName: \(appendOriginalName.state)")
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
		// dateStrings is used to ensure unique file names
		var dateStrings : Array<String> = []
		let count = imageFileData.count
		var current : Int = 1
		// iterate over images
		for image in imageFileData {
			progressIndicator.doubleValue = 100 * (Double(current++) / Double(count))
			var counter : Int = 1
			var baseDate: NSDate = image[dateKey] as NSDate
			var date = baseDate.dateByAddingTimeInterval(offset)
			var baseName = date.formattedString()
			// ensure name is unique if we have files with same date
			var newFileName: String = "\(baseName)_\(counter++)"
			while (contains(dateStrings, newFileName)) {
				newFileName = "\(baseName)_\(counter++)"
			}
			dateStrings.append(newFileName)
			// add postfix
			if (postfix.stringValue != "") {
				newFileName += "_\(postfix.stringValue)"
			}
			// append original name
			if (appendOriginalName.state == 1) {
				var nameWOExtension : String! = image["URL"]?.lastPathComponent.stringByDeletingPathExtension
				// remove potential previous original file name
				let start = nameWOExtension.startIndex
				if let end = find(nameWOExtension, "(") {
					nameWOExtension = nameWOExtension[start..<end]
				}
				newFileName += "(\(nameWOExtension))"
			}
			// add file extension
			let ext : String! = image["FileName"]?.pathExtension.lowercaseString
			// rename
			let oldPath : String! = image["URL"]?.path
			println("path: \(oldPath)")
			let basePath : String! = (oldPath as NSString).stringByDeletingLastPathComponent
			let newPathAndBaseName : String = basePath.stringByAppendingPathComponent(newFileName)
			println("newPath: \(newPathAndBaseName)")
			// convert to jpg if raw (CR2)
			if (ext == "cr2") {
				let source = CGImageSourceCreateWithURL(image["URL"] as CFURL, nil)
				let destinationPath = newPathAndBaseName + ".jpg"
				convertToJpg(source, path:destinationPath)
			} else {
				let destinationPath = newPathAndBaseName + ".\(ext)"
				fm.moveItemAtPath(oldPath, toPath: destinationPath, error: nil)
			}
			println("renamed to: \(newFileName)")
		}
		clearTable()
		progressIndicator.stopAnimation(self)
	}
	
	func readMetaDataOfFilesInDirectory(dir:NSURL) {
		//
		progressIndicator.doubleValue = 1
		progressIndicator.startAnimation(self)
		//
		let contents : [NSURL] = fm.contentsOfDirectoryAtURL(imageFolder!,
			includingPropertiesForKeys: [NSURLCreationDateKey],
			options: .SkipsHiddenFiles,
			error: nil) as [NSURL]
		//
		let count = contents.count
		imageFileData = [] // used to avoid duplicate new file names
		for (index, url : NSURL) in enumerate(contents) {
			// do we have an image?
			let pathExtension : String = url.pathExtension ?? ""
			if !contains(["jpeg", "jpg", "cr2"], pathExtension.lowercaseString) {
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
				"FileName": url.lastPathComponent!,
				"FileExtension": pathExtension,
				"ImageDate": getDateTime(source),
				"FileDate": fileCreateDate,
				"URL": url
				])
			if (index < 10) {
				fileListTableView.reloadData()
			}
		}
		progressIndicator.stopAnimation(self)
		
	}
	
	func clearTable() {
		imageFileData = []
		fileListTableView.reloadData()
	}
	
	func getDateTime(imageSource:CGImageSource) -> NSDate {
		let uint:UInt = UInt.min
		let metadataAtIndex = CGImageSourceCopyMetadataAtIndex(imageSource, uint, nil)
		
		let imageDict: Dictionary? = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary
		
		return imageDict <|> "{TIFF}" <| "DateTime" >>- {
			($0 as String).parseDate("yyyy:MM:dd HH:mm:ss")
			} ?? NSDate.defaultDate()
	}
	
	func convertToJpg(imageSource:CGImageSource, path:String) -> Bool {
		let destinationUrl:NSURL = NSURL(fileURLWithPath: path)!
		let destinationImage = CGImageDestinationCreateWithURL(destinationUrl, kUTTypeJPEG, 1, nil)
		CGImageDestinationAddImageFromSource(destinationImage, imageSource, 0, nil)
		let result: Bool = CGImageDestinationFinalize(destinationImage)
		return result
	}


}


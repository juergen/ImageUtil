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
	var imageFileData = [ImageFileMetaData]()
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
		let file : ImageFileMetaData = imageFileData[row]
		var value: AnyObject?
		switch identifier {
		case "FileName" :
			value = file.name
		case "ImageDate" :
			value = file.imageDate
		case "FileDate" :
			value = file.fileDate
		default: "./."
		}
		var stringValue: String
		if (value! is NSDate) {
			stringValue = (value as NSDate).formattedString()
		} else if (value is String) {
			stringValue = value as String
		} else {
			stringValue = "./."
		}
		cell.textField >>- { $0.stringValue = stringValue }
		return cell
	}
	
	@IBAction func rename(sender: NSButton) {
		//
		progressIndicator.doubleValue = 1
		progressIndicator.startAnimation(self)
		//
		var renamedImageFileData = [ImageFileMetaData]()
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
			let firstElement = imageFileData[0]
			let dateFirstImage: NSDate = useImageDate ? firstElement.imageDate : firstElement.fileDate
			println("dateFirstImage: \(dateFirstImage)")
			offset += newStartDate.dateValue.timeIntervalSinceDate(dateFirstImage)
		}
		// dateStrings is used to ensure unique file names
		var dateStrings : Array<String> = []
		let count = imageFileData.count
		var current : Int = 1
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
			// iterate over images
			for image:ImageFileMetaData in self.imageFileData {
				self.progressIndicator.doubleValue = 100 * (Double(current++) / Double(count))
				var counter : Int = 1
				var baseDate: NSDate = useImageDate ? image.imageDate : image.fileDate
				var date = baseDate.dateByAddingTimeInterval(offset)
				var baseName = date.formattedString()
				// ensure name is unique if we have files with same date
				var newFileName: String = "\(baseName)_\(counter++)"
				while (contains(dateStrings, newFileName)) {
					newFileName = "\(baseName)_\(counter++)"
				}
				dateStrings.append(newFileName)
				// add postfix
				if (self.postfix.stringValue != "") {
					newFileName += "_\(self.postfix.stringValue)"
				}
				// append original name
				if (self.appendOriginalName.state == 1) {
					if let nameWOExtension : String = image.url.lastPathComponent?.stringByDeletingPathExtension {
						// remove potential previous original file name
						let start = nameWOExtension.startIndex
						if let end = find(nameWOExtension, "(") {
							newFileName += "(\(nameWOExtension[start..<end]))"
						} else {
							newFileName += "(\(nameWOExtension))"
						}
					}
				}
				// add file extension
				let ext : String! = image.name.pathExtension.lowercaseString
				// rename
				let oldPath : String! = image.url.path
				println("path: \(oldPath)")
				let basePath : String! = (oldPath as NSString).stringByDeletingLastPathComponent
				let newPathAndBaseName : String = basePath.stringByAppendingPathComponent(newFileName)
				println("newPath: \(newPathAndBaseName)")
				//
				var newPath:String
				var newFileDate:NSDate = image.fileDate
				// convert to jpg if raw (CR2)
				if (ext == "cr2") {
					// added original file to result list as it remains in folder
					renamedImageFileData.append(image)
					let source = CGImageSourceCreateWithURL(image.url as CFURL, nil)
					let destinationPath = "\(newPathAndBaseName).jpg"
					self.convertToJpg(source, path:destinationPath)
					newPath = destinationPath
					// we just created the new file
					newFileDate = NSDate()
				} else {
					let destinationPath = "\(newPathAndBaseName).\(ext)"
					self.fm.moveItemAtPath(oldPath, toPath: destinationPath, error: nil)
					newPath = destinationPath
				}
				println("renamed to: \(newFileName)")
				// fileURLWithPath handle spaces in newPath
				if let newUrl:NSURL = NSURL(fileURLWithPath: newPath) {
					let renameImageFile = ImageFileMetaData(
						name:newUrl.lastPathComponent!,
						ext:newUrl.pathExtension!,
						imageDate:image.imageDate,
						fileDate: newFileDate,
						url: newUrl
					)
					renamedImageFileData.append(renameImageFile)
				}
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.imageFileData = renamedImageFileData
				self.fileListTableView.reloadData()
				return
			})
		})
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
		// do not block UI
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
			for (index, url : NSURL) in enumerate(contents) {
				// do we have an image?
				let pathExtension : String = url.pathExtension ?? ""
				if !contains(["jpeg", "jpg", "cr2"], pathExtension.lowercaseString) {
					continue
				}
				let progress : Double = 100 * (Double(index + 1) / Double(count))
				let progressFormatted: String  = progress.format(".1")
				// do we have a filename?
				let fileName : String = url.lastPathComponent ?? ""
				if fileName.isEmpty {
					continue
				}
				println("\(progressFormatted)% \(fileName)")
				self.progressIndicator.doubleValue = progress
				//println("nsurl: \(url.path)")
				let cachedValues : Dictionary = url.resourceValuesForKeys([NSURLCreationDateKey], error: nil)!
				let fileCreateDate : NSDate = cachedValues[NSURLCreationDateKey] as NSDate
				let source = CGImageSourceCreateWithURL(url, nil)
				if (nil == source) { continue }
				let imageFile = ImageFileMetaData(
					name:fileName,
					ext:pathExtension,
					imageDate:self.getDateTime(source),
					fileDate: fileCreateDate,
					url: url
				)
				self.imageFileData.append(imageFile)
				if (index < 10) {
					//self.fileListTableView.reloadData()
				}
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.fileListTableView.reloadData()
				self.progressIndicator.stopAnimation(self)
				return
			})
		})
		
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


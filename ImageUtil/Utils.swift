//
//  Utils.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 11.01.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Foundation

class Utils {
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Directory
	// ----------------------------------------------------------------------------------------------------
	
	/** will delete directory if it already exists before creating it */
	class func createOrEmptyDirectory(path:NSString) -> Bool {
		let fm = NSFileManager.defaultManager()
		var error:NSError?
		var exists:Bool = fm.fileExistsAtPath(path as String)
		if (exists) {
			fm.removeItemAtPath(path as String, error: nil)
		}
		var success:Bool = fm.createDirectoryAtPath(path as String, withIntermediateDirectories:true, attributes:nil, error:&error)
		if error != nil { println(error) }
		return success;
	}
	
	/** will add counter (and increase it) to path as long as directory already exists before ceating it */
	class func createDirectory(path:String) -> String? {
		let fm = NSFileManager.defaultManager()
		let basePath = path
		var currentPath = path
		var counter : Int = 1
		var error:NSError?
		var exists:Bool = fm.fileExistsAtPath(path as String)
		while (fm.fileExistsAtPath(currentPath as String)) {
			currentPath = "\(basePath)_\(counter++)"

		}
		var success:Bool = fm.createDirectoryAtPath(currentPath as String, withIntermediateDirectories:true, attributes:nil, error:&error)
		if error != nil { println(error) }
		if (success) {
			return currentPath
		}
		return nil;
	}

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Image
	// ----------------------------------------------------------------------------------------------------
	
	class func convertToJpg(imageSource:CGImageSource, path:String) -> Bool {
		let destinationUrl:NSURL = NSURL(fileURLWithPath: path)!
		let destinationImage = CGImageDestinationCreateWithURL(destinationUrl, kUTTypeJPEG, 1, nil)
		CGImageDestinationAddImageFromSource(destinationImage, imageSource, 0, nil)
		let result: Bool = CGImageDestinationFinalize(destinationImage)
		return result
	}
	
	class func resizeImage(imageUrl:NSURL, max:Int, destinationPath:String) -> Bool {
		// get CGImageSource from provided ulr
		if let imageSource:CGImageSource = CGImageSourceCreateWithURL(imageUrl, nil) {
			let options : [NSObject:AnyObject] = [
				kCGImageSourceThumbnailMaxPixelSize: max,
				kCGImageSourceCreateThumbnailFromImageAlways: true
			]
			// scale image
			let scaledImage : CGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
			// save image to provided destinationPath
			let destinationUrl : NSURL = NSURL(fileURLWithPath: destinationPath)!
			let destinationImage = CGImageDestinationCreateWithURL(destinationUrl, kUTTypeJPEG, 1, nil)
			CGImageDestinationAddImage(destinationImage, scaledImage, nil)
			let result: Bool = CGImageDestinationFinalize(destinationImage)
			return result
		}
		return false
	}
	
	class func renameToNumberedFiles(dirPath:String, filterExtension:String) -> Bool {
		let fm = NSFileManager.defaultManager()
		// check if dir exists
		var error:NSError?
		var isDir:ObjCBool=false;
		var exists:Bool = fm.fileExistsAtPath(dirPath, isDirectory:&isDir)
		if (!exists && !isDir) { return false }
		// read content of dir
		let dirUrl : NSURL = NSURL(fileURLWithPath: dirPath)!
		let contents : [NSURL] = fm.contentsOfDirectoryAtURL(dirUrl,
			includingPropertiesForKeys: [NSURLCreationDateKey],
			options: .SkipsHiddenFiles,
			error: nil) as! [NSURL]
		// filter file names
		var filteredFiles = [String:NSURL]()
		for (index, url:NSURL) in enumerate(contents) {
			let pathExtension : String = url.pathExtension ?? ""
			if let fileName:String = url.lastPathComponent {
				if contains([filterExtension], pathExtension.lowercaseString) {
					filteredFiles[fileName] = url
				}
			}
		}
		// sort file names
		let sortedFileNames = sorted(filteredFiles.keys, { s1, s2 in return s1 < s2 } )
		// rename
		for (index, fileName:String) in enumerate(sortedFileNames) {
			// e.g. "1" -> "001"
			let baseName = String(format: "%03d", index + 1)
			let newName = "\(baseName).\(filterExtension)"
			let sourceUrl:NSURL = filteredFiles[fileName]!
			let newURL:NSURL = dirUrl.URLByAppendingPathComponent(newName)
			fm.moveItemAtURL(sourceUrl, toURL:newURL, error: nil)
			println("renamed \(sourceUrl.lastPathComponent!) -> \(newURL.lastPathComponent!)")
		}
		return true
	}
	
	class func getDateTime(imageSource:CGImageSource) -> NSDate {
		let int:Int = Int.min
		let metadataAtIndex = CGImageSourceCopyMetadataAtIndex(imageSource, int, nil)
		
		let imageDict: Dictionary? = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary
		
		return imageDict <|> "{TIFF}" <| "DateTime" >>- {
			($0 as! String).parseDate("yyyy:MM:dd HH:mm:ss")
			} ?? NSDate.defaultDate()
	}

}
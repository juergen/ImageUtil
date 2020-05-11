//
//  Utils.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 11.01.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Foundation

class Utils {
  
  // ---------------------------------------------------------------------------
  // MARK: - generall functions
  // ---------------------------------------------------------------------------
  
  class func p(_ printMe:AnyObject?) {
    if let pm: AnyObject = printMe {
      print("\(pm)")
    } else {
      print("nil")
    }
  }
  
  // ---------------------------------------------------------------------------
  // MARK: - Directory
  // ---------------------------------------------------------------------------
  
  /** will delete directory if it already exists before creating it */
  class func createOrEmptyDirectory(_ path:NSString) -> Bool {
    let fm = FileManager.default
    let exists:Bool = fm.fileExists(atPath: path as String)
    if (exists) {
      try! fm.removeItem(atPath: path as String)
    }
    do {
      try FileManager.default.createDirectory(atPath: path as String, withIntermediateDirectories: true, attributes: nil)
    } catch {
      return false
    }
    return true
  }
  
  /** will add counter (and increase it) to path as long as directory already exists before ceating it */
  class func createDirectory(_ path:String) -> String? {
    let fm = FileManager.default
    let basePath = path
    var currentPath = path
    var counter : Int = 1
    while (fm.fileExists(atPath: currentPath as String)) {
      currentPath = "\(basePath)_\(counter)"
      counter = counter + 1
    }
    do {
      try FileManager.default.createDirectory(atPath: currentPath as String, withIntermediateDirectories: true, attributes: nil)
    } catch {
      return nil
    }
    return currentPath
  }
  
  // ---------------------------------------------------------------------------
  // MARK: - Image
  // ---------------------------------------------------------------------------
  
  @discardableResult class func convertToJpg(_ imageSource:CGImageSource, path:String) -> Bool {
    let destinationUrl:URL = URL(fileURLWithPath: path)
    let destinationImage = CGImageDestinationCreateWithURL(destinationUrl as CFURL, kUTTypeJPEG, 1, nil)
    CGImageDestinationAddImageFromSource(destinationImage!, imageSource, 0, nil)
    let result: Bool = CGImageDestinationFinalize(destinationImage!)
    return result
  }
  
  @discardableResult class func resizeImage(_ imageUrl:URL, max:Int, destinationPath:String) -> Bool {
    // get CGImageSource from provided ulr
    if let imageSource:CGImageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) {
      let options : [AnyHashable: Any] = [
        kCGImageSourceThumbnailMaxPixelSize as AnyHashable: max,
        kCGImageSourceCreateThumbnailFromImageAlways as AnyHashable: true
      ]
      // scale image
      let scaledImage : CGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)!
      // save image to provided destinationPath
      let destinationUrl : URL = URL(fileURLWithPath: destinationPath)
      let destinationImage = CGImageDestinationCreateWithURL(destinationUrl as CFURL, kUTTypeJPEG, 1, nil)
      CGImageDestinationAddImage(destinationImage!, scaledImage, nil)
      let result: Bool = CGImageDestinationFinalize(destinationImage!)
      return result
    }
    return false
  }
  
  @discardableResult class func renameToNumberedFiles(_ dirPath:String, filterExtension:String) -> Bool {
    let fm = FileManager.default
    // check if dir exists
    var isDir:ObjCBool = ObjCBool(false)
    let exists:Bool = fm.fileExists(atPath: dirPath, isDirectory:&isDir)
    if (!exists && !isDir.boolValue) { return false }
    // read content of dir
    let dirUrl : URL = URL(fileURLWithPath: dirPath)
    let contents : [URL]
    do {
      try contents = fm.contentsOfDirectory(at: dirUrl,
      includingPropertiesForKeys: [URLResourceKey.creationDateKey],
      options: .skipsHiddenFiles)
    } catch {
      return false
    }
    // filter file names
    var filteredFiles = [String:URL]()
    for url in contents {
      let pathExtension : String = url.pathExtension
      let fileName:String = url.lastPathComponent
      if filterExtension.contains(pathExtension.lowercased()) {
        filteredFiles[fileName] = url
      }
      
    }
    // sort file names
    let sortedFileNames = filteredFiles.keys.sorted()
    // rename
    for (index, fileName) in sortedFileNames.enumerated() {
      // e.g. "1" -> "001"
      let baseName = String(format: "%03d", index + 1)
      let newName = "\(baseName).\(filterExtension)"
      let sourceUrl:URL = filteredFiles[fileName]!
      let newURL:URL = dirUrl.appendingPathComponent(newName)
      do {
        try fm.moveItem(at: sourceUrl, to:newURL)
        print("renamed \(sourceUrl.lastPathComponent) -> \(newURL.lastPathComponent)")
      } catch {
        continue
      }
      
    }
    return true
  }
  
  class func getDateTime(_ imageSource:CGImageSource) -> Date {
    let imageDict = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as! [String:Any]
    if
      let tiffDict = imageDict["{TIFF}"] as? [String:Any],
      let dateTimeString = tiffDict["DateTime"] as? String {
      return dateTimeString.parseDate("yyyy:MM:dd HH:mm:ss")
    }
    return Date.defaultDate()
  }
  
  @discardableResult class func setDateTime(_ imageUrl:URL, date:Date) -> Bool {
    //
    if let imageSource:CGImageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) {
      let dateString = date.formattedString(Constant.imageDateTimeFormat)
      // build dictionary to update date time
      let tiff = [kCGImagePropertyTIFFDateTime as String:dateString]
      let exif = [
        kCGImagePropertyExifDateTimeOriginal as String:dateString,
        kCGImagePropertyExifDateTimeDigitized as String:dateString
      ]
      let metaData = [
        kCGImagePropertyTIFFDictionary as String:tiff,
        kCGImagePropertyExifDictionary as String:exif
      ]
      // update image with meta data
      let destination = CGImageDestinationCreateWithURL(imageUrl as CFURL, kUTTypeJPEG, 1, nil)
      CGImageDestinationAddImageFromSource(destination!,imageSource,0, metaData as CFDictionary)
      let result: Bool = CGImageDestinationFinalize(destination!)
      return result
    }
    return false
  }
  
}

//
//  Structs.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 10.01.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Foundation

struct ImageFileMetaData {
  
  var name:String
  var ext:String // extension
  var imageDate:Date // date of image meta data
  var fileDate:Date // date of file
  var fileNameDate:Date? // date parsed from filename
  var url:URL
  
}

struct Constant {
  
  static let imageDateTimeFormat = "yyyy:MM:dd HH:mm:ss"
  
  static let datePatterns: [(String, String)] = [
    ("yyyy-MM-dd_hh-mm", "[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]_[0-2][0-9]-[0-5][0-9]"),
    ("yyyy-MM-dd", "[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]"),
    ("yyyy-MM","[1-2][0-9]{3}-[0-1][0-9]"),
    ("yyyy","[1-2][0-9]{3}")
  ]
  
}

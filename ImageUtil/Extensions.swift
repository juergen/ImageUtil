//
//  Extensions.swift
//  ImageUtil
//
//  Created by juba on 24.10.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Foundation

extension Date {
  
  static func defaultDate() -> Date {
    return "2000:01:01 00:00:00".parseDate("yyyy:MM:dd HH:mm:ss")
  }
  
  func formattedString(_ format:String="yyyy-MM-dd_HH-mm") -> String {
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = format
    return dateStringFormatter.string(from: self)
  }
  
  func parseImageDate(_ dateStr:String, format:String="yyyy-MM-dd") -> Date {
    let dateFmt = DateFormatter()
    if let date = dateFmt.date(from: dateStr) {
      return date
    }
    return Date.defaultDate()
    //print("\(dateStr) -> \(date)")
  }
  
}

extension String {
  
  func parseDate(_ format:String="yyyy-MM-dd") -> Date {
    let dateFmt = DateFormatter()
    dateFmt.dateFormat = format
    if let date = dateFmt.date(from: self) {
      return date
    }
    return Date.defaultDate()
    //print("\(dateStr) -> \(date)")
  }
  
  func substringWithPattern(_ pattern:String) -> String? {
    if let range = self.range(of: pattern, options: .regularExpression) {
      return self.substring(with: range)
    }
    return nil
  }
  
  func substringFromIntIndex(_ i:Int) -> String {
    let index: String.Index = self.index(startIndex, offsetBy: i)
    return self.substring(from: index)
  }
  
  func parseDateFromFileName() -> Date? {
    let dateFmt = DateFormatter()
    for i in 0...self.characters.count {
      let s = self.substringFromIntIndex(i)
      for (format, pattern) in Constant.datePatterns {
        if let dateString = s.substringWithPattern(pattern) {
          dateFmt.dateFormat = format
          if let date = dateFmt.date(from: dateString) {
            return date
          }
        }
      }
    }
    return nil
  }
  
  var lastPathComponent: String {
    return (self as NSString).lastPathComponent
  }
  var pathExtension: String {
    return (self as NSString).pathExtension
  }
  var stringByDeletingLastPathComponent: String {
    return (self as NSString).deletingLastPathComponent
  }
  var stringByDeletingPathExtension: String {
    return (self as NSString).deletingPathExtension
  }
  var pathComponents: [String] {
    return (self as NSString).pathComponents
  }
  func stringByAppendingPathComponent(path: String) -> String {
    let nsSt = self as NSString
    return nsSt.appendingPathComponent(path)
  }
  func stringByAppendingPathExtension(ext: String) -> String? {
    let nsSt = self as NSString
    return nsSt.appendingPathExtension(ext)
  }
  
}

extension Double {
  func format(_ f: String) -> String {
    return NSString(format: "%\(f)f" as NSString, self) as String
  }
}

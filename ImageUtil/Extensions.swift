//
//  Extensions.swift
//  ImageUtil
//
//  Created by juba on 24.10.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Foundation

extension NSDate {
  
  class func defaultDate() -> NSDate {
    return "2000:01:01 00:00:00".parseDate("yyyy:MM:dd HH:mm:ss")
  }
  
  func formattedString(_ format:String="yyyy-MM-dd_HH-mm") -> String {
    let dateStringFormatter = NSDateFormatter()
    dateStringFormatter.dateFormat = format
    return dateStringFormatter.stringFromDate(self)
  }
  
  func parseImageDate(dateStr:String, format:String="yyyy-MM-dd") -> NSDate {
    var dateFmt = NSDateFormatter()
    dateFmt.timeZone = NSTimeZone()
    dateFmt.dateFormat = format
    if let date = dateFmt.dateFromString(dateStr) {
      return date
    }
    return NSDate.defaultDate()
    //println("\(dateStr) -> \(date)")
  }
  
}

extension String {
  
  func parseDate(_ format:String="yyyy-MM-dd") -> NSDate {
    var dateFmt = NSDateFormatter()
    dateFmt.timeZone = NSTimeZone()
    dateFmt.dateFormat = format
    if let date = dateFmt.dateFromString(self) {
      return date
    }
    return NSDate.defaultDate()
    //println("\(dateStr) -> \(date)")
  }
  
  func substringWithPattern(pattern:String) -> String? {
    if let range = self.rangeOfString(pattern, options: .RegularExpressionSearch) {
      return self.substringWithRange(range)
    }
    return nil
  }
  
  func substringFromIntIndex(i:Int) -> String {
    let index: String.Index = advance(self.startIndex, i)
    return self.substringFromIndex(index)
  }
  
  func parseDateFromFileName() -> NSDate? {
    var dateFmt = NSDateFormatter()
    dateFmt.timeZone = NSTimeZone()
    for i in 0...count(self) {
      let s = self.substringFromIntIndex(i)
      for (format, pattern) in Constant.datePatterns {
        if let dateString = s.substringWithPattern(pattern) {
          dateFmt.dateFormat = format
          if let date = dateFmt.dateFromString(dateString) {
            return date
          }
        }
      }
    }
    return nil
  }
  
}

extension Double {
  func format(f: String) -> String {
    return NSString(format: "%\(f)f", self) as String
  }
}
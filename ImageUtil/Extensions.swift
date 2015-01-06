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
	
	func formattedString() -> String {
		let dateStringFormatter = NSDateFormatter()
		dateStringFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
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
	
}

extension Double {
	func format(f: String) -> String {
		return NSString(format: "%\(f)f", self)
	}
}
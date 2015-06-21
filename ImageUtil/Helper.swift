//
//  Helper.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 20.06.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Foundation

class Regex {
  let _expression: NSRegularExpression
  let pattern: String
  
  init(_ pattern: String) {
    self.pattern = pattern
    var error: NSError?
    self._expression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
  }
  
  func test(input: String) -> Bool {
    let matches = self._expression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
    return matches.count > 0
  }
}
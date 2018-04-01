//
//  Helper.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 20.06.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Foundation

class Regex {
  let pattern: String
  
  init(_ pattern: String) {
    self.pattern = pattern
  }
  
  func test(_ input: String) -> Bool {
    do {
      let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
      let matches = expression.matches(in: input, options: [], range: NSMakeRange(0, input.count))
      return matches.count > 0
    } catch {
      return false
    }
  }

}

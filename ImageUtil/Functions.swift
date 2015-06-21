//
//  Functions.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 20.06.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Foundation

public func ==~ (input: String, pattern: String) -> Bool {
  return input.rangeOfString(pattern, options: .RegularExpressionSearch) != nil
}

public func p(printMe: Any) {
  println("\(printMe)")
}
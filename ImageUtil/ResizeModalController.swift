//
//  ResizeModalController.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 25.01.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Cocoa

class ResizeModalController: NSViewController {
	
	@IBOutlet weak var resizeWidth: NSTextField!
	@IBOutlet weak var renameToNumbers: NSButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
	
	@IBAction func resizeModalOk(sender: NSButton) {
		println("resizeModalOk")
		println("resizeWidth: \(resizeWidth.stringValue)")
		println("renameToNumbers: \(renameToNumbers.state)")
		//
		var width : Int = Int(resizeWidth.integerValue)
		if (width < 1) {
			// ToDo inform user
			self.dismissViewController(self)
			return
		}
		let rename:Bool = self.renameToNumbers.state == 1
		//resize("resizedTo_\(width)", size: width, renameNumbered:rename)
		self.dismissViewController(self)
	}
	
	@IBAction func resizeModalCancel(sender: NSButton) {
		println("resizeModalCancel")
		self.dismissViewController(self)
	}

}

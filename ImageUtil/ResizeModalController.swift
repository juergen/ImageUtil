//
//  ResizeModalController.swift
//  ImageUtil
//
//  Created by Juergen Baumann on 25.01.15.
//  Copyright (c) 2015 Juergen Baumann. All rights reserved.
//

import Cocoa

class ResizeModalController: NSViewController {
	
	var callBack:((Int,Bool) -> Void)?
	
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
		self.dismissViewController(self)
		callBack >>- {
			$0(width, rename)
		}
	}
	
	@IBAction func resizeModalCancel(sender: NSButton) {
		println("resizeModalCancel")
		self.dismissViewController(self)
		
	}
	
	

}

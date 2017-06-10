//
//  ViewController.swift
//  ImageUtilNew
//
//  Created by Juergen Baumann on 27.12.14.
//  Copyright (c) 2014 Juergen Baumann. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  var imageFolder : URL?
  var imageFileData = [ImageFileMetaData]()
  let fm = FileManager.default
  
  // ----------------------------------------------------------------------------------------------------
  // MARK: - Lifecycle
  // ----------------------------------------------------------------------------------------------------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
      print("in representedObject")
    }
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification?) {
    // Insert code here to initialize your application
  }
  
  func applicationWillTerminate(_ aNotification: Notification?) {
    // Insert code here to tear down your application
  }
  
  // ----------------------------------------------------------------------------------------------------
  // MARK: - Segue
  // ----------------------------------------------------------------------------------------------------
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    print("in prepareForSegue")
    let destination = segue.destinationController as! ResizeModalController
    destination.callBack = { size, renameNumbered in
      self.resize("\(size)", size: size, renameNumbered:renameNumbered)
    }
  }
  
  // ----------------------------------------------------------------------------------------------------
  // MARK: -  @IBOutlet
  // ----------------------------------------------------------------------------------------------------
  
  //@IBOutlet weak var window: NSWindow!
  @IBOutlet weak var pathTextField: NSTextField!
  @IBOutlet weak var fileListTableView: NSTableView!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  @IBOutlet weak var dateFromSelector: NSMatrix!
  @IBOutlet weak var useNewStartDate: NSButton!
  @IBOutlet weak var newStartDate: NSDatePicker!
  @IBOutlet weak var hours: NSTextField!
  @IBOutlet weak var postfix: NSTextField!
  @IBOutlet weak var appendOriginalName: NSButton!
  @IBOutlet weak var openRecentMenu: NSMenu!
  @IBOutlet weak var actionSelector: NSMatrix!
  
  
  // ----------------------------------------------------------------------------------------------------
  // MARK: -  @IBAction
  // ----------------------------------------------------------------------------------------------------
  
  @IBAction func openDocumentMenu(_ sender: NSMenuItem) {
    selectFolder()
  }
  
  @IBAction func selectImageFolder(_ sender: NSButton) {
    selectFolder()
  }
  
  @IBAction func generateSlidesMenu(_ sender: NSButton) {
    resize("slides", size: 900, renameNumbered:true)
  }
  
  @IBAction func generateThumbsMenu(_ sender: NSButton) {
    resize("thumbs", size: 120, renameNumbered:true)
  }
  
  @IBAction func resizeTo310Menu(_ sender: NSButton) {
    resize("310", size: 310)
  }
  
  @IBAction func resizeMenu(_ sender: NSButton) {
    self.performSegue(withIdentifier: "resizeSegue", sender: self)
  }
  
  @IBAction func update(_ sender: NSButton) {
    switch (actionSelector.selectedRow) {
    case 0:
      renameImages()
    case 1:
      updateImageDate()
    default:
      print("action not handled")
    }
    
  }

  
  // ----------------------------------------------------------------------------------------------------
  // MARK: - Private
  // ----------------------------------------------------------------------------------------------------
  
  fileprivate func clearTable() {
    imageFileData = []
    fileListTableView.reloadData()
  }
  
  fileprivate func selectFolder() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false
    //
    var pathString : String! = ""
    if openPanel.runModal() == NSOKButton    {
      imageFolder = openPanel.urls[0] as? URL
      readMetaDataOfFilesInDirectory(imageFolder!)
      fileListTableView.reloadData()
      pathString = imageFolder?.path
    } else {
      pathString = ""
      clearTable()
    }
    pathTextField.stringValue = NSLocalizedString("Path: ", comment:"Path label") + pathString
  }
  
  fileprivate func renameImages() {
    progressIndicator.doubleValue = 1
    progressIndicator.startAnimation(self)
    //
    var renamedImageFileData = [ImageFileMetaData]()
    //
    print("dateFromSelector: \(dateFromSelector.selectedRow)")
    print("useNewStartDate: \(useNewStartDate.state)")
    print("newStartDate: \(newStartDate.dateValue)")
    print("hours: \(hours.stringValue)")
    print("postfix: \(postfix.stringValue)")
    print("appendOriginalName: \(appendOriginalName.state)")
    //
    // hours based offset
    var offset : Double = Double(60 * 60) * Double(hours.floatValue)
    // add new start date based offset
    if (useNewStartDate.state == 1 && imageFileData.count > 0) {
      print("we have a newStartDate!")
      let firstElement = imageFileData[0]
      let dateFirstImage: Date = self.getSelectedDate(dateFromSelector, metaData: firstElement)
      print("dateFirstImage: \(dateFirstImage)")
      offset += newStartDate.dateValue.timeIntervalSince(dateFirstImage)
    }
    // dateStrings is used to ensure unique file names
    var dateStrings : Array<String> = []
    let count = imageFileData.count
    var current : Int = 1
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
      // iterate over images
      for image:ImageFileMetaData in self.imageFileData {
        var counter : Int = 1
        var baseDate: Date = self.getSelectedDate(self.dateFromSelector, metaData: image)
        var date = baseDate.addingTimeInterval(offset)
        var baseName = date.formattedString()
        // ensure name is unique if we have files with same date
        var newFileName: String = "\(baseName)_\(counter)"
        counter = counter + 1
        while (dateStrings.contains(newFileName)) {
          newFileName = "\(baseName)_\(counter)"
          counter = counter + 1
        }
        dateStrings.append(newFileName)
        // add postfix
        if (self.postfix.stringValue != "") {
          newFileName += "_\(self.postfix.stringValue)"
        }
        // append original name
        if (self.appendOriginalName.state == 1) {
          if let nameWOExtension : String = image.url.deletingPathExtension().lastPathComponent {
            // remove potential previous original file name
            let start = nameWOExtension.startIndex
            if let end = nameWOExtension.characters.index(of: "(") {
              newFileName += "(\(nameWOExtension[start..<end]))"
            } else {
              newFileName += "(\(nameWOExtension))"
            }
          }
        }
        // add file extension
        let ext : String? = URL(string: image.name)?.pathExtension.lowercased()
        // rename
        let oldPath : String! = image.url.path
        print("path: \(oldPath)")
        let basePath : String! = (oldPath as NSString).deletingLastPathComponent
        let newPathAndBaseName : String = basePath.stringByAppendingPathComponent(path: newFileName)
        print("newPath: \(newPathAndBaseName)")
        //
        var newPath:String
        var newFileDate:Date = image.fileDate as Date
        // convert to jpg if raw (CR2)
        if (ext == "cr2") {
          // added original file to result list as it remains in folder
          renamedImageFileData.append(image)
          let source = CGImageSourceCreateWithURL(image.url as CFURL, nil)
          let destinationPath = "\(newPathAndBaseName).jpg"
          Utils.convertToJpg(source!, path:destinationPath)
          newPath = destinationPath
          // we just created the new file
          newFileDate = Date()
        } else {
          // build file path
          let destinationPath : String
          if let unwrappedExt = ext {
            destinationPath = "\(newPathAndBaseName).\(unwrappedExt)"
          } else {
            destinationPath = "\(newPathAndBaseName)"
          }
          // move file
          do {
            try self.fm.moveItem(atPath: oldPath, toPath: destinationPath)
          } catch {
            print("could not move item to: \(destinationPath)")
          }
          newPath = destinationPath
        }
        print("renamed to: \(newFileName)")
        // fileURLWithPath handle spaces in newPath
        if let newUrl:URL = URL(fileURLWithPath: newPath) {
          let renameImageFile = ImageFileMetaData(
            name:newUrl.lastPathComponent,
            ext:newUrl.pathExtension,
            imageDate:image.imageDate,
            fileDate: newFileDate,
            fileNameDate: newFileName.parseDateFromFileName(),
            url: newUrl
          )
          renamedImageFileData.append(renameImageFile)
        }
        self.progressIndicator.doubleValue = 100 * (Double(current) / Double(count))
        current = current + 1
      }
      DispatchQueue.main.async(execute: {
        self.imageFileData = renamedImageFileData
        self.fileListTableView.reloadData()
        return
      })
    })
  }
  
  fileprivate func updateImageDate() {
    progressIndicator.doubleValue = 1
    progressIndicator.startAnimation(self)
    //
    var processedImageFileData = [ImageFileMetaData]()
    // hours based offset
    var offset : Double = Double(60 * 60) * Double(hours.floatValue)
    // add new start date based offset
    if (useNewStartDate.state == 1 && imageFileData.count > 0) {
      print("we have a newStartDate!")
      let firstElement = imageFileData[0]
      let dateFirstImage: Date = self.getSelectedDate(dateFromSelector, metaData: firstElement)
      print("dateFirstImage: \(dateFirstImage)")
      offset += newStartDate.dateValue.timeIntervalSince(dateFirstImage)
    }
    let count = imageFileData.count
    var current : Int = 1
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
      // iterate over images
      for image:ImageFileMetaData in self.imageFileData {
        var counter : Int = 1
        var baseDate: Date = self.getSelectedDate(self.dateFromSelector, metaData: image)
        var date = baseDate.addingTimeInterval(offset)
        Utils.setDateTime(image.url, date: date)
        let updatedImageFile = ImageFileMetaData(
          name:image.name,
          ext:image.ext,
          imageDate:date,
          fileDate: image.fileDate,
          fileNameDate: image.fileNameDate,
          url: image.url
        )
        processedImageFileData.append(updatedImageFile)
        self.progressIndicator.doubleValue = 100 * (Double(current) / Double(count))
        current = current + 1
      }
      DispatchQueue.main.async(execute: {
        self.imageFileData = processedImageFileData
        self.fileListTableView.reloadData()
        return
      })
    })
  }
  
  fileprivate func getSelectedDate(_ dateFromSelector:NSMatrix, metaData:ImageFileMetaData) -> Date {
    switch (dateFromSelector.selectedRow, metaData.fileNameDate) {
    case (0, _):
      return metaData.imageDate as Date
    case (1, _):
      return metaData.fileDate as Date
    case (2, .some(let fileNameDate)):
      return fileNameDate as Date
    default:
      return metaData.imageDate as Date
    }

  }
  
  fileprivate func readMetaDataOfFilesInDirectory(_ dir:URL) {
    //
    progressIndicator.doubleValue = 1
    progressIndicator.startAnimation(self)
    //
    let contents : [URL]
    do {
      contents = try fm.contentsOfDirectory(at: imageFolder!,
                                            includingPropertiesForKeys: [URLResourceKey.creationDateKey],
                                            options: .skipsHiddenFiles)
    } catch {
      print("could not read metaData of \(dir)")
      return
    }
    
    //
    let count = contents.count
    imageFileData = [] // used to avoid duplicate new file names
    // do not block UI
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
      for (index, url) in contents.enumerated() {
        let progress : Double = 100 * (Double(index + 1) / Double(count))
        let progressFormatted: String  = progress.format(".1")
        // do we have an image?
        let pathExtension : String = url.pathExtension
        if !["jpeg", "jpg", "cr2"].contains(pathExtension.lowercased()) {
          // ensure that progress indicator is also updated
          self.progressIndicator.doubleValue = progress
          continue
        }
        // do we have a filename?
        let fileName : String = url.lastPathComponent
        if fileName.isEmpty {
          continue
        }
        print("\(progressFormatted)% \(fileName) \(String(describing: fileName.parseDateFromFileName()))")
        //print("nsurl: \(url.path)")
        let resValues = try! url.resourceValues(forKeys: [.creationDateKey])
        let fileCreateDate : Date = resValues.creationDate!
        let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        if (nil == source) { continue }
        let imageFile = ImageFileMetaData(
          name:fileName,
          ext:pathExtension,
          imageDate:Utils.getDateTime(source!),
          fileDate: fileCreateDate,
          fileNameDate: fileName.parseDateFromFileName(),
          url: url
        )
        
        self.imageFileData.append(imageFile)
        if (index < 10) {
          //self.fileListTableView.reloadData()
        }
        self.progressIndicator.doubleValue = progress
      }
      DispatchQueue.main.async(execute: {
        self.fileListTableView.reloadData()
        self.progressIndicator.stopAnimation(self)
        return
      })
    })
    
  }
  
  fileprivate func resize(_ destinationDirName:String, size:Int, renameNumbered:Bool = false) {
    let count = imageFileData.count
    if (count < 1) {
      return
    }
    var current : Int = 1
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
      // generate slides folder
      var destinationDirPath : String?
      if let parentPath : String = self.imageFolder?.path {
        destinationDirPath = "\(parentPath)/\(destinationDirName)"
        destinationDirPath = Utils.createDirectory(destinationDirPath!)
        if destinationDirPath == nil { return }
      } else {
        return
      }
      // iterate over images
      for image:ImageFileMetaData in self.imageFileData {
        Utils.resizeImage(image.url, max: size, destinationPath:"\(destinationDirPath!)/\(image.name)")
        print("resized \(destinationDirPath!)/\(image.name)")
        // update progress bar
        self.progressIndicator.doubleValue = 100 * (Double(current) / Double(count))
        current = current + 1
      }
      if (renameNumbered) {
        Utils.renameToNumberedFiles(destinationDirPath!, filterExtension: "jpg")
      }
      //
      DispatchQueue.main.async(execute: {
        self.fileListTableView.reloadData()
        self.progressIndicator.stopAnimation(self)
        return
      })
    })
  }
  
}

// ----------------------------------------------------------------------------------------------------
// MARK: - TableView
// ----------------------------------------------------------------------------------------------------

extension ViewController: NSTableViewDelegate {
  
  func tableView(_ tableView: NSTableView, viewFor viewForTableColumn: NSTableColumn?, row: Int) -> NSView? {
    let identifier = viewForTableColumn!.identifier
    let cell = fileListTableView.make(withIdentifier: identifier, owner: self) as! NSTableCellView
    let file : ImageFileMetaData = imageFileData[row]
    var value: AnyObject?
    switch identifier {
    case "FileName" :
      value = file.name as AnyObject
    case "FileNameDate" :
      if let fileNameDate = file.fileNameDate {
        value = file.fileNameDate as AnyObject
      } else {
        value = "./." as AnyObject
      }
    case "ImageDate" :
      value = file.imageDate as AnyObject
    case "FileDate" :
      value = file.fileDate as AnyObject
    default: "./."
    }
    var stringValue: String
    if (value! is Date) {
      stringValue = (value as! Date).formattedString()
    } else if (value is String) {
      stringValue = value as! String
    } else {
      stringValue = "./."
    }
    cell.textField >>- { $0.stringValue = stringValue }
    return cell
  }
}

extension ViewController: NSTableViewDataSource {
  
  func numberOfRows(in aTableView: NSTableView) -> Int {
    return imageFileData.count
  }
}


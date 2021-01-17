//
//  ViewController.swift
//  AwesomeApp
//
//  Created by Vladislav Yakimchik on 14.01.21.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var selectStringButton: NSButton!
    @IBOutlet weak var selectImageButton: NSButton!
    
    @IBOutlet weak var base64ScrollView: NSScrollView!
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.window?.setFrame(NSRect(x:0,y:0,width: 200,height: 200), display: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func selectString(_ sender: Any) {
        decode()
    }
    
    @IBAction func selectImage(_ sender: Any) {
        encode()
    }
    
    func decode() {
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)

        do {
            let path = pickFile().path
            
            if path == "nil" {
                return
            }
            
            let strBase64 = try String(contentsOfFile: path)
            let dataDecoded = NSData(base64Encoded: strBase64, options: NSData.Base64DecodingOptions(rawValue: 0))
            let decodedData = NSImage(data: dataDecoded! as Data)
            
            let pathOutImage = url[0].appendingPathComponent("out.png")
            try dataDecoded?.write(to: pathOutImage, options: .noFileProtection)
            
            imageView.image = decodedData
            base64ScrollView.documentView?.insertText(strBase64)
        } catch {
            dialogOKCancel(messageText: "Alert", informativeText: error.localizedDescription)
            
            print(error)
        }
    }
    
    func encode() {
        let imageUrl = pickFile()
        
        if imageUrl.path == "nil" {
            return
        }
        
        let imageData = NSData.init(contentsOf: imageUrl)
        guard let strBase64 = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0)) else {
            return
        }
        
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        
        do {
            let path = url[0].appendingPathComponent("out.txt")
            try strBase64.write(to: path, atomically: true, encoding: .ascii)
            
            let image = NSImage.init(data: imageData! as Data)
            
            if image != nil {
                imageView.image = image
                base64ScrollView.documentView?.insertText(strBase64)
                
                print("Saved to: \(path)")
            } else {
                dialogOKCancel(messageText: "Alert", informativeText: "It's not an image")
            }
        } catch {
            dialogOKCancel(messageText: "Alert", informativeText: error.localizedDescription)
            
            print(error)
        }
    }
    
    func pickFile() -> URL {
        let dialog = NSOpenPanel();

        dialog.title = "Choose a file";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            guard let path = dialog.url else {
                return URL.init(string: "nil")!
            }
            
            print("Picked: \(path)")
            
            return path
        } else {
            print("Cancelled")
        }
        
        return URL.init(string: "nil")!
    }
    
    func dialogOKCancel(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}


//
//  ViewController.swift
//  AwesomeApp
//
//  Created by Vladislav Yakimchik on 14.01.21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var optionsButton: NSPopUpButton!
    @IBOutlet weak var mainImageView: DragImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsButton.addItem(withTitle: "Base64 -> Image")
        optionsButton.addItem(withTitle: "Image -> Base64")
        
        let tapGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(ViewController.imageViewTapped))
        mainImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func imageViewTapped(gesture: NSGestureRecognizer) {
//        let tappedImage = gesture.view as! NSImageView
        
        runConvert(path: pickFile())
    }
    
    func decode(pathToBase64: String) {
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)

        do {            
            if pathToBase64 == "nil" {
                return
            }
            
            let strBase64 = try String(contentsOfFile: pathToBase64)
            let dataDecoded = NSData(base64Encoded: strBase64, options: NSData.Base64DecodingOptions(rawValue: 0))
            let decodedData = NSImage(data: dataDecoded! as Data)
            
            let pathOutImage = url[0].appendingPathComponent("out.png")
            try dataDecoded?.write(to: pathOutImage, options: .noFileProtection)
            
            mainImageView.image = decodedData
            
            dialog(messageText: "Result", informativeText: pathOutImage.path)
            
            print("Saved to: \(pathOutImage.path)")
        } catch {
            dialog(messageText: "Alert", informativeText: error.localizedDescription)
            
            print(error)
        }
    }
    
    func encode(imageUrl: URL) {
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
            try strBase64.write(to: path, atomically: true, encoding: .utf8)
            
            let image = NSImage.init(data: imageData! as Data)
            
            if image != nil {
                mainImageView.image = image
                
                dialog(messageText: "Result", informativeText: path.path)
                
                print("Saved to: \(path.path)")
            } else {
                dialog(messageText: "Alert", informativeText: "It's not an image")
            }
        } catch {
            dialog(messageText: "Alert", informativeText: error.localizedDescription)
            
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
    
    func dialog(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func runConvert(path: URL) {
        let selectedOption = optionsButton.indexOfSelectedItem
        
        switch selectedOption {
        case 0:
            decode(pathToBase64: path.path)
        case 1:
            encode(imageUrl: path)
        default:
            print("No such an option")
        }
    }
}


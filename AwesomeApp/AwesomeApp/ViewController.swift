//
//  ViewController.swift
//  AwesomeApp
//
//  Created by Vladislav Yakimchik on 14.01.21.
//

import Cocoa

class ViewController: NSViewController, DragImageViewDelegate {
    
    @IBOutlet weak var optionsButton: NSPopUpButton!
    @IBOutlet weak var mainImageView: DragImageView! {
        didSet {
            let image = mainImageView.image?.tint(color: NSColor.gray)
            mainImageView.image = image
        }
    }
    @IBOutlet weak var hintTextField: NSTextField! {
        didSet {
            let str = "Drag and Drop a file that contains an image or click the image above to pick it. The result will be in the Downloads folder"
            hintTextField.placeholderString = str
        }
    }
    @IBOutlet weak var textAreaScrollView: NSScrollView!
    @IBOutlet weak var copyToClipboardButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsButton.addItem(withTitle: "Base64 -> Image")
        optionsButton.addItem(withTitle: "Image -> Base64")
        
        mainImageView.delegate = self
        
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
            guard let dataDecoded = NSData(base64Encoded: strBase64, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
                print("decode: dataDecoded is nil")
                return
            }
            let decodedData = NSImage(data: dataDecoded as Data)
            
            if saveButton.state == .on {
                let pathOutImage = url[0].appendingPathComponent("out.png")
                try dataDecoded.write(to: pathOutImage, options: NSData.WritingOptions.init(rawValue: 0))
                
                print("Saved to: \(pathOutImage.path)")
            }
            
            let textView = textAreaScrollView.documentView as! NSTextView
            
            mainImageView.image = decodedData
            textView.string = strBase64
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
            if saveButton.state == .on {
                let path = url[0].appendingPathComponent("out.txt")
                try strBase64.write(to: path, atomically: true, encoding: .utf8)
                
                print("Saved to: \(path.path)")
            }
            
            let image = NSImage.init(data: imageData! as Data)
            
            if image != nil {
                let textView = textAreaScrollView.documentView as! NSTextView
                
                mainImageView.image = image
                textView.string = strBase64
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
    
    @IBAction func copyToClipboard(_ sender: Any) {
        let textView = textAreaScrollView.documentView as! NSTextView
        
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(textView.string, forType: .string)
        
        print("String copied to clipboard")
    }
    
    @IBAction func process(_ sender: Any) {
        let textView = textAreaScrollView.documentView as! NSTextView
        let base64String = textView.string
        
        if !base64String.isEmpty {
            do {
                let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
                
                guard let dataDecoded = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
                    print("process: dataDecoded is nil")
                    return
                }
                let decodedData = NSImage(data: dataDecoded as Data)
                
                if saveButton.state == .on {
                    let pathOutImage = url[0].appendingPathComponent("out.png")
                    try dataDecoded.write(to: pathOutImage, options: NSData.WritingOptions.init(rawValue: 0))
                }
                
                mainImageView.image = decodedData
            } catch {
                dialog(messageText: "Alert", informativeText: error.localizedDescription)
                
                print(error)
            }
        }
    }
    
}

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}

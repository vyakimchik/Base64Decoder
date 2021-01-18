//
//  DragImageView.swift
//  AwesomeApp
//
//  Created by Vladislav Yakimchik on 17.01.21.
//

import Cocoa

class DragImageView: NSImageView {
    
    var delegate: DragImageViewDelegate?
    
    var expectedExt = ["jpg", "jpeg", "bmp", "png", "pdf", "txt", "tif", "tiff"]
    let border = CAShapeLayer()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true

        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
//            self.layer?.backgroundColor = CGColor.init(red: 0.945, green: 0.945, blue: 0.945, alpha: 0.3)
            dashedLine()
            return .copy
        } else {
            return NSDragOperation()
        }
    }

    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String
        else { return false }

        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.expectedExt {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
//        self.layer?.backgroundColor = NSColor.gray.cgColor
        border.path = nil
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
//        self.layer?.backgroundColor = NSColor.gray.cgColor
        border.path = nil
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = pasteboard[0] as? String
        else { return false }

        print("File path: \(path)")
        
        let finalPath = "file://" + path
        
        if let temp = self.delegate {
            delegate?.runConvert(path: URL(string: finalPath)!)
        }
        
        return true
    }
    
    func dashedLine() {
        border.strokeColor = NSColor.gray.cgColor
        border.fillColor = nil
        border.lineDashPattern = [20, 10]
        border.lineWidth = 5
        border.frame = bounds
        border.path = NSBezierPath(rect: bounds).cgPath
        self.layer?.addSublayer(border)
    }
    
}

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let elementCount = self.elementCount
        
        if elementCount > 0 {
            var didClosePath = true
            
            for index in 0..<elementCount {
                let pathType = self.element(at: index, associatedPoints: points)
                
                switch pathType {
                case .moveTo:
                    path.move(to: CGPoint(x: points[0].x, y: points[0].y))
                case .lineTo:
                    path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
                    didClosePath = false
                case .curveTo:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
                    didClosePath = false
                case .closePath:
                    path.closeSubpath()
                    didClosePath = true
                @unknown default:
                    fatalError()
                }
            }
            
            if !didClosePath { path.closeSubpath() }
        }
        
        points.deallocate()
        return path
    }
}

protocol DragImageViewDelegate {
    func runConvert(path: URL);
}

//
//  Helper.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/08.
//

import Cocoa

// MARK: - helper

private let sharedController: HelperController = HelperController()

class HelperController: NSObject {
    var helperPanel: HelperPanel
    var helperTimer: Timer?
    var opacity: Int = 100

    static var shared: HelperController { get { return sharedController } }

    override init() {
        helperPanel = HelperPanel(contentRect: NSRect(x: 0, y: 0, width: 16, height: 16), styleMask: [.borderless], backing: .buffered, defer: false)
        helperPanel.becomesKeyOnlyIfNeeded = false
        helperPanel.hasShadow = false
        helperPanel.hidesOnDeactivate = false
        helperPanel.isFloatingPanel = true
        helperPanel.level = .statusBar // .floating
        //
        helperTimer = nil
    }

    func showHelper(cursorRect: NSRect, string: String, fadeDelay: Double? = nil) {
        helperPanel.imageView.image = nil
        helperPanel.imageView.alphaValue = 0
        //
        helperPanel.label.alphaValue = 1
        helperPanel.label.stringValue = string
        helperPanel.label.sizeToFit()
        helperPanel.setFrame(helperPanel.label.frame, display: true)
        //
        helperPanel.backgroundColor = .textBackgroundColor
        // helperPanel.hasShadow = false
        helperPanel.isOpaque = true
        //
        showHelper(cursorRect: cursorRect, fadeDelay: fadeDelay)
    }

    func showHelper(cursorRect: NSRect, image: NSImage) {
        helperPanel.imageView.image = image
        helperPanel.imageView.alphaValue = 1
        //
        helperPanel.label.stringValue = ""
        helperPanel.label.alphaValue = 0
        //
        helperPanel.setFrame(helperPanel.imageView.frame, display: true)
        //
        helperPanel.backgroundColor = .clear
        // helperPanel.hasShadow = false
        helperPanel.isOpaque = false
        //
        showHelper(cursorRect: cursorRect, fadeDelay: 1.0)
    }

    func showHelper(cursorRect: NSRect, fadeDelay: Double? = nil) {
        var frame = helperPanel.frame
        frame.origin = cursorRect.origin
        frame.origin.y -= frame.size.height
        // for panel not to go out of screen
        if frame.origin.y < 0 { frame.origin.y = cursorRect.origin.y + cursorRect.height }
        if let x = NSScreen.main?.frame.maxX, x < frame.maxX { frame.origin.x = x - frame.size.width }
        helperPanel.setFrameOrigin(frame.origin)
        //
        helperPanel.alphaValue = 1.0
        //
        helperPanel.orderFront(nil)
        //
        helperTimer?.invalidate()
        //
        opacity = 100
        //
        if let fadeDelay = fadeDelay {
            helperTimer = Timer.scheduledTimer(timeInterval: fadeDelay, target: self, selector: #selector(helperFadeStart(timer:)), userInfo: nil, repeats: false)
        }
    }

    func hideHelper() {
        helperPanel.orderOut(nil)
    }

    @objc func helperFadeStart(timer: Timer) {
        helperTimer?.invalidate()
        helperTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(helperFade(timer:)), userInfo: nil, repeats: true)
    }

    @objc func helperFade(timer: Timer) {
        opacity -= 5
        //
        if opacity <= 0 {
            hideHelper()
            helperTimer?.invalidate()
            helperTimer = nil
        } else { helperPanel.alphaValue = CGFloat(opacity) / 100.0 }
    }
}

class HelperPanel: NSPanel {
    override var canBecomeMain: Bool { return true }
    override var canBecomeKey: Bool { return true }

    var label: NSTextField
    var imageView: MyImageView

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        label = NSTextField(labelWithString: "")
        imageView = MyImageView(image: NSImage(named: "status-icon")!)
        //
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        //
        // backgroundColor = .textBackgroundColor
        guard let view = contentView else { return }
        view.addSubview(label)
        label.setFrameOrigin(view.frame.origin)
        label.setFrameSize(view.frame.size)
        label.wantsLayer = true
        label.layer?.borderColor = NSColor.textColor.cgColor
        label.alignment = .center
        label.isBordered = true
        label.font = NSFont.systemFont(ofSize: 14.0)
        //
        imageView.imageScaling = .scaleProportionallyUpOrDown
        view.addSubview(imageView)
        imageView.setFrameOrigin(view.frame.origin)
        imageView.setFrameSize(view.frame.size)
    }
}

// MARK: - no interpolation
// - Scale NSImage up into NSImageView :: michaelspahn.de — Hello.
// - https://michaelspahn.de/posts/nsimage-up-into-nsimageview/
class MyImageView: NSImageView {
    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.current!.imageInterpolation = .none
        super.draw(dirtyRect)
    }
}

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

    static var shared: HelperController { get { return sharedController } }

    override init() {
        helperPanel = HelperPanel(contentRect: NSRect(x: 0, y: 0, width: 16, height: 16), styleMask: [.borderless], backing: .buffered, defer: false)
        helperPanel.becomesKeyOnlyIfNeeded = false
        helperPanel.hasShadow = false
        helperPanel.hidesOnDeactivate = false
        helperPanel.isFloatingPanel = true
        helperPanel.level = .statusBar // .floating
    }

    func showHelper(cursorRect: NSRect, string: String) {
        helperPanel.label.stringValue = string
        helperPanel.label.sizeToFit()
        helperPanel.setFrame(helperPanel.label.frame, display: true)
        showHelper(cursorRect: cursorRect)
    }

    func showHelper(cursorRect: NSRect) {
        var frame = helperPanel.frame
        frame.origin = cursorRect.origin
        frame.origin.y -= frame.size.height
        // for panel not to go out of screen
        if frame.origin.y < 0 { frame.origin.y = cursorRect.origin.y + cursorRect.height }
        if let x = NSScreen.main?.frame.maxX, x < frame.maxX { frame.origin.x = x - frame.size.width }
        helperPanel.setFrameOrigin(frame.origin)
        //
        helperPanel.orderFront(nil)
    }

    func hideHelper() {
        helperPanel.orderOut(nil)
    }
}

class HelperPanel: NSPanel {
    override var canBecomeMain: Bool { return true }
    override var canBecomeKey: Bool { return true }

    var label: NSTextField

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        label = NSTextField(labelWithString: "")
        //
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        //
        backgroundColor = .textBackgroundColor
        guard let view = contentView else { return }
        view.addSubview(label)
        label.setFrameOrigin(view.frame.origin)
        label.setFrameSize(view.frame.size)
        label.wantsLayer = true
        label.layer?.borderColor = NSColor.textColor.cgColor
        label.alignment = .center
        label.isBordered = true
        label.font = NSFont.systemFont(ofSize: 14.0)
    }
}

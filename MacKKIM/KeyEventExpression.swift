//
//  KeyEventExpression.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/02.
//

import Cocoa
import Carbon.HIToolbox

class KeyEventExpression {
    open var stringValue: String? = nil

    init(_ event: NSEvent) {
        let modifierFlags = event.modifierFlags
        let keyCode: Int = Int(event.keyCode)
        //let characters = event.characters
        let charactersIgnoringModifiers = event.charactersIgnoringModifiers

        var s = ""
        if modifierFlags.contains(.option) { s += "A-" }
        if modifierFlags.contains(.control) { s += "C-" }
        if modifierFlags.contains(.command) { s += "M-" }
        if modifierFlags.contains(.shift) { s += "S-" }

        if let string = KeyEventExpression.keyCodeDictionary[keyCode] {
            if string.count == 1 {
                if let ch = charactersIgnoringModifiers { stringValue = s + ch }
                else { stringValue = nil }
            }
            else { stringValue = s + string }
        } else { stringValue = nil }
    }

    static let keyCodeDictionary: [Int:String] = [
        0 : "a",    // ANSI_A
        1 : "s",    // ANSI_S
        2 : "d",    // ANSI_D
        3 : "f",    // ANSI_F
        4 : "h",    // ANSI_H
        5 : "g",    // ANSI_G
        6 : "z",    // ANSI_Z
        7 : "x",    // ANSI_X
        8 : "c",    // ANSI_C
        9 : "v",    // ANSI_V
        10 : "section",    // ISO_Section
        11 : "b",    // ANSI_B
        12 : "q",    // ANSI_Q
        13 : "w",    // ANSI_W
        14 : "e",    // ANSI_E
        15 : "r",    // ANSI_R
        16 : "y",    // ANSI_Y
        17 : "t",    // ANSI_T
        18 : "1",    // ANSI_1
        19 : "2",    // ANSI_2
        20 : "3",    // ANSI_3
        21 : "4",    // ANSI_4
        22 : "6",    // ANSI_6
        23 : "5",    // ANSI_5
        24 : "=",    // ANSI_Equal
        25 : "9",    // ANSI_9
        26 : "7",    // ANSI_7
        27 : "-",    // ANSI_Minus
        28 : "8",    // ANSI_8
        29 : "0",    // ANSI_0
        30 : "]",    // ANSI_RightBracket
        31 : "o",    // ANSI_O
        32 : "u",    // ANSI_U
        33 : "[",    // ANSI_LeftBracket
        34 : "i",    // ANSI_I
        35 : "p",    // ANSI_P
        36 : "return",    // Return
        37 : "l",    // ANSI_L
        38 : "j",    // ANSI_J
        39 : "'",    // ANSI_Quote
        40 : "k",    // ANSI_K
        41 : ";",    // ANSI_Semicolon
        42 : "\\",    // ANSI_Backslash
        43 : ",",    // ANSI_Comma
        44 : "/",    // ANSI_Slash
        45 : "n",    // ANSI_N
        46 : "m",    // ANSI_M
        47 : ".",    // ANSI_Period
        48 : "tab",    // Tab
        49 : "space",    // Space
        50 : "`",    // ANSI_Grave
        51 : "delete",    // Delete
        53 : "escape",    // Escape
        54 : "rightcommand",    // RightCommand
        55 : "command",    // Command
        56 : "shift",    // Shift
        57 : "capslock",    // CapsLock
        58 : "option",    // Option
        59 : "control",    // Control
        60 : "rightshift",    // RightShift
        61 : "rightoption",    // RightOption
        62 : "rightcontrol",    // RightControl
        63 : "function",    // Function
        64 : "f17",    // F17
        65 : "kp.",    // ANSI_KeypadDecimal
        67 : "kp*",    // ANSI_KeypadMultiply
        69 : "kp+",    // ANSI_KeypadPlus
        71 : "kpclear",    // ANSI_KeypadClear
        72 : "volumeup",    // VolumeUp
        73 : "volumedown",    // VolumeDown
        74 : "mute",    // Mute
        75 : "kp/",    // ANSI_KeypadDivide
        76 : "kpenter",    // ANSI_KeypadEnter
        78 : "kp-",    // ANSI_KeypadMinus
        79 : "f18",    // F18
        80 : "f19",    // F19
        81 : "kp=",    // ANSI_KeypadEquals
        82 : "kp0",    // ANSI_Keypad0
        83 : "kp1",    // ANSI_Keypad1
        84 : "kp2",    // ANSI_Keypad2
        85 : "kp3",    // ANSI_Keypad3
        86 : "kp4",    // ANSI_Keypad4
        87 : "kp5",    // ANSI_Keypad5
        88 : "kp6",    // ANSI_Keypad6
        89 : "kp7",    // ANSI_Keypad7
        90 : "f20",    // F20
        91 : "kp8",    // ANSI_Keypad8
        92 : "kp9",    // ANSI_Keypad9
        93 : "¥",    // JIS_Yen
        94 : "_",    // JIS_Underscore
        95 : "kp,",    // JIS_KeypadComma
        96 : "f5",    // F5
        97 : "f6",    // F6
        98 : "f7",    // F7
        99 : "f3",    // F3
        100 : "f8",    // F8
        101 : "f9",    // F9
        102 : "eisu",    // JIS_Eisu
        103 : "f11",    // F11
        104 : "kana",    // JIS_Kana
        105 : "f13",    // F13
        106 : "f16",    // F16
        107 : "f14",    // F14
        109 : "f10",    // F10
        111 : "f12",    // F12
        113 : "f15",    // F15
        114 : "help",    // Help
        115 : "home",    // Home
        116 : "pageup",    // PageUp
        117 : "del",    // ForwardDelete
        118 : "f4",    // F4
        119 : "end",    // End
        120 : "f2",    // F2
        121 : "pagedown",    // PageDown
        122 : "f1",    // F1
        123 : "left",    // LeftArrow
        124 : "right",    // RightArrow
        125 : "down",    // DownArrow
        126 : "up",    // UpArrow
    ]
}

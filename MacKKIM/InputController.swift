//
//  InputController.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/02.
//

import Cocoa
import InputMethodKit

@objc(InputController)
class InputController: IMKInputController {
    var dict: [String:String] = [
        "3":"あ",  "e":"い",  "4":"う",  "5":"え",  "6":"お",
        "t":"か",  "g":"き",  "h":"く",  "'":"け",  "b":"こ",
        "x":"さ",  "d":"し",  "r":"す",  "p":"せ",  "c":"そ",
        "q":"た",  "a":"ち",  "z":"つ",  "w":"て",  "s":"と",
        "u":"な",  "i":"に",  "1":"ぬ",  ",":"ね",  "k":"の",
        "f":"は",  "v":"ひ",  "2":"ふ",  "=":"へ",  "-":"ほ",
        "j":"ま",  "n":"み", "\\":"む",  "/":"め",  "m":"も",
        "7":"や",              "8":"ゆ",              "9":"よ",
        "o":"ら",  "l":"り",  ".":"る",  ";":"れ",  "`":"ろ",
        "0":"わ",  ")":"を",  "y":"ん",
        "#":"ぁ",  "E":"ぃ",  "$":"ぅ",  "%":"ぇ",  "^":"ぉ",
        "Z":"っ",  "&":"ゃ",  "*":"ゅ",  "(":"ょ",
        "_":"ー",  "{":"「",  "}":"」",  "<":"、",  ">":"。",
        "?":"・",  "[":"゛",  "]":"゜",
       //
       "t[":"が", "g[":"ぎ", "h[":"ぐ", "'[":"げ", "b[":"ご",
       "x[":"ざ", "d[":"じ", "r[":"ず", "p[":"ぜ", "c[":"ぞ",
       "q[":"だ", "a[":"ぢ", "z[":"づ", "w[":"で", "s[":"ど",
       "f[":"ば", "v[":"び", "2[":"ぶ", "=[":"べ", "-[":"ぼ",
       "f]":"ぱ", "v]":"ぴ", "2]":"ぷ", "=]":"ぺ", "-]":"ぽ",
       "0]":"ゎ", "e]":"ゐ",             "5]":"ゑ",
       "4[":"ヴ", "t]":"ヵ", "']":"ヶ",
       //
       "~1":"○", "~!":"●",
       "~2":"▽", "~@":"▼",
       "~3":"△", "~#":"▲",
       "~4":"□", "~$":"■",
       "~5":"◇", "~%":"◆",
       "~6":"☆", "~^":"★",
       "~7":"◎", "~&":"£",
       "~8":"¢", "~*":"×",
       "~9":"♂", "~(":"【",
       "~0":"♀", "~)":"】",
       "~-":"〜", "~_":"∴",
       "~=":"≠", "~+":"±",
       "~\\":"＼", "~|":"‖",
       "~`":"´", "~~":"¨",
       //
       "~q":"《", "~Q":"〈",
       "~w":"》", "~W":"〉",
       "~r":"々", "~R":"仝",
       "~t":"〆", "~T":"§",
                   "~Y":"￥",
       "~p":"〒", "~P":"↑",
       "~[":"『", "~{":"〔",
       "~]":"』", "~}":"〕",
       //
       "~s":"ヽ", "~S":"ヾ",
       "~d":"ゝ", "~D":"ゞ",
       "~f":"〃", "~F":"→",
       "~g":"‐", "~G":"—",
       "~h":"←",
       "~j":"↓",
       "~k":"↑",
       "~l":"→",
       "~;":"゛", "~:":"゜",
       "~'":"‘", "~\"":"“",
       //
       "~x":"’", "~X":"”",
       "~c":"〇", "~C":"℃",
       "~v":"※", "~V":"÷",
       "~b":"°", "~B":"←",
       "~n":"′", "~N":"↓",
       "~m":"″", "~M":"〓",
       "~,":"‥", "~<":"≦",
       "~.":"…", "~>":"≧",
       "~/":"・", "~?":"∞",
    ]
    var romanPattern: NSRegularExpression?
    var startingCharset: CharacterSet
    var endingCharset: CharacterSet
    //
    // converter
    var kanaKanji: KanaKanji
    // buffers
    // var roman: String = ""
    var roman: String = "" { didSet { autoPreview() } }
    var kana: String = ""
    var kanji: String = ""
    // var markedText: String = ""
    // client
    var currentClient: IMKTextInput?
    // eisu mode
    var eisuMode: Bool = false {
        didSet { if let client = currentClient { showMode(client) } }
    }
    // candidate selection
    var candidates: IMKCandidates?
    var cand: [String] = []
    // options
    var optCompatibleBind: Bool = false
    var optKanaPreview: Bool = false { didSet { autoPreview() } }
    var optOfflineMode: Bool = false
    var optAutoConvert: Bool { get { return optOfflineMode } }
    var optSetWindowLevel: Bool = false
    var candidateSelectionChanged: Bool = false
    // direct mode
    var bundleIdentifier: String?
    var directMode: Bool {
        get {
            guard let client = bundleIdentifier else { return false }
            let directClients = UserDefaults.standard.array(forKey: "directClients") as? [String] ?? []
            return directClients.contains(client)
        }
        set {
            guard let client = bundleIdentifier else { return }
            var directClients = UserDefaults.standard.array(forKey: "directClients") as? [String] ?? []
            if newValue { directClients.insertUnique(client) }
            else { directClients.removeAll(where: { $0 == client }) }
            UserDefaults.standard.set(directClients, forKey: "directClients")
        }
    }

    // MARK: - init
    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        startingCharset = CharacterSet(charactersIn: dict.map { String($0.key.first!) } .joined())
        //
        endingCharset = CharacterSet(charactersIn: dict.map { String($0.key.last!) } .joined())
        kanaKanji = KanaKanji()
        //
        super.init(server: server, delegate: delegate, client: inputClient)
        //
        // 縦一列
        let panelType = kIMKSingleColumnScrollingCandidatePanel
        candidates = IMKCandidates(server: server, panelType: panelType)
        // 候補選択ウインドウが Spotlight の後ろに隠れないようにする
        // - [InputMethodKit] azooKey on macOSの開発知見
        // - https://zenn.dev/azookey/articles/d06b4ee8039ba9
        // > ただし、Info.plistでLSBackgroundOnly=YESが指定されている場合、
        // > 変換候補ウィンドウが文字通りBackgroundに描画されてしまうため、注意が必要です。
        // > さらにLSUIElement=YESを設定することで正しく変換候補ウィンドウが最前面に表示されました。
        // candidates?.perform(Selector(("setWindowLevel:")), with: Int(max(CGShieldingWindowLevel(), kCGPopUpMenuWindowLevel)))
        // candidates?.perform(Selector(("setWindowLevel:")), with: kCGPopUpMenuWindowLevel)
        //
        romanPattern = makeRomanPattern(rules: dict)
        //
        // options
        UserDefaults.standard.register(defaults: ["optCompatibleBind": false])
        UserDefaults.standard.register(defaults: ["optKanaPreview": false])
        UserDefaults.standard.register(defaults: ["optOfflineMode": false])
        UserDefaults.standard.register(defaults: ["optSetWindowLevel": false])
        optCompatibleBind = UserDefaults.standard.bool(forKey: "optCompatibleBind")
        optKanaPreview = UserDefaults.standard.bool(forKey: "optKanaPreview")
        optOfflineMode = UserDefaults.standard.bool(forKey: "optOfflineMode")
        optSetWindowLevel = UserDefaults.standard.bool(forKey: "optSetWindowLevel")
        //
        //
        if optSetWindowLevel {
            // candidates?.perform(Selector(("setWindowLevel:")), with: Int(max(CGShieldingWindowLevel(), kCGPopUpMenuWindowLevel)))
            candidates?.perform(Selector(("setWindowLevel:")), with: kCGPopUpMenuWindowLevel)
        }
        // direct mode
        if let textInput = inputClient as? IMKTextInput {
            bundleIdentifier = textInput.bundleIdentifier()
        }
        //
        if let kanaKanji = Cache.shared.object(forKey: "kanaKanji" as AnyObject) { self.kanaKanji = kanaKanji as! KanaKanji}
        else {
            kanaKanji = KanaKanji()
            guard let builtinKanaKanjiDic = Bundle.main.path(forResource: "kanakanji", ofType: "dic") else { return }
            kanaKanji.readDic(builtinKanaKanjiDic)
            Cache.shared.setObject(kanaKanji as AnyObject, forKey: "kanaKanji" as AnyObject)
        }
    }

    // MARK: - romanToKana
    func makeRomanPattern(rules: [String:String]) -> NSRegularExpression? {
        // let metaChars = #"[-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]"#
        let sorted = rules.sorted { $1.key.count < $0.key.count } .map { $0.key }
        let pattern = sorted.map { NSRegularExpression.escapedPattern(for: $0) } .joined(separator: "|")
        // return try? NSRegularExpression(pattern: pattern)
        return try? NSRegularExpression(pattern: "(.*?)(\(pattern))(.*)$")
    }

    func romanToKana(_ romanString: String) -> (String, String) {
        var roman = romanString
        guard let regex = romanPattern else { return ("", roman) }
        var ret = ""
        while let match = regex.firstMatch(in: roman, range: NSRange(location: 0, length: roman.count)) {
            let nsRoman = roman as NSString
            let noKana = nsRoman.substring(with: match.range(at: 1))
            let kana = dict[nsRoman.substring(with: match.range(at: 2))]!
            ret += noKana + kana // XXX
            roman = nsRoman.substring(with: match.range(at: 3))
        }
        // return ret
        // return ret + roman
        return (ret, roman)
    }

    // MARK: - menu
    override func menu() -> NSMenu! {
        let menu = NSMenu(title: "MacKKIM")
        var menuItem: NSMenuItem
        // version
        menu.addItem(withTitle: "Version " + versionString(), action: nil, keyEquivalent: "")
        // eisu mode
        menuItem = NSMenuItem(title: "Eisu Mode", action: #selector(toggleEisuMode(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = eisuMode ? .on : .off
        // compatible bind
        menuItem = NSMenuItem(title: "Compatible Bind", action: #selector(toggleCompatibleBind(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optCompatibleBind ? .on : .off
        // kana preview
        menuItem = NSMenuItem(title: "Kana Preview", action: #selector(toggleKanaPreview(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optKanaPreview ? .on : .off
        // offline mode
        menuItem = NSMenuItem(title: "Offline Mode", action: #selector(toggleOfflineMode(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optOfflineMode ? .on : .off
        // setWindowLevel:
        menuItem = NSMenuItem(title: "setWindowLevel:", action: #selector(toggleSetWindowLevel(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optSetWindowLevel ? .on : .off
        // kill
        menuItem = NSMenuItem(title: "kill -HUP", action: #selector(killHUP(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        // direct mode
        var localizedName = bundleIdentifier ?? "?"
        if let identifier = bundleIdentifier {
            for app in NSRunningApplication.runningApplications(withBundleIdentifier: identifier) {
                if let name = app.localizedName { localizedName = name; break }
            }
        }
        menuItem = NSMenuItem(title: "Direct Input in “\(localizedName)”", action: #selector(toggleDirectMode(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = directMode ? .on : .off
        //
        return menu
    }

    // version string
    private func versionString() -> String {
        let version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return "\(version ?? "unknown") (\(build ?? "unknown"))"
    }

    // eisu mode
    @objc func toggleEisuMode(_ sender: Any) {
        eisuMode.toggle()
    }

    // compatible bind
    @objc func toggleCompatibleBind(_ sender: Any) {
        optCompatibleBind.toggle()
        UserDefaults.standard.set(optCompatibleBind, forKey: "optCompatibleBind")
    }

    // kana preview
    @objc func toggleKanaPreview(_ sender: Any) {
        optKanaPreview.toggle()
        UserDefaults.standard.set(optKanaPreview, forKey: "optKanaPreview")
    }

    // offline mode
    @objc func toggleOfflineMode(_ sender: Any) {
        optOfflineMode.toggle()
        UserDefaults.standard.set(optOfflineMode, forKey: "optOfflineMode")
    }

    // setWindowLevel:
    @objc func toggleSetWindowLevel(_ sender: Any) {
        optSetWindowLevel.toggle()
        UserDefaults.standard.set(optSetWindowLevel, forKey: "optSetWindowLevel")
    }

    // kill
    @objc func killHUP(_ sender: Any) {
        let pid = getpid()
        // LOG("pid = \(pid)")
        kill(pid, SIGHUP)
    }

    // direct mode
    @objc func toggleDirectMode(_ sender: Any) {
        directMode.toggle()
    }

    // MARK: - handle input
    // candidates mode
    var candidatesMode: Bool {
        get { if let candidates: IMKCandidates = candidates, candidates.isVisible() { return true } else { return false } }
    }

    // handle
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        // clear to kill -HUP
        if let kee = KeyEventExpression(event).stringValue {
            switch kee {
            case "C-M-kpclear":
                // LOG("received \(kee), doing kill -HUP")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { self.killHUP(self) })
                return true
            default: break
            }
        }
        // direct mode
        if directMode {
            switch Int(event.keyCode) {
            case kVK_JIS_Eisu, kVK_JIS_Kana: return true
            default: break
            }
            return false
        }
        //
        guard let client = sender as? IMKTextInput else { return false }
        guard let string = event.characters else { return false }
        guard let kee = KeyEventExpression(event).stringValue else { return false }
        //
        let flags = event.modifierFlags
        let charset = CharacterSet(charactersIn: dict.map { $0.key } .joined()) // XXX
        let printable = CharacterSet.alphanumerics.union(CharacterSet.punctuationCharacters).union(.symbols) // XXX
        //
        let returnKeyEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: [], timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "\n", charactersIgnoringModifiers: "\n", isARepeat: event.isARepeat, keyCode: UInt16(kVK_Return))
        // let rightKeyEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: [], timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "\u{f703}", charactersIgnoringModifiers: "\u{f703}", isARepeat: event.isARepeat, keyCode: UInt16(kVK_RightArrow))
        // let leftKeyEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: [], timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "\u{f702}", charactersIgnoringModifiers: "\u{f702}", isARepeat: event.isARepeat, keyCode: UInt16(kVK_LeftArrow))
        let downKeyEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: [], timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "\u{f701}", charactersIgnoringModifiers: "\u{f701}", isARepeat: event.isARepeat, keyCode: UInt16(kVK_DownArrow))
        let upKeyEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: [], timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "\u{f700}", charactersIgnoringModifiers: "\u{f700}", isARepeat: event.isARepeat, keyCode: UInt16(kVK_UpArrow))
        //
        // C-num で num 番目の候補を選択して確定
        if candidatesMode {
            for i in 0...9 {
                if kee == "C-\(i)" {
                    if i <= cand.count, let down = downKeyEvent, let ret = returnKeyEvent {
                        var events: [NSEvent] = Array.init(repeating: down, count: i == 0 ? 9 : i - 1)
                        // events.append(ret)
                        if !optCompatibleBind { events.append(ret) }
                        // XXX: bad hack
                        /*
                        candidates?.hide()
                        candidates?.show()
                         */
                        candidates?.interpretKeyEvents(events)
                        // kana preview
                        autoPreview()
                    }
                    return true
                }
            }
        }
        //
        switch kee {
        case "eisu", "C-l":
            // if isEmpty { return kee == "eisu" }
            // if isEmpty { if kee != "C-l" { showMode(client) }; return kee == "eisu" }
            if isEmpty { if kee != "C-l" { eisuMode = true }; return kee != "C-l" }
            candidates?.hide()
            kanji = ""; kana = ""
            commitComposition(client: client)
            return true
        case "C-eisu", "S-eisu": // XXX
            // kana preview
            toggleKanaPreview(self)
            return true
        case "kana", "C-kana", "S-kana", "C-j":
            if candidatesMode, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]); return true }
            // hiragana/katakana
            if !kanji.isEmpty { commitComposition(client: client); return true }
            if isEmpty {
                // if !revert(client: client) { return kee == "kana" || kee == "C-kana" || kee == "S-kana" }
                // if !revert(client: client) { if kee != "C-j" { showMode(client) }; return kee == "kana" || kee == "C-kana" || kee == "S-kana" }
                if !revert(client: client) { if kee != "C-j" { eisuMode = false }; return kee != "C-j" }
            }
            var remainder = ""
            (kana, remainder) = romanToKana(roman)
            kana += remainder // XXX
            convert(client: client)
            return true
        case "C-k":
            if eisuMode { return false }
            if isEmpty { break }
            // hiragana/katakana
            if !candidatesMode && kanji.isEmpty {
                hiragana(client: client)
                commitComposition(client: client)
            } else if !candidatesMode {
                hiraganaKatakana(client: client)
                showPreedit(client: client, text: kanji)
            } else {
                candidates?.hide()
                hiraganaKatakana(client: client)
                showPreedit(client: client, text: kanji)
            }
            return true
        case "delete", "C-h":
            if eisuMode { return false }
            if isEmpty { return false }
            deleteBackward(client: client)
            return true
        case "return", "C-m":
            if eisuMode { return false }
            if optAutoConvert, candidatesMode {
                commitComposition(client: client)
                // commitComposition(client: client, withMarkedText: true)
                candidates?.hide()
                return optCompatibleBind // XXX
            }
            //
            if candidatesMode { candidates?.interpretKeyEvents([event]); return optCompatibleBind }
            if isEmpty { return false }
            // kanji = ""; kana = ""
            commitComposition(client: client)
            return optCompatibleBind
        case "tab", "S-tab":
            if eisuMode { return false }
            if optCompatibleBind {
                if candidatesMode {
                    if let event = downKeyEvent, !flags.contains(.shift) { candidates?.interpretKeyEvents([event]) }
                    if let event = upKeyEvent, flags.contains(.shift) { candidates?.interpretKeyEvents([event]) }
                    candidateSelectionChanged = true
                    return true
                }
                if isEmpty { return false }
                commitComposition(client: client)
                return true
            }
            break
        case "space", "S-space":
            if eisuMode { return false }
            if optAutoConvert, candidatesMode {
                commitComposition(client: client)
                // commitComposition(client: client, withMarkedText: true)
                candidates?.hide()
                return optCompatibleBind // XXX
            }
            //
            if candidatesMode {
                if optCompatibleBind {
                    if let event = downKeyEvent, !flags.contains(.shift) { candidates?.interpretKeyEvents([event]) }
                    if let event = upKeyEvent, flags.contains(.shift) { candidates?.interpretKeyEvents([event]) }
                    candidateSelectionChanged = true
                    return true
                } else {
                    if let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
                }
            }
            if isEmpty { return false }
            if optCompatibleBind {
                var remainder = ""
                (kana, remainder) = romanToKana(roman)
                kana += remainder // XXX
                convert(client: client)
                return true
            }
            // kanji = ""; kana = ""
            commitComposition(client: client)
            return optCompatibleBind
        case "escape":
            if eisuMode { return false }
            // if candidatesMode { candidates?.hide(); return true }
            if candidatesMode || !kanji.isEmpty {
                candidates?.hide();
                kanji = ""
                showPreedit(client: client)
                // kana preview
                autoPreview()
                return true
            }
            kanji = ""; kana = ""
            if isEmpty { return false }
            if optCompatibleBind {
                setPreedit(string: "")
                showPreedit(client: client)
                candidates?.hide()
                return true
            }
            break
        case "C-t":
            if eisuMode { return false }
            if isEmpty { return false }
            if roman.count < 2 { commitComposition(client: client); return false }
            transpose(client: client)
            return true
        default: break
        }
        //
        if eisuMode { return false }
        //
        if candidatesMode, printable.contains(string.unicodeScalars.first!), let event = returnKeyEvent {
            // candidates?.interpretKeyEvents([event])
            if !optAutoConvert || candidateSelectionChanged || !charset.contains(string.unicodeScalars.first!) { candidates?.interpretKeyEvents([event]) }
        }
        //
        if candidatesMode, !charset.contains(string.unicodeScalars.first!) {
            candidates?.interpretKeyEvents([event])
            candidateSelectionChanged = true
            return true
        }
        //
        if flags.contains(.control) || flags.contains(.command) {
            commitComposition(client: client)
            return false
        }
        //
        if let range = string.rangeOfCharacter(from: charset.inverted), range.contains(string.startIndex) {
            commitComposition(client: client)
            return false
        }
        //
        // if candidatesMode, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
        if !optAutoConvert, candidatesMode, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
        // if !kanji.isEmpty { commitComposition(client: client) }
        if !optAutoConvert, !kanji.isEmpty { commitComposition(client: client) }
        if receive(string: string, client: client) {
            // if optAutoConvert, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
            commitComposition(client: client)
            return false
        }
        //
        showPreedit(client: client)
        return true
    }
}

// MARK: - buffer of input controller
private extension InputController {
    // buffer state
    var isEmpty: Bool { get { return roman.isEmpty } }

    // receive key input as string
    // @discardableResult
    func receive(string: String, client: IMKTextInput) -> Bool {
        let remainder = romanToKana(roman + string).1
        if !remainder.isEmpty && !startingCharset.contains(remainder.unicodeScalars.first!) { return true }
        roman += string
        //
        if optAutoConvert {
            let (kana, remainder) = romanToKana(roman)
            self.kana = kana + remainder
            if !remainder.isEmpty && !endingCharset.contains(remainder.unicodeScalars.first!) { return true }
            convert(client: client)
        }
        //
        return false
    }

    func hiragana(client: IMKTextInput) {
        let (kana, remainder) = romanToKana(roman)
        /*
        if let hiragana = (kana + remainder).applyingTransform(.hiraganaToKatakana, reverse: true) { kanji = hiragana }
        // ↑ これだと「もーど」が「もおど」になる
         */
        // kanji = (kana + remainder).katakanaToHiragana()
        // ↑ これだと「ヴぁ」が「ゔぁ」になる
        kanji = kana + remainder
    }

    func hiraganaKatakana(client: IMKTextInput) {
        /*
        if NSPredicate(format: "SELF MATCHES %@", #".*[^\p{Hiragana}\p{Katakana}].*"#).evaluate(with: kanji) {
            kanji = kana
        } else if NSPredicate(format: "SELF MATCHES %@", #".*[\p{Katakana}].*"#).evaluate(with: kanji) {
            kanji = kanji.applyingTransform(.hiraganaToKatakana, reverse: true) ?? kanji
        } else if NSPredicate(format: "SELF MATCHES %@", #".*[\p{Hiragana}].*"#).evaluate(with: kanji) {
            kanji = kanji.applyingTransform(.hiraganaToKatakana, reverse: false) ?? kanji
        }
         */
        if NSPredicate(format: "SELF MATCHES %@", #".*[\p{Katakana}].*"#).evaluate(with: kanji) {
            // kanji = kanji.applyingTransform(.hiraganaToKatakana, reverse: true) ?? kanji
            kanji = kanji.katakanaToHiragana()
        } else if NSPredicate(format: "SELF MATCHES %@", #".*[\p{Hiragana}].*"#).evaluate(with: kanji) {
            // kanji = kanji.applyingTransform(.hiraganaToKatakana, reverse: false) ?? kanji
            kanji = kanji.hiraganaToKatakana()
        } else if NSPredicate(format: "SELF MATCHES %@", #".*[^\p{Hiragana}\p{Katakana}].*"#).evaluate(with: kanji) {
            kanji = kana
        }
    }

    // conversion
    func convert(client: IMKTextInput) {
        candidateSelectionChanged = false
        if optOfflineMode {
            cand = kanaKanji.look(kana)
            if let katakana = kana.applyingTransform(.hiraganaToKatakana, reverse: false) { cand.insertUnique(katakana) }
            cand.insertUnique(kana)
            if optAutoConvert { cand.insertUnique(roman) }
            //
            if kana.isEmpty || cand.count == 0 { candidates?.hide(); return } // XXX
            candidates?.update()
            candidates?.show()
            autoPreview() // XXX
            return
        }
        //
        // Google Transliterate Conversion
        let transliterator = GoogleTransliterate()
        transliterator.transliterate(text: kana + ",", callback: { (result) in
            DispatchQueue.main.async {
                self.cand = result
                self.candidates?.update()
                self.candidates?.show()
                // kana preview
                self.autoPreview()
            }
        })
    }

    // commit when conversion done
    func commitComposition(client: IMKTextInput, replacementRange: NSRange = NSMakeRange(NSNotFound, NSNotFound)) {
        let s = !kanji.isEmpty ? kanji : !kana.isEmpty ? kana : roman
    /*
    func commitComposition(client: IMKTextInput, replacementRange: NSRange = NSMakeRange(NSNotFound, NSNotFound), withMarkedText: Bool = false) {
        let s = withMarkedText && !markedText.isEmpty ? markedText : !kanji.isEmpty ? kanji : !kana.isEmpty ? kana : roman
     */
        if !s.isEmpty {
            client.insertText(s, replacementRange: replacementRange)
            roman = ""
            kana = ""
            kanji = ""
            // markedText = ""
        }
        showPreedit(client: client)
    }

    // backspace
    func deleteBackward(client: IMKTextInput) {
        candidates?.hide()
        let _ = roman.popLast()
        kanji = ""; kana = ""
        showPreedit(client: client)
        //
        if optAutoConvert {
            let (kana, remainder) = romanToKana(roman)
            self.kana = kana + remainder
            convert(client: client)
        }
    }

    // transpose 2 chars before cursor
    func transpose(client: IMKTextInput) {
        if 1 < roman.count {
            candidates?.hide()
            let s2 = String(roman.popLast()!)
            let s1 = String(roman.popLast()!)
            roman += s2 + s1
        }
        showPreedit(client: client)
        //
        if optAutoConvert {
            let (kana, remainder) = romanToKana(roman)
            self.kana = kana + remainder
            convert(client: client)
        }
    }

    // get buffer content
    func getPreedit() -> String {
        return roman
    }

    // set buffer content
    func setPreedit(string: String, remainder: String = "") {
        roman = string
    }

    // show buffer content
    func showPreedit(client: IMKTextInput, replacementRange: NSRange = NSMakeRange(NSNotFound, NSNotFound)) {
        let text = getPreedit()
        client.setMarkedText(text, selectionRange: NSMakeRange(0, text.count), replacementRange: replacementRange)
        // markedText = text
    }

    func showPreedit(client: IMKTextInput, text: String, replacementRange: NSRange = NSMakeRange(NSNotFound, NSNotFound)) {
        client.setMarkedText(text, selectionRange: NSMakeRange(0, text.count), replacementRange: replacementRange)
        // markedText = text
    }
}

// MARK: - mode of input controller
extension InputController {
    // show mode tips when activated
    override func activateServer(_ sender: Any!) {
        guard let client = sender as? IMKTextInput else { currentClient = nil; return }
        currentClient = client
        showMode(client)
    }

    // show mode tips near cursor
    func showMode(_ client: IMKTextInput) {
        var cursorRect: NSRect = .init()
        let _ = client.attributes(forCharacterIndex: 0, lineHeightRectangle: &cursorRect)
        // HelperController.shared.showHelper(cursorRect: cursorRect, image: NSImage(named: "mode-tips")!)
        let image = eisuMode ? "mode-tips-eisu" : "mode-tips-kana"
        HelperController.shared.showHelper(cursorRect: cursorRect, image: NSImage(named: image)!)
    }

    // kana preview
    func showPreview(_ client: IMKTextInput, string: String) {
        var cursorRect: NSRect = .init()
        let _ = client.attributes(forCharacterIndex: 0, lineHeightRectangle: &cursorRect)
        HelperController.shared.showHelper(cursorRect: cursorRect, string: string)
    }

    func hidePreview() {
        HelperController.shared.hideHelper()
    }

    func autoPreview() {
        let (kana, remainder) = romanToKana(roman)
        if let client = currentClient, optKanaPreview {
            let preview: String = kana + remainder
            if preview.isEmpty || candidatesMode { hidePreview() }
            else { showPreview(client, string: preview) }
        } else { hidePreview() }
    }
}

extension InputController {
    // candidates of conversion
    override func candidates(_ sender: Any!) -> [Any]! {
        return cand
    }

    // when candidate selected
    override func candidateSelected(_ candidateString: NSAttributedString!) {
        let s = candidateString.string
        // kanji = s
        kanji = kanji.isEmpty ? s : kanji
        candidates?.hide()
        guard let client = currentClient else { return }
        showPreedit(client: client)
        commitComposition(client: client)
    }

    override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        guard let client = currentClient else { return }
        showPreedit(client: client, text: candidateString.string)
        kanji = candidateString.string // XXX
        // candidateSelectionChanged = true
    }
}

// MARK: - reconvert
extension InputController {
    func revert(client: IMKTextInput) -> Bool {
        // get string
        var range = client.selectedRange()
        // if range.length == 0 { range = NSMakeRange(0, range.location) }
        if range.length == 0 { return false } // XXX
        var actualRange = range
        let string = client.string(from: range, actualRange: &actualRange)
        guard let roman = string, !roman.isEmpty else { return false }
        setPreedit(string: roman)
        showPreedit(client: client, replacementRange: actualRange)
        return true
    }
}

// MARK: - Google Transliterate
// - Google CGI API for Japanese Input
// - Google 日本語入力 - CGI API デベロッパーガイド
// - https://www.google.co.jp/ime/cgiapi.html
//
// http://www.google.com/transliterate?langpair=ja-Hira|ja&text=

// - Implementing google translation api in swift 3 iOS - Stack Overflow
// - https://stackoverflow.com/questions/42449468/implementing-google-translation-api-in-swift-3-ios

func LOG(_ string: String) {
    NSLog("■ %@", string)
}

open class GoogleTransliterate {
    public init() { }

    open func transliterate(text: String, callback: @escaping (_ transliterations: [String]) -> ()) {
        if let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "http://www.google.com/transliterate?langpair=ja-Hira%7Cja&text=\(urlEncodedText)") {
                let httpRequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        print("Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        guard httpResponse.statusCode == 200 else {
                            if let data = data {
                                print("Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            return
                        }
                        do {
                            if let data = data {
                                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                                    if let jsonData = json[0] as? [Any] {
                                        if let transliterations = jsonData[1] as? [String] {
                                            callback(transliterations)
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Serialization failed: \(error.localizedDescription)")
                        }
                    }
                })
                httpRequest.resume()
            }
        }
    }
}

// MARK: - hiragana/katakana
extension String {
    // XXX: bad hack
    /*
    func hiraganaToKatakana() -> String {
        return self.replacingOccurrences(of: "ー", with: "\0").applyingTransform(.hiraganaToKatakana, reverse: false)?.replacingOccurrences(of: "\0", with: "ー") ?? "\(self)"
    }

    // XXX: bad hack
    func katakanaToHiragana() -> String {
        return self.replacingOccurrences(of: "ー", with: "\0").applyingTransform(.hiraganaToKatakana, reverse: true)?.replacingOccurrences(of: "\0", with: "ー") ?? "\(self)"
    }
     */

    // - [Swift5] FoundationのapplyingTransformでカタカナをひらがなに変換すると長音符号(ー)が勝手に変換される
    // - https://zenn.dev/en3_hcl/articles/e0ab050b52fc77
    func hiraganaToKatakana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x3041 <= scalar.value && scalar.value <= 0x3096 { return  UnicodeScalar(scalar.value + 96)! }
            else { return scalar }
        }
        return String(String.UnicodeScalarView(result))
    }

    func katakanaToHiragana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x30A1 <= scalar.value && scalar.value <= 0x30F6 { return  UnicodeScalar(scalar.value - 96)! }
            else { return scalar }
        }
        return String(String.UnicodeScalarView(result))
    }

    // other refs:
    // - 【Swift】ひらがな→カタカナ変換を(applyingTransformを使わずに)実装してみた
    // - https://zenn.dev/onepointfive/articles/6153aa5905942a
    // - 【Swift】CFStringTransformで文字の変換！ひらがな→カタカナや半角など
    // - https://appdev-room.com/swift-cfstringtransform
    // - [iOS|Swift3] ひらがな、カタカナ変換を文字列表で行いたい « きんくまデザイン
    // - http://www.kuma-de.com/blog/2017-05-18/7317
    // - Swift でひらがな／カタカナを変換する | クロジカ
    // - https://tech.kurojica.com/archives/11899/

    // yet other refs:
    // - 漢字をひらがな/カタカナに変換する #Swift - Qiita
    // - https://qiita.com/sgr-ksmt/items/cc8882aa80a59e5a8355
    // - iOSで半角から全角へ変換したり、ローマ字からひらがなに変換したりする - 酢ろぐ！
    // - https://blog.ch3cooh.jp/entry/20120619/1340100077
}

// MARK: - unique
// - 【Swift】Arrayからユニークな順序付きリストへの変換を超絶シンプルに書く - Qiita
// - https://qiita.com/ruwatana/items/7dbbb3a4a28f63aec901
extension Array where Element: Hashable {
    func unique() -> [Element] {
        return NSOrderedSet(array: self).array as! [Element]
    }

    mutating func insertUnique(_ newElement: Element) {
        insert(newElement, at: 0)
        self = unique()
    }
}

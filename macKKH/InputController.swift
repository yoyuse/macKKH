//
//  InputController.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/02.
//

import Cocoa
import InputMethodKit

func Log(_ string: String) { NSLog("■ %@", string) }

// segmented conversion
typealias Segment = (kana: String, cand: [String])

// tuple を Equatable, Hashable に準拠させる
// - [Swift] Tuple タプルの七不思議 #tuple - Qiita
// - https://qiita.com/nak435/items/e044daa296532912a424
struct SegmentTuple: Equatable, /* Comparable, */ Hashable {
    typealias Element = Segment
    let tuple: Element
    init(_ _tuple: Element) { self.tuple = _tuple }
    func callAsFunction() -> Element { self.tuple }
    // Equatable
    static func == (lhs: SegmentTuple, rhs: SegmentTuple) -> Bool {
        lhs.tuple == rhs.tuple
    }
    /*
    // Comparable
    static func < (lhs: SegmentTuple, rhs: SegmentTuple) -> Bool {
        lhs.tuple < rhs.tuple
    }
     */
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(tuple.kana)
        hasher.combine(tuple.cand)
    }
}

@objc(InputController)
class InputController: IMKInputController {
    var dict: [String:String] { get { return optRGTs ? dictRGTs : dictUSKana } }
    var dictUSKana: [String:String] = [
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
       // "~/":"・", "~?":"∞",
       "~/":"／", "~?":"∞",
    ]
    var dictRGTs: [String:String] = [
        "a":"あ", "i":"い", "u":"う", "e":"え", "o":"お",
        "ka":"か", "ki":"き", "ku":"く", "ke":"け", "ko":"こ",
        "sa":"さ", "si":"し", "su":"す", "se":"せ", "so":"そ",
        "ta":"た", "ti":"ち", "tu":"つ", "te":"て", "to":"と",
        "na":"な", "ni":"に", "nu":"ぬ", "ne":"ね", "no":"の",
        "ha":"は", "hi":"ひ", "hu":"ふ", "he":"へ", "ho":"ほ",
        "ma":"ま", "mi":"み", "mu":"む", "me":"め", "mo":"も",
        "ya":"や", "yu":"ゆ", "yo":"よ",
        "ra":"ら", "ri":"り", "ru":"る", "re":"れ", "ro":"ろ",
        "wa":"わ", "wi":"うぃ", "we":"うぇ", "wo":"を",
        "n'":"ん",
        "ga":"が", "gi":"ぎ", "gu":"ぐ", "ge":"げ", "go":"ご",
        "za":"ざ", "zi":"じ", "zu":"ず", "ze":"ぜ", "zo":"ぞ",
        "da":"だ", "di":"ぢ", "du":"づ", "de":"で", "do":"ど",
        "ba":"ば", "bi":"び", "bu":"ぶ", "be":"べ", "bo":"ぼ",
        "pa":"ぱ", "pi":"ぴ", "pu":"ぷ", "pe":"ぺ", "po":"ぽ",
        //
        "kya":"きゃ", "kyu":"きゅ", "kye":"きぇ", "kyo":"きょ",
        "sya":"しゃ", "syu":"しゅ", "sye":"しぇ", "syo":"しょ",
        "sha":"しゃ", "shu":"しゅ", "she":"しぇ", "sho":"しょ",
        "cha":"ちゃ", "chu":"ちゅ", "che":"ちぇ", "cho":"ちょ",
        "tya":"ちゃ", "tyu":"ちゅ", "tye":"ちぇ", "tyo":"ちょ",
        "nya":"にゃ", "nyu":"にゅ", "nye":"にぇ", "nyo":"にょ",
        "hya":"ひゃ", "hyu":"ひゅ", "hye":"ひぇ", "hyo":"ひょ",
        "mya":"みゃ", "myu":"みゅ", "mye":"みぇ", "myo":"みょ",
        "rya":"りゃ", "ryu":"りゅ", "rye":"りぇ", "ryo":"りょ",
        "gya":"ぎゃ", "gyu":"ぎゅ", "gye":"ぎぇ", "gyo":"ぎょ",
        "zya":"じゃ", "zyu":"じゅ", "zye":"じぇ", "zyo":"じょ",
        "ja":"じゃ", "ju":"じゅ", "je":"じぇ", "jo":"じょ",
        "dya":"ぢゃ", "dyu":"ぢゅ", "dye":"ぢぇ", "dyo":"ぢょ",
        "bya":"びゃ", "byu":"びゅ", "bye":"びぇ", "byo":"びょ",
        "pya":"ぴゃ", "pyu":"ぴゅ", "pye":"ぴぇ", "pyo":"ぴょ",
        //
        "kwa":"くぁ", "kwi":"くぃ", "kwe":"くぇ", "kwo":"くぉ",
        "tsa":"つぁ", "tsi":"つぃ", "tse":"つぇ", "tso":"つぉ",
        "fa":"ふぁ", "fi":"ふぃ", "fe":"ふぇ", "fo":"ふぉ",
        "gwa":"ぐぁ", "gwi":"ぐぃ", "gwe":"ぐぇ", "gwo":"ぐぉ",
        //
        "ji":"じ", "fu":"ふ", "ye":"いぇ", "who":"うぉ",
        "whi":"うぃ", "whe":"うぇ", // XXX
        //
        "va":"ヴぁ", "vi":"ヴぃ", "vu":"ヴ", "ve":"ヴぇ", "vo":"ヴぉ",
        //
        "xa":"ぁ", "xi":"ぃ", "xu":"ぅ", "xe":"ぇ", "xo":"ぉ",
        "xya":"ゃ", "xyu":"ゅ", "xyo":"ょ", "xwa":"ゎ",
        "xka":"ヵ", "xke":"ヶ",
        //
        "wyi":"ゐ", "wye":"ゑ",
        "thi":"てぃ", "thu":"てゅ", "twu":"とぅ",
        "dhi":"でぃ", "dhu":"でゅ", "dwu":"どぅ",
        "fyu":"ふゅ", "vyu":"ヴゅ", "qwa":"くゎ",
        //
        "n":"ん",
        //
        "-":"ー", "[":"「", "]":"」", ".":"。", ",":"、",
        "/":"・",
        //
        "w":"を", "r":"る", "t":"た", "s":"し", "d":"で",
        "g":"が", "h":"は", "k":"か", "m":"ま",
        "y":"き", "p":"こ", "f":"と", "j":"の", "l":"す", "z":"て",
        "x":"っ", "c":"く", "v":"に", "b":"な",
        //
        "w;":"を", "r;":"る", "t;":"た", "s;":"し", "d;":"で",
        "g;":"が", "h;":"は", "k;":"か", "m;":"ま",
        "y;":"き", "p;":"こ", "f;":"と", "j;":"の", "l;":"す", "z;":"て",
        "x;":"っ", "c;":"く", "v;":"に", "b;":"な",
        //
        "n;":"ん",
        "rq":"るい", "tq":"たい", "sq":"しょ", "dq":"であ",
        "gq":"がい", "hq":"はい", "kq":"かい", "mq":"まい",
        "yq":"きょ",
        "pq":"こう", "fq":"とう", "jq":"のう", "lq":"すう", "zq":"てい",
        "xq":"っけ", "cq":"くう", "vq":"にゅ", "bq":"ない",
        //
        "q1":"○", "q!":"●",
        "q2":"▽", "q@":"▼",
        "q3":"△", "q#":"▲",
        "q4":"□", "q$":"■",
        "q5":"◇", "q%":"◆",
        "q6":"☆", "q^":"★",
        "q7":"◎", "q&":"£",
        "q8":"¢", "q*":"×",
        "q9":"♂", "q(":"【",
        "q0":"♀", "q)":"】",
        "q-":"〜", "q_":"∴",
        "q=":"≠", "q+":"±",
        "q\\":"＼", "q|":"‖",
        "q`":"´", "q~":"¨",
        //
        "qq":"’", "qQ":"”",
        "qr":"々", "qR":"仝",
        "qt":"〆", "qT":"§",
        "qp":"〒", "qP":"↑",
        "q[":"『", "q{":"〔",
        "q]":"』", "q}":"〕",
        //
        "qs":"ヽ", "qS":"ヾ",
        "qd":"ゝ", "qD":"ゞ",
        "qf":"〃", "qF":"→",
        "qg":"‐", "qG":"—",
        "qh":"←",
        "qj":"↓",
        "qk":"↑",
        "ql":"→",
        "q;":"゛", "q:":"゜",
        "q'":"‘", "q\"":"“",
        //
        "qz":"《", "qZ":"〈",
        "qx":"》", "qX":"〉",
        "qc":"〇", "qC":"℃",
        "qv":"※", "qV":"÷",
        "qb":"°", "qB":"←",
        "qn":"′", "qN":"↓",
        "qm":"″", "qM":"〓",
        "q,":"‥", "q<":"≦",
        "q.":"…", "q>":"≧",
        "q/":"・", "q?":"∞",
    ]
    var romanPatternUSKana: NSRegularExpression?
    var romanPatternRGTs: NSRegularExpression?
    var romanPattern: NSRegularExpression? { get { optRGTs ? romanPatternRGTs : romanPatternUSKana } }
    var printable: CharacterSet
    var charset: CharacterSet { get { return CharacterSet(charactersIn: dict.map { $0.key } .joined()) } } // XXX
    // var startingCharset: CharacterSet
    // var endingCharset: CharacterSet
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
    var segments: [Segment] = []
    // conversion history
    var hist: [SegmentTuple] = []
    // options
    var optRGTs: Bool = false
    var optCompatibleBind: Bool = false
    var optKanaPreview: Bool = false { didSet { autoPreview() } }
    var optOfflineMode: Bool = false
    var optSegmented: Bool = false
    var optAutoConvert: Bool { get { return optOfflineMode } }
    // var optSetWindowLevel: Bool = false
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
    // MODETIPS
    var timer: Timer = Timer()
    // /MODETIPS
    var restartOnDeactivate: Bool = false
    // prefix kanchoku
    var optPrefixKanchoku: Bool = false
    var prefix: String = "|"
    var prefixed: Bool = false
    var tt: TT
    var help: String = ""
    // /prefix kanchoku

    // MARK: - init
    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        printable = CharacterSet.alphanumerics.union(CharacterSet.punctuationCharacters).union(.symbols) // XXX
        // charset = CharacterSet(charactersIn: dict.map { $0.key } .joined()) // XXX
        // startingCharset = CharacterSet(charactersIn: dict.map { String($0.key.first!) } .joined())
        // endingCharset = CharacterSet(charactersIn: dict.map { String($0.key.last!) } .joined())
        kanaKanji = KanaKanji()
        // prefix kanchoku
        tt = TT()
        // /prefix kanchoku
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
        // romanPattern = makeRomanPattern(rules: dict)
        romanPatternUSKana = makeRomanPattern(rules: dictUSKana)
        romanPatternRGTs = makeRomanPattern(rules: dictRGTs)
        //
        // options
        UserDefaults.standard.register(defaults: ["optRGTs": false])
        UserDefaults.standard.register(defaults: ["optCompatibleBind": false])
        UserDefaults.standard.register(defaults: ["optKanaPreview": false])
        UserDefaults.standard.register(defaults: ["optOfflineMode": false])
        UserDefaults.standard.register(defaults: ["optSegmented": false])
        // prefix kanchoku
        UserDefaults.standard.register(defaults: ["optPrefixKanchoku": false])
        // /prefix kanchoku
        // UserDefaults.standard.register(defaults: ["optSetWindowLevel": false])
        optRGTs = UserDefaults.standard.bool(forKey: "optRGTs")
        optCompatibleBind = UserDefaults.standard.bool(forKey: "optCompatibleBind")
        optKanaPreview = UserDefaults.standard.bool(forKey: "optKanaPreview")
        optOfflineMode = UserDefaults.standard.bool(forKey: "optOfflineMode")
        optSegmented = UserDefaults.standard.bool(forKey: "optSegmented")
        // prefix kanchoku
        optPrefixKanchoku = UserDefaults.standard.bool(forKey: "optPrefixKanchoku")
        // /prefix kanchoku
        // optSetWindowLevel = UserDefaults.standard.bool(forKey: "optSetWindowLevel")
        //
        /*
        if optSetWindowLevel {
            // candidates?.perform(Selector(("setWindowLevel:")), with: Int(max(CGShieldingWindowLevel(), kCGPopUpMenuWindowLevel)))
            candidates?.perform(Selector(("setWindowLevel:")), with: kCGPopUpMenuWindowLevel)
        }
         */
        // direct mode
        if let textInput = inputClient as? IMKTextInput {
            bundleIdentifier = textInput.bundleIdentifier()
        }
        //
        if let kanaKanji = Cache.shared.object(forKey: "kanaKanji" as AnyObject) { self.kanaKanji = kanaKanji as! KanaKanji }
        else {
            kanaKanji = KanaKanji()
            guard let builtinKanaKanjiDic = Bundle.main.path(forResource: "kanakanji", ofType: "dic") else { return }
            guard let builtinTankanjiRev = Bundle.main.path(forResource: "tankanji", ofType: "rev") else { return }
            kanaKanji.readDic(builtinKanaKanjiDic)
            kanaKanji.readRev(builtinTankanjiRev)
            Cache.shared.setObject(kanaKanji as AnyObject, forKey: "kanaKanji" as AnyObject)
        }
        // prefix kanchoku
        if let tt = Cache.shared.object(forKey: "tt" as AnyObject) { self.tt = tt as! TT }
        else {
            tt = TT()
            Cache.shared.setObject(tt as AnyObject, forKey: "tt" as AnyObject)
        }
        // /prefix kanchoku
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
        let menu = NSMenu(title: "macKKH")
        var menuItem: NSMenuItem
        // version
        menu.addItem(withTitle: "Version " + versionString(), action: nil, keyEquivalent: "")
        //
        menu.addItem(.separator())
        // eisu mode
        menuItem = NSMenuItem(title: "Eisu Mode", action: #selector(toggleEisuMode(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = eisuMode ? .on : .off
        //
        menu.addItem(.separator())
        // rgts
        menuItem = NSMenuItem(title: "RGTs", action: #selector(toggleRGTs(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optRGTs ? .on : .off
        // compatible bind
        menuItem = NSMenuItem(title: "Compatible Bind", action: #selector(toggleCompatibleBind(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optCompatibleBind ? .on : .off
        // kana preview
        menuItem = NSMenuItem(title: "Kana Preview", action: #selector(toggleKanaPreview(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optKanaPreview ? .on : .off
        // offline mode
        menuItem = NSMenuItem(title: "Offline Auto Convert", action: #selector(toggleOfflineMode(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optOfflineMode ? .on : .off
        // segmented conversion
        menuItem = NSMenuItem(title: "Single Candidate / Reconvert", action: #selector(toggleSegmented(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optSegmented ? .on : .off
        // prefix kanchoku
        menuItem = NSMenuItem(title: "TT-code input (“\(prefix)” Prefix)", action: #selector(togglePrefixKanchoku(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optPrefixKanchoku ? .on : .off
        // /prefix kanchoku
        /*
        // setWindowLevel:
        menuItem = NSMenuItem(title: "setWindowLevel:", action: #selector(toggleSetWindowLevel(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = optSetWindowLevel ? .on : .off
         */
        //
        menu.addItem(.separator())
        // restart on deactivate
        menuItem = NSMenuItem(title: "Restart on Deactivate", action: #selector(toggleRestartOnDeactivate(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menuItem.state = restartOnDeactivate ? .on : .off
        /*
        // kill
        menuItem = NSMenuItem(title: "kill -HUP", action: #selector(killHUP(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
         */
        //
        menu.addItem(.separator())
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

    // version string
    private func versionString() -> String {
        let version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return "\(version ?? "unknown") (\(build ?? "unknown"))"
    }

    // eisu mode
    @objc func toggleEisuMode(_ sender: Any) {
        eisuMode.toggle()
    }

    // rgts
    @objc func toggleRGTs(_ sender: Any) {
        optRGTs.toggle()
        UserDefaults.standard.set(optRGTs, forKey: "optRGTs")
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

    // segmented conversion
    @objc func toggleSegmented(_ sender: Any) {
        optSegmented.toggle()
        UserDefaults.standard.set(optSegmented, forKey: "optSegmented")
    }

    // prefix kanchoku
    @objc func togglePrefixKanchoku(_ sender: Any) {
        optPrefixKanchoku.toggle()
        tt.reset()
        UserDefaults.standard.set(optPrefixKanchoku, forKey: "optPrefixKanchoku")
    }
    // /prefix kanchoku

    /*
    // setWindowLevel:
    @objc func toggleSetWindowLevel(_ sender: Any) {
        optSetWindowLevel.toggle()
        UserDefaults.standard.set(optSetWindowLevel, forKey: "optSetWindowLevel")
    }
     */

    /*
    // kill
    @objc func killHUP(_ sender: Any) {
        let pid = getpid()
        // Log("pid = \(pid)")
        kill(pid, SIGHUP)
    }
     */

    @objc func toggleRestartOnDeactivate(_ sender: Any) {
        restartOnDeactivate.toggle()
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
        // prefix kanchoku
        help = "" // clear help
        // /prefix kanchoku
        /*
        // clear to kill -HUP
        if let kee = KeyEventExpression(event).stringValue {
            switch kee {
            case "C-M-kpclear":
                // Log("received \(kee), doing kill -HUP")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { self.killHUP(self) })
                return true
            default: break
            }
        }
         */
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
        } else if isEmpty {
            // C-num でカーソル位置から num 文字さかのぼって選択し再変換
            for i in 1...9 {
                if kee == "C-\(i)" {
                    if revert(client: client, num: i) {
                        kana = roman
                        convert(client: client)
                        return true
                    }
                }
            }
        }
        //
        switch kee {
        case "eisu", "C-l":
            // if isEmpty { return kee == "eisu" }
            // if isEmpty { if kee != "C-l" { showMode(client) }; return kee == "eisu" }
            if isEmpty { if kee != "C-l" { eisuMode = true }; return kee != "C-l" }
            // candidates?.hide()
            kanji = ""; kana = ""
            // 無変換確定
            if kee == "eisu" {
                commitComposition(client: client)
                candidates?.hide()
                hidePreview()
                return true
            }
            /* */
            // 無変換
            if !optCompatibleBind { commitComposition(client: client) }
            else if !candidatesMode { showPreedit(client: client) }
            else {
                if optAutoConvert { candidateSelectionChanged = true }
                showPreedit(client: client)
            }
            candidates?.hide()
            hidePreview()
            /* */
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
        // case "C-k":
        case "C-u":
            if eisuMode { return false }
            if isEmpty { break }
            /*
            // hiragana/katakana
            if !candidatesMode && kanji.isEmpty {
                hiragana(client: client)
                commitComposition(client: client)
            } else if !candidatesMode {
                hiraganaKatakana(client: client)
                showPreedit(client: client, text: kanji)
            } else {
                if optAutoConvert {
                    kanji = kana.hiraganaToKatakana()
                    candidateSelectionChanged = true
                }
                candidates?.hide()
                hiraganaKatakana(client: client)
                showPreedit(client: client, text: kanji)
            }
            return true
             */
            // prefix kanchoku
            // hiragana
            // hiragana(client: client)
            if optPrefixKanchoku { kana(client: client) }
            else { hiragana(client: client) }
            // /prefix kanchoku
            if !optCompatibleBind { commitComposition(client: client) }
            else if !candidatesMode { showPreedit(client: client, text: kanji) }
            else {
                if optAutoConvert { candidateSelectionChanged = true }
                showPreedit(client: client, text: kanji)
            }
            candidates?.hide()
            hidePreview()
            return true
        // case "C-u":
        case "C-o":
            if eisuMode { return false }
            if isEmpty { break }
            // hankaku kana
            let (kana, remainder) = romanToKana(roman)
            kanji = (kana + remainder).hiraganaToKatakana().zenkakuToHankaku()
            if !optCompatibleBind { commitComposition(client: client) }
            else if !candidatesMode { showPreedit(client: client, text: kanji) }
            else {
                if optAutoConvert { candidateSelectionChanged = true }
                showPreedit(client: client, text: kanji)
            }
            candidates?.hide()
            hidePreview()
            return true
        // case "C-i":
        case "C-k":
            if eisuMode { return false }
            if isEmpty { break }
            // katakana
            katakana(client: client)
            if !optCompatibleBind { commitComposition(client: client) }
            else if !candidatesMode { showPreedit(client: client, text: kanji) }
            else {
                if optAutoConvert { candidateSelectionChanged = true }
                showPreedit(client: client, text: kanji)
            }
            candidates?.hide()
            hidePreview()
            return true
        // case "C-o":
        // case "C-y":
        case "C-t":
            if eisuMode { return false }
            if isEmpty { break }
            // zenkaku eisu
            kanji = roman.hankakuToZenkaku()
            if !optCompatibleBind { commitComposition(client: client) }
            else if !candidatesMode { showPreedit(client: client, text: kanji) }
            else {
                if optAutoConvert { candidateSelectionChanged = true }
                showPreedit(client: client, text: kanji)
            }
            candidates?.hide()
            hidePreview()
            return true
        case "delete", "C-h":
            if eisuMode { return false }
            if isEmpty { return false }
            //
            // if optCompatibleBind && !optAutoConvert && (candidatesMode || !kanji.isEmpty) {
            if /* optCompatibleBind && */ !optAutoConvert && (candidatesMode || !kanji.isEmpty) {
                candidates?.hide()
                kanji = ""; kana = ""
                showPreedit(client: client)
                autoPreview()
                return true
            }
            // prefix kanchoku
            if optPrefixKanchoku && !tt.isReset { tt.reset(); return true }
            // /prefix kanchoku
            //
            deleteBackward(client: client)
            return true
        case "return", "C-m":
            if eisuMode { return false }
            if optAutoConvert, !candidateSelectionChanged { kanji = ""; kana = "" }
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
            // break
            if optAutoConvert,!candidateSelectionChanged { kanji = ""; kana = "" }
            if optAutoConvert, candidatesMode {
                commitComposition(client: client)
                candidates?.hide()
                return false
            }
            if candidatesMode, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
            if isEmpty { return false }
            commitComposition(client: client)
            return false
        case "space", "S-space":
            if eisuMode { return false }
            if optAutoConvert, !candidateSelectionChanged { kanji = ""; kana = "" }
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
            //
            // “読み空白”
            if kee == "S-space", /* optCompatibleBind, */ !candidatesMode, kanji.isEmpty {
                roman += " "
                showPreedit(client: client)
                autoPreview()
                return true
            }
            //
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
        // case "escape":
        case "escape", "C-g":
            if eisuMode { return false }
            // if candidatesMode { candidates?.hide(); return true }
            if candidatesMode || !kanji.isEmpty {
                candidates?.hide();
                kanji = ""; kana = ""
                showPreedit(client: client)
                // kana preview
                autoPreview()
                return true
            }
            // prefix kanchoku
            if optPrefixKanchoku && !tt.isReset { tt.reset(); return true }
            // /prefix kanchoku
            kanji = ""; kana = ""
            if isEmpty { return false }
            /*
            if optCompatibleBind {
                setPreedit(string: "")
                showPreedit(client: client)
                candidates?.hide()
                return true
            }
            break
             */
            setPreedit(string: "")
            showPreedit(client: client)
            candidates?.hide()
            return true
            /*
        case "C-t":
            if eisuMode { return false }
            if isEmpty { return false }
            if roman.count < 2 { commitComposition(client: client); return false }
            transpose(client: client)
            return true
             */
        default: break
        }
        //
        if eisuMode { return false }
        //
        if candidatesMode, printable.contains(string.unicodeScalars.first!), let event = returnKeyEvent {
            if optAutoConvert, !candidateSelectionChanged { kanji = ""; kana = "" }
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
        /*
        // 大文字・記号など
        if let range = string.rangeOfCharacter(from: charset.inverted), range.contains(string.startIndex) {
            commitComposition(client: client)
            return false
        }
         */
        // 非印字文字 (矢印キーなど)
        if !printable.contains(string.unicodeScalars.first!) {
            commitComposition(client: client)
            return false
        }
        //
        if optAutoConvert, candidateSelectionChanged { commitComposition(client: client) }
        // if candidatesMode, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
        if !optAutoConvert, candidatesMode, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
        // if !kanji.isEmpty { commitComposition(client: client) }
        if !optAutoConvert, !kanji.isEmpty { commitComposition(client: client) }
        if receive(string: string, client: client) {
            // if optAutoConvert, let event = returnKeyEvent { candidates?.interpretKeyEvents([event]) }
            commitComposition(client: client)
            return true
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
        // prefix kanchoku
        if optPrefixKanchoku {
            if prefixed {
                let s = tt.trans(char: string)
                if s == string { tt.reset() }
                roman += s
                //
                if optAutoConvert {
                    var remainder = ""
                    (kana, remainder) = romanToKana(roman)
                    kana += remainder
                    convert(client: client)
                }
                //
                prefixed = false
                return false
            }
            if !prefixed && string == prefix { prefixed = true; return false }
            tt.reset()
        }
        // /prefix kanchoku
        let remainder = romanToKana(roman + string).1
        // 大文字・記号など
        // if !remainder.isEmpty && !startingCharset.contains(remainder.unicodeScalars.first!) { return true }
        roman += string
        //
        if optAutoConvert {
            let (kana, remainder) = romanToKana(roman)
            self.kana = kana + remainder
            // 大文字・記号など
            // if !remainder.isEmpty && !endingCharset.contains(remainder.unicodeScalars.first!) { return true }
            convert(client: client)
        }
        //
        return false
    }

    // prefix kanchoku
    func kana(client: IMKTextInput) {
        let (kana, remainder) = romanToKana(roman)
        kanji = kana + remainder
        self.kana = kanji // XXX: Compatible Bind でひらがなのヘルプを抑制
    }
    // /prefix kanchoku

    func hiragana(client: IMKTextInput) {
        let (kana, remainder) = romanToKana(roman)
        /*
        if let hiragana = (kana + remainder).applyingTransform(.hiraganaToKatakana, reverse: true) { kanji = hiragana }
        // ↑ これだと「もーど」が「もおど」になる
         */
        kanji = (kana + remainder).katakanaToHiragana()
        // kanji = kana + remainder
    }

    func katakana(client: IMKTextInput) {
        let (kana, remainder) = romanToKana(roman)
        kanji = (kana + remainder).hiraganaToKatakana()
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
        if NSPredicate(format: "SELF MATCHES %@", #"[\p{Katakana}ー・]+"#).evaluate(with: kanji) {
            kanji = kanji.katakanaToHiragana()
        } else if NSPredicate(format: "SELF MATCHES %@", #"[\p{Hiragana}ー・]+"#).evaluate(with: kanji) {
            kanji = kanji.hiraganaToKatakana()
        } else if NSPredicate(format: "SELF MATCHES %@", #".*[^\p{Hiragana}\p{Katakana}ー・].*"#).evaluate(with: kanji) {
            kanji = kana
        }
    }

    // conversion
    func convert(client: IMKTextInput) {
        candidateSelectionChanged = false
        if optOfflineMode {
            // maze
            // cand = kanaKanji.look(kana)
            cand = kanaKanji.lookMaze(kana)
            // /maze
            /*
            if let katakana = kana.applyingTransform(.hiraganaToKatakana, reverse: false) { cand.insertUnique(katakana) }
            cand.insertUnique(kana)
            if optAutoConvert { cand.insertUnique(roman) }
            //
            // if kana.isEmpty || cand.count == 0 { candidates?.hide(); return } // XXX
             */
            /* */
            /*
            if kana.isEmpty || cand.count == 0 {
                let (kana, remainder) = romanToKana(roman)
                cand = [kana + remainder]
            }
             */
            if cand.count == 0 {
                /*
                candidates?.hide()
                return
                 */
                if !kana.isEmpty { cand = [kana] }
                else { candidates?.hide(); return }
            }
            //
            candidates?.update()
            candidates?.show()
            autoPreview() // XXX
            return
        }
        //
        // Google Transliterate Conversion
        if optSegmented {
            if let found = hist.first(where: { $0.tuple.kana == kana || $0.tuple.cand.firstIndex(of: kana) != nil }) {
                cand = found.tuple.cand
                //
                candidates?.update()
                candidates?.show()
                // kana preview
                autoPreview()
                // XXX: hide cand window when only one cand
                if cand.count == 1 { candidates?.hide() }
                //
                return
            }
            //
            let transliterator = GoogleTransliterate()
            transliterator.transliterateSegmented(text: kana, callback: { (result) in
                DispatchQueue.main.async {
                    self.segments = result
                    // for hist
                    for segment in self.segments {
                        self.hist.insertUnique(SegmentTuple(segment))
                    }
                    //
                    let candidate = self.segments.reduce("", { $0 + $1.cand[0] })
                    self.cand = self.segments.count == 1 ? self.segments[0].cand : [candidate]
                    //
                    self.candidates?.update()
                    self.candidates?.show()
                    // kana preview
                    self.autoPreview()
                    // XXX: hide cand window when only one cand
                    if self.cand.count == 1 { self.candidates?.hide() }
                }
            })
            return
        }
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
            // prefix kanchoku
            // let certain = kana
            let certain = !kana.isEmpty ? kana : roman
            if optPrefixKanchoku && s != certain { help = tt.help(forString: s, withCertain: certain) }
            // /prefix kanchoku
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
        super.activateServer(sender)
        //
        guard let client = sender as? IMKTextInput else { currentClient = nil; return }
        currentClient = client
        // MODETIPS
        // showMode(client)
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in self.showMode(client) }
        // /MODETIPS
    }

    // MODETIPS
    override func deactivateServer(_ sender: Any!) {
        hideMode()
        timer.invalidate()
        if restartOnDeactivate {
            // Log("restarting...")
            let delay = 0.1 // 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { kill(getpid(), SIGHUP) })
        }
        //
        super.deactivateServer(sender)
    }
    // /MODETIPS

    // show mode tips near cursor
    func showMode(_ client: IMKTextInput) {
        var cursorRect: NSRect = .init()
        let _ = client.attributes(forCharacterIndex: 0, lineHeightRectangle: &cursorRect)
        // HelperController.shared.showHelper(cursorRect: cursorRect, image: NSImage(named: "mode-kana")!)
        // let image = eisuMode ? "mode-eisu" : "mode-kana"
        // let image = directMode ? "mode-direct" : eisuMode ? "mode-eisu" : "mode-kana"
        let image = directMode ? "mode-direct" : bundleIdentifier != nil ? (eisuMode ? "mode-eisu" : "mode-kana") : (eisuMode ? "mode-unknown-eisu" : "mode-unknown-kana")
        HelperController.shared.showHelper(cursorRect: cursorRect, image: NSImage(named: image)!)
    }

    // MODETIPS
    func hideMode() {
        HelperController.shared.hideHelper()
    }
    // /MODETIPS

    // kana preview
    // prefix kanchoku
    func showPreview(_ client: IMKTextInput, string: String, fadeDelay: Double? = nil) {
        var cursorRect: NSRect = .init()
        let _ = client.attributes(forCharacterIndex: 0, lineHeightRectangle: &cursorRect)
        HelperController.shared.showHelper(cursorRect: cursorRect, string: string, fadeDelay: fadeDelay)
    }
    // /prefix kanchoku

    func hidePreview() {
        HelperController.shared.hideHelper()
    }

    func autoPreview() {
        let (kana, remainder) = romanToKana(roman)
        if let client = currentClient, optKanaPreview {
            let preview: String = kana + remainder
            // prefix kanchoku
            if candidatesMode { hidePreview() }
            else if !preview.isEmpty { showPreview(client, string: preview) }
            else if !help.isEmpty { showPreview(client, string: help, fadeDelay: 5.0) }
            else { hidePreview() }
            // /prefix kanchoku
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
        /*
        let s = candidateString.string
        // kanji = s
        kanji = kanji.isEmpty ? s : kanji
        if optAutoConvert, !candidateSelectionChanged { kanji = ""; kana = "" }
         */
        // if (!optAutoConvert || candidateSelectionChanged) && kanji.isEmpty  { kanji = candidateString.string }
        if !optAutoConvert || candidateSelectionChanged  { kanji = candidateString.string }
        /* */
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
    // func revert(client: IMKTextInput) -> Bool {
    func revert(client: IMKTextInput, num: Int? = nil) -> Bool {
        // get string
        // var range = client.selectedRange()
        // if range.length == 0 { range = NSMakeRange(0, range.location) }
        // let range = client.selectedRange()
        // if range.length == 0 { return false } // XXX
        var range = client.selectedRange()
        if range.length == 0, let num = num { range = NSMakeRange(range.location - num, num) }
        //
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

open class GoogleTransliterate {
    public init() { }

    open func transliterate(text: String, callback: @escaping (_ transliterations: [String]) -> ()) {
        if let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "http://www.google.com/transliterate?langpair=ja-Hira%7Cja&text=\(urlEncodedText)") {
                let httpRequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        NSLog("%@", "Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        guard httpResponse.statusCode == 200 else {
                            if let data = data {
                                NSLog("%@", "Response [\(httpResponse.statusCode)] - \(data)")
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
                            NSLog("%@", "Serialization failed: \(error.localizedDescription)")
                        }
                    }
                })
                httpRequest.resume()
            }
        }
    }

    func transliterateSegmented(text: String, callback: @escaping (_ transliterations: [Segment]) -> ()) {
        if let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "http://www.google.com/transliterate?langpair=ja-Hira%7Cja&text=\(urlEncodedText)") {
                let httpRequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        NSLog("%@", "Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        guard httpResponse.statusCode == 200 else {
                            if let data = data {
                                NSLog("%@", "Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            return
                        }
                        do {
                            if let data = data {
                                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                                    /* */
                                    let segmentList: [Segment] = json.map {
                                        let elm = $0 as! [Any]
                                        return (kana: elm[0] as! String, cand: elm[1] as! [String])
                                    }
                                    callback(segmentList)
                                    /* */
                                }
                            }
                        } catch {
                            NSLog("%@", "Serialization failed: \(error.localizedDescription)")
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
    // - 平仮名 (Unicodeのブロック) - Wikipedia
    // - https://ja.wikipedia.org/wiki/%E5%B9%B3%E4%BB%AE%E5%90%8D_(Unicode%E3%81%AE%E3%83%96%E3%83%AD%E3%83%83%E3%82%AF)
    // - 片仮名 (Unicodeのブロック) - Wikipedia
    // - https://ja.wikipedia.org/wiki/%E7%89%87%E4%BB%AE%E5%90%8D_(Unicode%E3%81%AE%E3%83%96%E3%83%AD%E3%83%83%E3%82%AF)

    // ヴヵヶ はカタカナのまま (ゔゕゖ にしない)
    // ゝゞ ←→ ヽヾ の変換を行う

    func hiraganaToKatakana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            // if 0x3041 <= scalar.value && scalar.value <= 0x3096 { return  UnicodeScalar(scalar.value + 96)! }
            if 0x3041 <= scalar.value && scalar.value <= 0x3093 || scalar.value == 0x309D || scalar.value == 0x309E { return  UnicodeScalar(scalar.value + 96)! }
            else { return scalar }
        }
        return String(String.UnicodeScalarView(result))
    }

    func katakanaToHiragana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            // if 0x30A1 <= scalar.value && scalar.value <= 0x30F6 { return  UnicodeScalar(scalar.value - 96)! }
            if 0x30A1 <= scalar.value && scalar.value <= 0x30F3 || scalar.value == 0x30FD || scalar.value == 0x30FE { return  UnicodeScalar(scalar.value - 96)! }
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

// MARK: - hankaku/zenkaku
extension String {
    // - 半角カナ - Wikipedia
    // - https://ja.wikipedia.org/wiki/%E5%8D%8A%E8%A7%92%E3%82%AB%E3%83%8A

    // ヮヰヱヵヶ ←→ ﾜﾟｲﾟｴﾟｶﾟｹﾟ の変換を行う
    // 単独の濁点・半濁点 ゛゜ は触らない (うまく処理できない)
    // static let HankakuSpecial = "ﾜﾟ/ｲﾟ/ｴﾟ/ｶﾟ/ｹﾟ/ﾞ/ﾟ".components(separatedBy: "/")
    // static let ZenkakuSpecial = "ヮ/ヰ/ヱ/ヵ/ヶ/゛/゜".components(separatedBy: "/")
    static let HankakuSpecial = "ﾜﾟ ｲﾟ ｴﾟ ｶﾟ ｹﾟ".components(separatedBy: " ")
    static let ZenkakuSpecial = "ヮ ヰ ヱ ヵ ヶ".components(separatedBy: " ")

    func hankakuToZenkaku() -> String {
        var ret = self
        for i in 0..<String.HankakuSpecial.count {
            ret = ret.replacingOccurrences(of: String.HankakuSpecial[i], with: String.ZenkakuSpecial[i])
        }
        ret = ret.applyingTransform(.fullwidthToHalfwidth, reverse: true) ?? ret
        return ret
    }

    func zenkakuToHankaku() -> String {
        var ret = self
        for i in 0..<String.ZenkakuSpecial.count {
            ret = ret.replacingOccurrences(of: String.ZenkakuSpecial[i], with: String.HankakuSpecial[i])
        }
        ret = ret.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? ret
        return ret
    }
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

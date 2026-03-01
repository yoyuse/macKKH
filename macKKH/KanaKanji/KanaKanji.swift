//
//  KanaKanji.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/11.
//

import Foundation

open class KanaKanji {
    var dic: [String:[String]]
    var lex: [String:[String]]
    var rev: [String:[String]]
    // var maxYomiCount: Int

    public init() {
        dic = [:]
        lex = [:]
        rev = [:]
        // maxYomiCount = 0
    }

    func readDic(_ path: String) {
        do {
            let str = try String(contentsOfFile: path, encoding: .utf8)
            str.enumerateLines { [weak self] (line, stop) in
                let ary = line.components(separatedBy: " /") // XXX
                if 1 < ary.count {
                    let yomi: String = ary[0]
                    let cands: [String] = ary[1].components(separatedBy: "/").dropLast().map { $0 }
                    guard let self = self else { return }
                    self.dic[yomi] = cands
                    //
                    /*
                    var yomiCount = yomi.count
                    if yomi.hasSuffix("—") { yomiCount -= 1 }
                    if self.maxYomiCount < yomiCount { self.maxYomiCount = yomiCount }
                     */
                }
            }
        } catch let error { NSLog("%@", error.localizedDescription) }
    }

    func readRev(_ path: String) {
        do {
            let str = try String(contentsOfFile: path, encoding: .utf8)
            str.enumerateLines { [weak self] (line, stop) in
                let ary = line.components(separatedBy: " /") // XXX
                if 1 < ary.count {
                    let kanji: String = ary[0]
                    let yomis: [String] = ary[1].components(separatedBy: "/").dropLast().map { $0 }
                    guard let _self = self else { return }
                    _self.rev[kanji] = yomis
                }
            }
        } catch let error { NSLog("%@", error.localizedDescription) }
    }

    func lookSub(_ key: String) -> [String] {
        let lexCands = lex[key] ?? []
        let dicCands = dic[key] ?? []
        return lexCands + dicCands
    }

    func look(_ str: String) -> [String] {
        var ret: [String] = []
        let yomiLength = str.count
        if yomiLength < 1 { return ret }
        for gokanLength in 1...yomiLength {
            var re: [String] = []
            let gobiLength = yomiLength - gokanLength
            let gokan = String(str.prefix(gokanLength))
            let gobi = String(str.suffix(gobiLength))
            // 活用しない語
            re += lookSub(gokan).map { $0 + gobi }
            // 活用語尾の短いものを優先
            re += lookSub(gokan + "—").map { $0 + gobi }
            // 語幹の長いものを優先
            ret = re + ret
        }
        return ret.unique()
    }

    // 単漢字 kanji の読みのリストを返す
    func lookTankanji(_ kanji: String) -> [String] {
        return self.rev[kanji] ?? [kanji]
    }

    // 読みのリスト同士の直積を取って連結したリストを返す
    func productJoined(_ set: [[String]]) -> [String] {
        if set.isEmpty { return [""] }
        //
        let car = set[0]
        let cdr = set[1...].map { $0 }
        var ret: [String] = []
        for scar in car {
            for scdr in self.productJoined(cdr) {
                ret.append(scar + scdr)
            }
        }
        //
        return ret
    }

    // 漢字かな交じり語 str の読みのリストを返す
    func lookYomi(_ str: String) -> [String] {
        let ary = str.map { self.lookTankanji((String($0))) }
        return self.productJoined(ary)
    }

    // 漢字かな交じり語 str から正規表現を生成して返す
    func mazeRegexp(_ str: String) throws -> NSRegularExpression {
        let pat = NSRegularExpression.escapedPattern(for: str.replacingOccurrences(of: "—$", with: "", options: .regularExpression)).replacingOccurrences(of: "[ーぁ-ん]+", with: ".+", options: .regularExpression)
        return try NSRegularExpression(pattern: "^\(pat)$", options: [])
    }

    // 漢字かな交じり語 str で索字する
    func lookMazeSub(_ str: String) -> [String] {
        let yomis = self.lookYomi(str)
        // yomis で索字したものを、平坦化 (joined) し、重複を取り除く (reduce)
        let ls = yomis.map { self.lookSub($0) }.joined().map { $0 }.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
        do {
            let re = try self.mazeRegexp(str)
            let ret = ls.filter({
                // 正規表現で絞りこむ。もとの読み str と同じ候補も除外する
                $0 + "—" != str && // XXX: str が活用語の場合
                $0 != str && re.matches(in: $0, options: [], range: NSRange(location: 0, length: $0.count)).count != 0
            })
            return ret
        } catch let error {
            NSLog("%@", error.localizedDescription)
            return []
        }
    }

    func lookMaze(_ str: String) -> [String] {
        var ret: [String] = []
        let yomiLength = str.count
        if yomiLength < 1 { return ret }
        for gokanLength in 1...yomiLength {
            var re: [String] = []
            let gobiLength = yomiLength - gokanLength
            let gokan = String(str.prefix(gokanLength))
            let gobi = String(str.suffix(gobiLength))
            // 活用しない語
            re += lookMazeSub(gokan).map { $0 + gobi }
            // 活用語尾の短いものを優先
            re += lookMazeSub(gokan + "—").map { $0 + gobi }
            // 語幹の長いものを優先
            ret = re + ret
        }
        return ret.unique()
    }
}

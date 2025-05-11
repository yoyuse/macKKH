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
    var maxYomiCount: Int

    public init() {
        dic = [:]
        lex = [:]
        maxYomiCount = 0
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
                    var yomiCount = yomi.count
                    if yomi.hasSuffix("—") { yomiCount -= 1 }
                    if self.maxYomiCount < yomiCount { self.maxYomiCount = yomiCount }
                }
            }
        } catch let error { print(error.localizedDescription) }
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
}

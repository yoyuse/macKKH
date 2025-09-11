//
//  Cache.swift
//  MacKKIM
//
//  Created by YUSE Yosihiro on 25/05/11.
//

import Foundation

final class Cache: NSCache<AnyObject, AnyObject> {
    static let shared = Cache()
    private override init() {}
}

//
//  CodeBase.swift
//  RxAtomic
//
//  Created by Kevin Minority on 1/13/19.
//

import Foundation

public class Codebase {
    static public let httpClient: HttpDataRequestable = URLSessionHttpClient()
    static public let cacheClient: DataCachable = CacheService()
}

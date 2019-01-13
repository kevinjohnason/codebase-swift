//
//  CacheService.swift
//  RxAtomic
//
//  Created by Kevin Minority on 1/13/19.
//

import Foundation
import RxSwift


public protocol DataCachable {
    func loadDataFromDiskCache(fileName: String) -> Observable<Data?>
    func cacheDataInDisk(_ data: Data, with fileName: String) -> Observable<Void>    
}

class CacheService: DataCachable {
    
    static let cacheServiceQueue = DispatchQueue(label: "cache_service_queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    static let cacheServiceScheduler = ConcurrentDispatchQueueScheduler(queue: CacheService.cacheServiceQueue)
    
    // swiftlint:disable force_try
    static let diskCacheUrl: URL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    public func loadDataFromDiskCache(fileName: String) -> Observable<Data?> {
        return Observable<Data?>.create { observer in
            let fileUrl = CacheService.diskCacheUrl.appendingPathComponent(String(fileName.hashValue))
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                observer.onNext(nil)
                return Disposables.create()
            }
            do {
                observer.onNext(try Data(contentsOf: fileUrl))
            } catch {
                print(error.localizedDescription)
                observer.onError(error)
            }
            return Disposables.create()
            }.take(1)
            .subscribeOn(CacheService.cacheServiceScheduler)
    }
    
    public func cacheDataInDisk(_ data: Data, with fileName: String) -> Observable<Void>  {
        return Observable<Void>.create { observer in
            let fileUrl = CacheService.diskCacheUrl.appendingPathComponent(String(fileName.hashValue))
            do {
                try data.write(to: fileUrl, options: [.atomic])
                observer.onNext(())
            } catch {
                print(error.localizedDescription)
                observer.onError(error)
            }
            return Disposables.create()
            }.take(1)
            .subscribeOn(CacheService.cacheServiceScheduler)
    }
}

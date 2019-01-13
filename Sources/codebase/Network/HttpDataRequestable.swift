//
//  Network.swift
//  codebase
//
//  Created by Kevin Minority on 1/6/19.
//  Copyright © 2019 Kevin Cheng. All rights reserved.
//

import Foundation
import RxSwift

public enum NetworkError: Error {
    case unauthorized
    case dataNotExisted(message: String)
    case invalidFormat(type: Any.Type, value: Any)
    case badRequest
    case duplicateRequest
    case serverError
    case invalidUrl
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol HttpDataRequestable: class {
    
    func requestData(url: String, body: Data?, method: HttpMethod, headers: [String: String],
                     queryStrings: [String: String]) -> Observable<(Data)>

    func requestData(url: String, body: Data?, method: HttpMethod, headers: [String: String])
        -> Observable<(Data)>
    

    func requestData(url: String, body: Data?, method: HttpMethod) -> Observable<(Data)>
    

    func requestData(url: String, body: Data?) -> Observable<(Data)>
    

    func requestData(url: String) -> Observable<(Data)>
    
    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data?,
                                        method: HttpMethod, headers: [String: String],
                                        queryStrings: [String: String]) -> Observable<(T)>
    

    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data?,
                                        method: HttpMethod, headers: [String: String]) -> Observable<(T)>
    

    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data?,
                                        method: HttpMethod) -> Observable<(T)>
    

    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data?) -> Observable<(T)>
    

    func requestDecodable<T: Decodable>(type: T.Type, url: String) -> Observable<(T)>
    
}

extension HttpDataRequestable {        
    
    func requestData(url: String, body: Data? = nil, method: HttpMethod = .get, headers: [String: String] = [:]) -> Observable<(Data)> {
        return requestData(url: url, body: body, method: method, headers: headers, queryStrings: [:])
    }
    
    func requestData(url: String, body: Data? = nil, method: HttpMethod = .get) -> Observable<(Data)> {
        return requestData(url: url, body: body, method: method, headers: [:], queryStrings: [:])
    }
    
    func requestData(url: String, body: Data? = nil) -> Observable<(Data)> {
        return requestData(url: url, body: body, method: .get, headers: [:], queryStrings: [:])
    }
    
    func requestData(url: String) -> Observable<(Data)> {
        return requestData(url: url, body: nil, method: .get, headers: [:], queryStrings: [:])
    }
    
    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data? = nil, method: HttpMethod = .get,
                                        headers: [String: String] = [:]) -> Observable<(T)> {
        return requestDecodable(type: type, url: url, body: body, method: method, headers: headers, queryStrings: [:])
    }
    
    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data? = nil, method: HttpMethod = .get) -> Observable<(T)> {
        return requestDecodable(type: type, url: url, body: body, method: method, headers: [:])
    }
    
    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data? = nil) -> Observable<(T)> {
        return requestDecodable(type: type, url: url, body: body, method: .get)
    }
    
    func requestDecodable<T: Decodable>(type: T.Type, url: String) -> Observable<(T)> {
        return requestDecodable(type: type, url: url, body: nil)
    }
    
}

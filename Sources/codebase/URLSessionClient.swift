//
//  URLSessionClient.swift
//  codebase
//
//  Created by Kevin Minority on 1/6/19.
//

import Foundation
import RxSwift

class URLSessionHttpClient: HttpDataRequestable {
    var disposeBag: DisposeBag = DisposeBag()
    let asyncScheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    let requestTimeout: Int = 5
    
    /// Once configured, session object ignores any changes to configuration object. To use new configuration, new URLSession object is needed
    let session: URLSession
    
    init(URLSessionConfiguration: URLSessionConfiguration = .default) {
        session = URLSession(configuration: URLSessionConfiguration)
    }
    

    func requestData(url: String, body: Data? = nil, method: HttpMethod = .get, headers: [String: String] = [:],
                     queryStrings: [String: String] = [:]) -> Observable<(Data)> {
        
        let requestObservable = request(url: url, body: body, method: method, headers: headers, queryStrings: queryStrings)
            .map { $0.1 }
        
        return requestObservable
    }
    
    
    /**
     Making http request and parse into given Decodable object(s)
     
     - parameters:
     - url:  Endpoint URL.
     - body: HTML body to be posted or put. Default: nil
     - method: HTML method. Default: .get
     - headers: HTML headers. Default: [:]
     - queryStrings: Query strings appended to URL for GET request. Default: [:]
     - Returns: Observable of a duplet of returned data and URLResponse.
     */
    func requestDecodable<T: Decodable>(type: T.Type, url: String, body: Data? = nil, method: HttpMethod = .get,
                                        headers: [String: String] = [:],
                                        queryStrings: [String: String] = [:]) -> Observable<(T)> {
        return request(type: type, url: url, body: body, method: method, headers: headers, queryStrings: queryStrings)
            .map { $0.1 }
    }
    
    func request(url: String, body: Data? = nil, method: HttpMethod = .get, headers: [String: String] = [:],
                 queryStrings: [String: String] = [:]) -> Observable<(URLResponse, Data)> {
        
        return Observable<(URLResponse, Data)>.create { observable in
            guard var urlComponents = URLComponents(string: url) else {
                observable.onError(NetworkError.invalidUrl)
                return Disposables.create()
            }
            if method == .get {
                urlComponents.queryItems = queryStrings.map {
                    URLQueryItem(name: $0.key, value: $0.value)
                }
            }
            guard let url = urlComponents.url else {
                observable.onError(NetworkError.invalidUrl)
                return Disposables.create()
            }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.cachePolicy = .reloadIgnoringLocalCacheData
            headers.forEach {
                request.addValue($0.value, forHTTPHeaderField: $0.key)
            }
            if let body = body {
                #if DEBUG
                print("posting body: \(String(data: body, encoding: .utf8) ?? "")")
                #endif
                request.httpBody = body
            }
            let urlSession = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    observable.onError(error)
                    return
                } else if let data = data, let response = response {
                    observable.onNext((response, data))
                    observable.onCompleted()
                }
            })
            urlSession.resume()
            return Disposables.create {
                if urlSession.state == URLSessionTask.State.running {
                    urlSession.cancel()
                }
            }
            }.map(errorCheck)
            .subscribeOn(asyncScheduler)
    }
    
    func request(url: String, body: Data? = nil, method: HttpMethod = .get, headers: [String: String] = [:],
                 queryStrings: [String: String] = [:], callback: @escaping (URLResponse, Data) -> Void ) {
        request(url: url, body: body, method: method, headers: headers, queryStrings: queryStrings)
            .timeout(RxTimeInterval(requestTimeout), scheduler: MainScheduler.instance)
            .subscribe(onNext: callback)
            .disposed(by: disposeBag)
    }
    
    func request<T: Decodable>(type: T.Type, url: String, body: Data? = nil, method: HttpMethod = .get,
                               headers: [String: String] = [:],
                               queryStrings: [String: String] = [:]) -> Observable<(URLResponse, T)> {
        return request(url: url, body: body, method: method, headers: headers, queryStrings: queryStrings)
            .map { ($0.0, try $0.1.parse(into: type)) }
    }
    
    func errorCheck(_ httpResult: (URLResponse, Data)) throws ->  (URLResponse, Data) {
        if let urlResponse = httpResult.0 as? HTTPURLResponse {
            if urlResponse.statusCode >= 400 {
                print("error on: \(httpResult.0.url?.absoluteString ?? "")")
                print("error code: \(urlResponse.statusCode)")
                print(String(data: httpResult.1, encoding: .utf8) ?? "")
            }
            switch urlResponse.statusCode {
            case 401:
                throw NetworkError.unauthorized
            case 400:
                throw NetworkError.badRequest
            case 409:
                throw NetworkError.duplicateRequest
            case 500:
                throw NetworkError.serverError
            default:
                break
            }
        }
        return httpResult
    }
}

extension Data {
    // parse Data into a decodable object
    func parse<T: Decodable>(into decodable: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(decodable, from: self)
        } catch {
            print("Parsing data into \(decodable) failed. From data: \(String(data: self, encoding: .utf8) ?? "nil")")
            throw NetworkError.invalidFormat(type: decodable, value: error)
        }
    }
}

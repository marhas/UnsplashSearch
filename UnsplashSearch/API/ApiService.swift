//
//  ApiService.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import Foundation

public enum ApiError: Error {
    case requestFailed(errorMessage: String)
    case dataTaskFailed(error: Error?)
}

class ApiService {

    static let unsplashTokenKey = "UNSPLASH_TOKEN"

    var loadTask: URLSessionDataTask?
    let urlSession: URLSession
    let operationQueue = OperationQueue()

    init() {
        let urlSessionConfig = URLSessionConfiguration.default
        let unsplashApiToken = ApiService.unsplashApiToken ?? ""
        urlSessionConfig.httpAdditionalHeaders = ["Authorization": "Client-ID \(unsplashApiToken)"]
        urlSession = URLSession(configuration: urlSessionConfig, delegate: nil, delegateQueue: operationQueue)
    }

    func load<T>(resource: Resource<T>, completion: @escaping (T?, ApiError?) -> Void) {
        loadTask?.cancel()
        loadTask = urlSession.dataTask(with: resource.url) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                completion(nil, ApiError.dataTaskFailed(error: error))
                return
            }
            if !(200..<300 ~= response.statusCode) {
                completion(nil, ApiError.requestFailed(errorMessage: "Request failed with status code \(response.statusCode)"))
            } else {
                let parsedResult = resource.parse(data, response)
                completion(parsedResult, nil)
            }
        }
        loadTask?.resume()
    }

    static var unsplashApiToken: String? {
        get {
            return UserDefaults.standard.string(forKey: unsplashTokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: unsplashTokenKey)
        }
    }

}

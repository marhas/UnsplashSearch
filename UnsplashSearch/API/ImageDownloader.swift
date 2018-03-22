//
//  ImageDownloader.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import UIKit

class ImageDownloader {

    var dataTask: URLSessionDataTask?

    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        dataTask?.resume()
    }

    func cancelDownload() {
        dataTask?.cancel()
    }
}

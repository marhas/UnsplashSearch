//
//  ThumbnailCollectionViewCell.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    let imageDownloader = ImageDownloader()

    var imageUrl: URL? {
        didSet {
            guard let imageUrl = imageUrl else {
                imageView.image = nil
                return
            }
            imageDownloader.downloadImage(url: imageUrl) { image in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageDownloader.cancelDownload()
        imageView.image = UIImage(named: "imageplaceholder")
    }
}

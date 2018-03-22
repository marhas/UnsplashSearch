//
//  ImageDetailViewController.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-19.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageUrl: URL?
    var placeholderImage: UIImage?

    func configure(imageUrl: URL, placeholderImage: UIImage) {
        self.imageUrl = imageUrl
        self.placeholderImage = placeholderImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let imageUrl = imageUrl, let placeholderImage = placeholderImage else {
            assert(false, "You need to set an image url and a placeholder image before presenting this view controller")
            return
        }
        imageView.image = placeholderImage

        ImageDownloader().downloadImage(url: imageUrl) { [unowned self] image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let toVC = segue.destination
        if toVC is ImageDetailViewController {
            toVC.transitioningDelegate = self
        }
    }
}

extension ImageDetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ThumbnailExpanderAnimationController()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ThumbnailRestorerAnimationController()
    }
}

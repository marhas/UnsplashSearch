//
//  ThumbnailRestorerAnimationController.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-21.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import UIKit

class ThumbnailRestorerAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard   let imageDetailVC = transitionContext.viewController(forKey: .from) as? ImageDetailViewController,
                let destNavController = transitionContext.viewController(forKey: .to) as? UINavigationController,
                let imageSearchVC = destNavController.childViewControllers.first as? ImageSearchViewController,
                let indexPathForSelectedItem = imageSearchVC.collectionView.indexPathsForSelectedItems?.first,
                let selectedThumbnailCell = imageSearchVC.collectionView.cellForItem(at: indexPathForSelectedItem) as? ThumbnailCollectionViewCell,
                let imageView = imageDetailVC.imageView
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)

        let targetThumbnailFrame = imageSearchVC.collectionView.convert(selectedThumbnailCell.frame, to: imageDetailVC.view)

        let imageViewOriginalFrame = imageDetailVC.imageView.frame
        let imageSearchView = transitionContext.view(forKey: .to)!
        let blackBackground = UIView()
        blackBackground.backgroundColor = .black
        blackBackground.frame = containerView.frame
        containerView.addSubview(imageSearchView)
        containerView.addSubview(blackBackground)
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = true

        imageView.frame = imageViewOriginalFrame
        imageView.contentMode = .scaleAspectFit

        UIView.animate(withDuration: duration, animations: {
            imageView.frame = targetThumbnailFrame
            blackBackground.alpha = 0.0
        }) { finished in
            imageView.removeFromSuperview()
            blackBackground.removeFromSuperview()
            transitionContext.view(forKey: .from)?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

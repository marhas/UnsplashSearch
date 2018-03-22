//
//  ThumbnailExpanderAnimationController.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-20.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import UIKit

class ThumbnailExpanderAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard   let fromVCNavController = transitionContext.viewController(forKey: .from) as? UINavigationController,
                let imageSearchVC = fromVCNavController.childViewControllers.first as? ImageSearchViewController,
                let indexPathForSelectedItem = imageSearchVC.collectionView.indexPathsForSelectedItems?.first,
                let selectedThumbnailCell = imageSearchVC.collectionView.cellForItem(at: indexPathForSelectedItem) as? ThumbnailCollectionViewCell,
                let imageDetailVC = transitionContext.viewController(forKey: .to) as? ImageDetailViewController
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)

        let thumbnailOrigin = imageSearchVC.collectionView.convert(selectedThumbnailCell.frame, to: imageSearchVC.view)

        let copiedImage = UIImage(cgImage: selectedThumbnailCell.imageView.image!.cgImage!, scale: selectedThumbnailCell.imageView.image!.scale, orientation: selectedThumbnailCell.imageView.image!.imageOrientation)
        let decoyImageView = UIImageView(image: copiedImage)
        decoyImageView.contentMode = .scaleAspectFit

        containerView.addSubview(imageDetailVC.view)
        imageDetailVC.view.isHidden = true
        imageSearchVC.view.alpha = 1.0
        containerView.addSubview(decoyImageView)
        let frameInToView = imageDetailVC.view.convert(thumbnailOrigin, to: imageDetailVC.view)
        decoyImageView.frame = frameInToView

        let thumbnailTargetSize = decoyImageView.image!.size.aspectFit(in: imageDetailVC.imageView.frame.size)
        let targetOrigin = CGPoint(x: imageDetailVC.imageView.frame.origin.x, y: imageDetailVC.imageView.frame.height / 2 - thumbnailTargetSize.height / 2)

        let convertedTargetOrigin = imageDetailVC.imageView.convert(targetOrigin, to: imageDetailVC.view)
        let thumbnailTargetFrame = CGRect(origin: convertedTargetOrigin, size: thumbnailTargetSize)

        UIView.animate(withDuration: duration, animations: { [decoyImageView] in
            decoyImageView.frame = thumbnailTargetFrame
            imageSearchVC.view.alpha = 0.0
        }) { completed in
            decoyImageView.removeFromSuperview()
            imageDetailVC.view.isHidden = false
            imageSearchVC.view.alpha = 1.0
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

extension CGSize {
    func aspectFit(in targetSize: CGSize) -> CGSize {
        let widthScalingFactor = targetSize.width / width
        // Test if self fits in targetRect height when scaled to full width
        if height * widthScalingFactor <= targetSize.height {
            return CGSize(width: width * widthScalingFactor, height: height * widthScalingFactor)
        } else {
            let heightScalingFactor = targetSize.height / height
            return CGSize(width: width * heightScalingFactor, height: height * heightScalingFactor)
        }
    }
}


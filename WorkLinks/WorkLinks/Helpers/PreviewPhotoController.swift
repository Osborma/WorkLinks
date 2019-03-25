//
//  PreviewPhotoController.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 23/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//


import UIKit
import Photos

protocol PreviewPhotoContainerViewDelegate: class {
    func handleDismissAfterPreview()
}

class PreviewPhotoContainerView: UIView {
    weak var delegate: PreviewPhotoContainerViewDelegate?

    let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    func handleSave(callback: @escaping (UIImage) -> Void) {
        guard let previewImage = previewImageView.image else { return }

        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }, completionHandler: { _, err in
            if let err = err {
                print("Failed to save image to photo library:", err)
                return
            }
            print("Successfully saved image to photo library")

            let rect = CGRect(x: 0, y: 0, width: previewImage.size.width, height: previewImage.size.width)
            let imageRef = previewImage.cgImage?.cropping(to: rect)

            callback(UIImage(cgImage: imageRef!, scale: 1, orientation: previewImage.imageOrientation))
        })
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
                                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                                width: frame.width, height: frame.width)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

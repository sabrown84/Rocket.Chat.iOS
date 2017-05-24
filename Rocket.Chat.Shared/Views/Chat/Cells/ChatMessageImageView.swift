//
//  ChatMessageImageView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

protocol ChatMessageImageViewProtocol: class {
    func openImageFromCell(attachment: Attachment, thumbnail: UIImageView)
}

final class ChatMessageImageView: UIView, AuthManagerInjected {
    static let defaultHeight = CGFloat(250)

    var injectionContainer: InjectionContainer!
    weak var delegate: ChatMessageImageViewProtocol?
    var attachment: Attachment! {
        didSet {
            updateMessageInformation()
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var activityIndicatorImageView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 3
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 1
        }
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapView))
    }()

    fileprivate func updateMessageInformation() {
        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }

        labelTitle.text = attachment.title

        guard let auth = authManager.isAuthenticated() else { return }
        let imageURL = attachment.fullImageURL(inAuth: auth)
        activityIndicatorImageView.startAnimating()
        imageView.sd_setImage(with: imageURL, completed: { [weak self] _, _, _, _ in
            self?.activityIndicatorImageView.stopAnimating()
        })
    }

    func didTapView() {
        delegate?.openImageFromCell(attachment: attachment, thumbnail: imageView)
    }
}

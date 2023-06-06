//
//  MWImageCollectionViewCell.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import UIKit
import MobileWorkflowCore

class MWImageCollectionViewCell: UICollectionViewCell {
    
    struct ViewData {
        let title: String?
        let subtitle: String?
        let imageUrl: URL?
        let showAction: Bool
        let actionSymbol: String
    }
    
    //MARK: Class properties
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    @MainActor private let imageView = UIImageView()
    private var imageLoadTask: Task<(), Never>?
    private let actionButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 16.0
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.titleLabel?.textAlignment = .center
        return button
    }()
    private var remoteAction: () async -> Void = {}
    private let remoteActionIndicator = {
        let progress = UIActivityIndicatorView(style: .white)
        progress.hidesWhenStopped = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
        self.titleLabel.font = .preferredFont(forTextStyle: .body)
        self.titleLabel.textColor = .label
        
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.setContentCompressionResistancePriority(.required-1, for: .vertical)
        self.subtitleLabel.setContentHuggingPriority(.required-1, for: .vertical)
        self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        self.subtitleLabel.textColor = .secondaryLabel
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 9/16).isActive = true
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = 16.0
        self.imageView.layer.masksToBounds = true
        
        containerView.addPinnedSubview(self.imageView)
        containerView.addSubview(self.actionButton)
        containerView.addSubview(self.remoteActionIndicator)
        NSLayoutConstraint.activate([
            self.actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.0),
            self.actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10.0),
            self.actionButton.heightAnchor.constraint(equalToConstant: 30.0),
            self.actionButton.widthAnchor.constraint(equalToConstant: 30.0),
            self.remoteActionIndicator.centerXAnchor.constraint(equalTo: self.actionButton.centerXAnchor),
            self.remoteActionIndicator.centerYAnchor.constraint(equalTo: self.actionButton.centerYAnchor)
        ])
        
        let infoStack = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
        infoStack.axis = .vertical
        infoStack.distribution = .fill
        infoStack.alignment = .fill
        infoStack.spacing = 0
        
        let mainStack = UIStackView(arrangedSubviews: [containerView, infoStack])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = 12
        
        super.init(frame: frame)
        
        self.actionButton.addTarget(self, action: #selector(self.remoteActionButtonTouchUpInside), for: .touchUpInside)
        self.contentView.addPinnedSubview(mainStack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    //MARK: Configuration
    func configure(viewData: ViewData, isLargeSection: Bool, imageLoader: ImageLoadingService, imageCache: RemoteImageCaching, session: Session, theme: Theme, remoteAction: @escaping () async -> Void) {
        self.remoteAction = remoteAction
        self.titleLabel.text = viewData.title
        self.subtitleLabel.text = viewData.subtitle
        
        self.imageView.layer.cornerRadius = isLargeSection ? 16.0 : 12.0
        self.imageLoadTask?.cancel()
        
        guard let imageUrl = viewData.imageUrl?.absoluteString else { return }
        
        self.imageView.image = nil
        self.imageView.backgroundColor = theme.imagePlaceholderBackgroundColor
        
        self.actionButton.tintColor = theme.primaryNavBarTintColor
        self.actionButton.backgroundColor = theme.primaryNavBarBackgroundColor
        self.actionButton.isHidden = !viewData.showAction
        self.actionButton.layer.cornerRadius = isLargeSection ? 16.0 : 12.0
        
        self.actionButton.titleLabel?.textColor = theme.primaryNavBarTintColor
        if let symbol = UIImage(systemName: viewData.actionSymbol) {
            let imageText = NSAttributedString(attachment: NSTextAttachment(image: symbol))
            self.actionButton.setAttributedTitle(imageText, for: .normal)
        } else {
            self.actionButton.setAttributedTitle(nil, for: .normal)
        }
        
        self.remoteActionIndicator.color = theme.primaryNavBarTintColor
        
        if let image = imageCache.imageForURL(imageUrl) {
            self.imageView.transition(to: image, animated: false)
            return
        }
        self.imageLoadTask = Task { [weak self] in
            let result = await imageLoader.load(image: imageUrl, session: session)
            if let image = result.image {
                imageCache.storeImage(image, forUrl: imageUrl)
                self?.imageView.transition(to: result.image, animated: true)
            }
        }
    }
    
    @objc private func remoteActionButtonTouchUpInside() {
        Task {
            await self.showProgress()
            await self.remoteAction()
        }
    }
    
    @MainActor
    private func showProgress() {
        self.actionButton.setAttributedTitle(nil, for: .normal)
        self.remoteActionIndicator.startAnimating()
    }
    
    private func clear() {
        self.remoteAction = {}
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        
        self.imageLoadTask?.cancel()
        self.imageView.image = nil
    }
}

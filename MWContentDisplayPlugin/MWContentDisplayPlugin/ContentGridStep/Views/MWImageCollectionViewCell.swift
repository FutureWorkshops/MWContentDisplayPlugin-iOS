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
        let showFavorite: Bool
        let isFavorite: Bool
    }
    
    //MARK: Class properties
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    @MainActor private let imageView = UIImageView()
    private var imageLoadTask: Task<(), Never>?
    private let favoriteButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 16.0
        button.layer.masksToBounds = true
        return button
    }()
    private var favoriteAction: () async -> Bool = { false }
    
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
        containerView.addSubview(self.favoriteButton)
        NSLayoutConstraint.activate([
            self.favoriteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.0),
            self.favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10.0),
            self.favoriteButton.heightAnchor.constraint(equalToConstant: 30.0),
            self.favoriteButton.widthAnchor.constraint(equalToConstant: 30.0),
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
        
        self.favoriteButton.addTarget(self, action: #selector(self.favoriteButtonAction), for: .touchUpInside)
        self.contentView.addPinnedSubview(mainStack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    
    private func updateState(for button: UIButton, asFavorite favorite: Bool) {
        let fillImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        let normalImage = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
        
        if favorite {
            button.setImage(fillImage, for: .normal)
            button.setImage(normalImage, for: .selected)
            button.setImage(normalImage, for: .highlighted)
        } else {
            button.setImage(normalImage, for: .normal)
            button.setImage(fillImage, for: .selected)
            button.setImage(fillImage, for: .highlighted)
        }
    }
    
    //MARK: Configuration
    func configure(viewData: ViewData, isLargeSection: Bool, imageLoader: ImageLoadingService, imageCache: RemoteImageCaching, session: Session, theme: Theme, favoriteAction: @escaping () async -> Bool) {
        self.favoriteAction = favoriteAction
        self.titleLabel.text = viewData.title
        self.subtitleLabel.text = viewData.subtitle
        
        self.imageView.layer.cornerRadius = isLargeSection ? 16.0 : 12.0
        self.imageLoadTask?.cancel()
        
        guard let imageUrl = viewData.imageUrl?.absoluteString else { return }
        
        self.imageView.image = nil
        self.imageView.backgroundColor = theme.imagePlaceholderBackgroundColor
        
        self.favoriteButton.tintColor = theme.primaryNavBarTintColor
        self.favoriteButton.backgroundColor = theme.primaryNavBarBackgroundColor
        self.favoriteButton.isHidden = !viewData.showFavorite
        self.favoriteButton.layer.cornerRadius = isLargeSection ? 16.0 : 12.0
        self.updateState(for: self.favoriteButton, asFavorite: viewData.isFavorite)
        
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
    
    @objc private func favoriteButtonAction() {
        Task { await self.favoriteAction() }
    }
    
    private func clear() {
        self.favoriteAction = { false }
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        
        self.imageLoadTask?.cancel()
        self.imageView.image = nil
    }
}

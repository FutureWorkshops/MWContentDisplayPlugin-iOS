//
//  MWImageCollectionViewCell.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import Combine
import UIKit
import MobileWorkflowCore

class MWImageCollectionViewCell: UICollectionViewCell {
    
    struct ViewData {
        let title: String?
        let subtitle: String?
        let imageUrl: URL?
    }
    
    //MARK: Class properties
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    private var imageLoadTask: AnyCancellable?
    
    private lazy var placeholderImage: UIImage? = {
        let size = CGSize(width: 500, height: 500/2)
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(.normal)
        
        let imageConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        guard let image = UIImage(systemName: "photo", withConfiguration: imageConfig) else {
            return nil
        }
        
        // Center image
        let x = (size.width / 2) - (image.size.width / 2)
        let y = (size.height / 2) - (image.size.height / 2)
        
        let rect = CGRect(x: x, y: y, width: image.size.width, height: image.size.height)
        context.clip(to: rect, mask: image.cgImage!)
        UIColor.systemGray2.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = 16.0
        self.imageView.layer.masksToBounds = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 9/16).isActive = true
        
        let infoStack = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
        infoStack.axis = .vertical
        infoStack.distribution = .fill
        infoStack.alignment = .fill
        infoStack.spacing = 0
        
        let mainStack = UIStackView(arrangedSubviews: [self.imageView, infoStack])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = 12
        
        super.init(frame: frame)
        
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
    func configure(viewData: ViewData, isLargeSection: Bool, imageLoader: ImageLoadingService, session: Session, theme: Theme) {
        self.titleLabel.text = viewData.title
        self.subtitleLabel.text = viewData.subtitle
        
        self.imageView.layer.cornerRadius = isLargeSection ? 16.0 : 12.0
        self.imageLoadTask?.cancel()
        if let imageUrl = viewData.imageUrl {
            self.imageView.image = self.placeholderImage
            self.imageView.backgroundColor = theme.imagePlaceholderBackgroundColor
            self.imageLoadTask = imageLoader.fromCacheElseAsyncLoad(image: imageUrl.absoluteString, session: session) { [weak self] image, fromCache in
                guard let strongSelf = self else { return }
                strongSelf.imageView.transition(to: image ?? strongSelf.placeholderImage, animated: !fromCache)
            }
        }
    }
    
    private func clear() {
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        
        self.imageLoadTask?.cancel()
        self.imageView.image = nil
    }
}

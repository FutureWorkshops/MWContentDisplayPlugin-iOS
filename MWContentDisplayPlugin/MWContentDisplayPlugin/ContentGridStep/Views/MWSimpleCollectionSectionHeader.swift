//
//  MWSimpleCollectionSectionHeader.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import UIKit
import MobileWorkflowCore

class MWSimpleCollectionSectionHeader: UICollectionReusableView, ReusableView {
    
    //MARK: Properties
    private let titleLabel = UILabel()
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        self.titleLabel.font = .preferredFont(forTextStyle: .title2, weight: .bold)
        super.init(frame: frame)
        self.addPinnedSubview(self.titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }
    
    //MARK: Configuration
    func configure(withTitle title: String?) {
        self.titleLabel.text = title
    }
    
}

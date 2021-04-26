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
        self.titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        super.init(frame: frame)
        self.addPinnedSubview(self.titleLabel, order: .top, insets: .init(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }
    
    //MARK: Configuration
    func configure(withTitle title: String) {
        self.titleLabel.text = title
    }
    
}

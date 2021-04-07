//
//  MWSimpleCollectionSectionHeader.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import UIKit
import MobileWorkflowCore

class MWSimpleCollectionSectionHeader: UICollectionReusableView, ReusableView {
    
    struct ViewData {
        let title: String
    }
    
    private let titleLabel: UILabel!
    
    override init(frame: CGRect) {
        
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .title2, weight: .bold)
        self.titleLabel = titleLabel
        
        super.init(frame: frame)
        
        self.addPinnedSubview(titleLabel, order: .top, insets: .init(top: 8, leading: 15, bottom: 8, trailing: 15))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.clear()
    }
    
    //MARK: - Configuration
    
    func configure(viewData: ViewData) {
        self.titleLabel.text = viewData.title
    }
    
    func clear() {
        self.titleLabel.text = nil
    }
    
}

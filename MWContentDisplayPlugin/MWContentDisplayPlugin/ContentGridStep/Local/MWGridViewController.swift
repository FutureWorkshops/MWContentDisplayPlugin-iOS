//
//  MWGridViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

class MWGridViewController: MWStepViewController, HasSecondaryWorkflows {
    
    struct Item {
        let id: String
        let title: String
        let subtitle: String?
        let imageUrl: URL?
    }
    
    struct Section {
        let id: String
        let type: MWGridItemType
        let title: String
        let items: [Item]
    }
    
    private (set) var collectionView: UICollectionView!
    private (set) var collectionViewLayout: UICollectionViewLayout!
    private (set) var sections: [Section] = []
    
    var gridStep: MWGridStep { self.mwStep as! MWGridStep }
    var secondaryWorkflowIDs: [String] { self.gridStep.secondaryWorkflowIDs }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setupCollectionView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.update(items: self.gridStep.items)
    }
    
    func update(items: [MWGridStepItem]) {
        self.sections = self.gridStep.viewControllerSections()
        self.collectionView.reloadData()
    }
    
    // MARK: Configuration
    
    private func setupCollectionView() {
        // Generate the layout
        self.collectionViewLayout = self.generateLayout()
        
        // Configure the collectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MWImageCollectionViewCell.self)
        collectionView.register(MWSimpleCollectionSectionHeader.self, forSupplementaryViewOfKind: MWSimpleCollectionSectionHeader.defaultReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.collectionView = collectionView
    }
    
    //MARK: - Layout generation
    
    func generateLayout() -> UICollectionViewLayout {
 
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in
            
            let contentWidth = layoutEnvironment.container.effectiveContentSize.width

            let sectionType = self.sections[sectionIndex].type
            switch sectionType {
            case .carouselLarge: return self.generateBigImageLayout(contentWidth: contentWidth)
            case .carouselSmall: return self.generateSmallImageLayout(contentWidth: contentWidth)
            case .item: preconditionFailure("Not a section")
            }
        }
        
        return layout
    }
    
    private func generateBigImageLayout(contentWidth: CGFloat) -> NSCollectionLayoutSection {
        return self.generateImageLayout(itemWidth: contentWidth * 0.9, orthogonalScrollingBehavior: .groupPagingCentered)
    }
    
    private func generateSmallImageLayout(contentWidth: CGFloat) -> NSCollectionLayoutSection {
        return self.generateImageLayout(itemWidth: contentWidth * 0.55)
    }
    
    private func generateImageLayout(itemWidth: CGFloat, orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous) -> NSCollectionLayoutSection {
        
        // Items
        let itemEstimatedHeight = itemWidth * (9/16) + 50
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .estimated(itemEstimatedHeight) )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Groups
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitem: item, count: 1)
        
        // Header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: MWSimpleCollectionSectionHeader.defaultReuseIdentifier, alignment: .top)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                              leading: orthogonalScrollingBehavior == .groupPagingCentered ? 8 : 0,
                                                              bottom: 0,
                                                              trailing: orthogonalScrollingBehavior == .groupPagingCentered ? 8 : 0)
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        section.contentInsets = NSDirectionalEdgeInsets(top: 12,
                                                        leading: orthogonalScrollingBehavior == .groupPagingCentered ? 0 : 16,
                                                        bottom: 24,
                                                        trailing: orthogonalScrollingBehavior == .groupPagingCentered ? 0 : 16)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        
        return section
    }
}

extension MWGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var result: UICollectionViewCell
        
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        switch section.type {
        case .carouselLarge:
            let cell: MWImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(viewData: MWImageCollectionViewCell.ViewData(item: item), isLargeSection: true, imageLoader: self.gridStep.services.imageLoadingService, session: self.gridStep.session)
            result = cell
            
        case .carouselSmall:
            let cell: MWImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(viewData: MWImageCollectionViewCell.ViewData(item: item), isLargeSection: false, imageLoader: self.gridStep.services.imageLoadingService, session: self.gridStep.session)
            result = cell
            
        case .item: preconditionFailure("Not a section")
        }
        
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case MWSimpleCollectionSectionHeader.defaultReuseIdentifier:
            let sectionTitle = self.sections[indexPath.section].title
            let header: MWSimpleCollectionSectionHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, forIndexPath: indexPath)
            header.configure(withTitle: sectionTitle)
            return header
            
        default: return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard self.hasNextStep() else {
            return
        }
        
        let item = self.sections[indexPath.section].items[indexPath.item]
        if let selected = self.gridStep.items.first(where: { item.id == $0.id }) {
            let result = MWGridStepResult(identifier: self.gridStep.identifier, selected: selected)
            self.addStepResult(result)
            self.goForward()
        }
    }
}

private extension MWImageCollectionViewCell.ViewData {
    
    init(item: MWGridViewController.Item) {
        self.init(title: item.title, subtitle: item.subtitle, imageUrl: item.imageUrl)
    }
}

//
//  MWVideoGridViewController.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

class MWVideoGridViewController: ORKStepViewController, HasSecondaryWorkflows {
    
    struct Item {
        let id: String
        let title: String
        let subtitle: String?
        let imageUrl: URL?
    }
    
    struct Section {
        let id: String
        let type: VideoGridItemType
        let title: String
        let items: [Item]
    }
    
    private (set) var collectionView: UICollectionView!
    private (set) var collectionViewLayout: UICollectionViewLayout!
    private (set) var sections: [Section] = []
    
    var videoGridStep: VideoGridStep! {
        return (self.step as? VideoGridStep)
    }
    
    var secondaryWorkflowIDs: [Int] {
        return self.videoGridStep.secondaryWorkflowIDs
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
        self.setupConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.update(items: self.videoGridStep.items)
    }
    
    func update(items: [VideoGridStepItem]) {
        self.sections = self.videoGridStep.viewControllerSections()
        self.collectionView.reloadData()
    }
    
    // MARK: Configuration
    
    private func setupCollectionView() {
        self.setupCollectionLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MWImageCollectionViewCell.self)
        collectionView.register(MWSimpleCollectionSectionHeader.self, forSupplementaryViewOfKind: MWSimpleCollectionSectionHeader.defaultReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        self.view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    private func setupCollectionLayout() {
        self.collectionViewLayout = self.generateLayout()
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
        return self.generateImageLayout(
            itemWidth: contentWidth - 45, // space for margins and interGroupSpacing
            sectionMargin: 0,
            orthogonalScrollingBehavior: .groupPagingCentered
        )
    }
    
    private func generateSmallImageLayout(contentWidth: CGFloat) -> NSCollectionLayoutSection {
        return self.generateImageLayout(
            itemWidth: 160,
            sectionMargin: 15,
            orthogonalScrollingBehavior: .continuous
        )
    }
    
    private func generateImageLayout(
        itemWidth: CGFloat,
        sectionMargin: CGFloat,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    ) -> NSCollectionLayoutSection {
        
        let itemEstimatedHeight = itemWidth * (9/16) + 50
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .estimated(itemEstimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemSize,
            subitem: item,
            count: 1
        )
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: MWSimpleCollectionSectionHeader.defaultReuseIdentifier,
            alignment: .top
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: sectionMargin,
            bottom: 5,
            trailing: sectionMargin
        )
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        
        return section
    }
    
    private func setupConstraints() {
        guard let collectionView = self.collectionView else { return }
        
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension MWVideoGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
            cell.configure(viewData: MWImageCollectionViewCell.ViewData(item: item), imageLoader: self.videoGridStep.services.imageLoadingService, session: self.videoGridStep.session)
            result = cell
            
        case .carouselSmall:
            let cell: MWImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(viewData: MWImageCollectionViewCell.ViewData(item: item), imageLoader: self.videoGridStep.services.imageLoadingService, session: self.videoGridStep.session)
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
            header.configure(viewData: MWSimpleCollectionSectionHeader.ViewData(title: sectionTitle))
            return header
            
        default: return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let identifier = self.step?.identifier else {
            fatalError("Unable to get the identifier from the step. Something went really wrong")
        }
        let item = self.sections[indexPath.section].items[indexPath.item]
        if let selected = self.videoGridStep.items.first(where: { item.id == $0.id }) {
            let result = VideoGridStepResult(identifier: identifier, selected: selected)
            self.addResult(result)
            self.goForward()
        }
    }
}

private extension MWImageCollectionViewCell.ViewData {
    
    init(item: MWVideoGridViewController.Item) {
        self.init(title: item.title, subtitle: item.subtitle, imageUrl: item.imageUrl)
    }
}

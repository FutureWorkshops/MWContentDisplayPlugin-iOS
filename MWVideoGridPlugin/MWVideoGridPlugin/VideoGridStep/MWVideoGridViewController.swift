//
//  MWVideoGridViewController.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import UIKit
import MobileWorkflowCore
import ResearchKit

class MWVideoGridViewController: ORKStepViewController {
    
    typealias SectionKind = VideoGridStepSection.Kind
    
    struct Item {
        let title: String?
        let subtitle: String?
        let imageUrl: URL?
    }
    
    struct Section {
        let kind: SectionKind
        let title: String
        let items: [Item]
    }
    
    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewLayout!
    private var sections: [Section] = []
    private var stepSections: [Section] {
        return self.castedStep.sections.map({
            let items = $0.items.map({ Item(title: $0.title, subtitle: $0.subtitle, imageUrl: $0.imageURL) })
            return Section(kind: $0.kind, title: $0.title, items: items)
        })
    }
    private var castedStep: MWVideoGridStep! {
        return (self.step as! MWVideoGridStep)
    }
    
    private var imageLoader: ImageLoader {
        return self.castedStep.imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
        self.setupConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.update(sections: self.stepSections)
    }
    
    // MARK: Configuration

    private func setupCollectionView() {
        self.setupCollectionLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MWBigImageCollectionViewCell.self)
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
        let sections = self.stepSections
      let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
        layoutEnvironment: NSCollectionLayoutEnvironment)
          -> NSCollectionLayoutSection? in
        
        let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500
        
        let sectionKind = sections[sectionIndex].kind
        switch sectionKind {
        case .carouselLarge: return self.generateBigImageLayout(isWide: isWideView)
        case .carouselSmall: return self.generateSmallImageLayout(isWide: isWideView)
        }
      }
        
      return layout
    }
    
    private func generateBigImageLayout(isWide: Bool) -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalWidth(2/3))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      // Show one item plus peek on narrow screens,
      // two items plus peek on wider screens
        let groupFractionalWidth = isWide ? 0.475 : 0.95
      let groupFractionalHeight: Float = isWide ? 1/3 : 2/3
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(CGFloat(groupFractionalWidth)),
        heightDimension: .fractionalWidth(CGFloat(groupFractionalHeight)))
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitem: item,
        count: 1)
      group.contentInsets = NSDirectionalEdgeInsets(
        top: 5,
        leading: 5,
        bottom: 5,
        trailing: 5)

      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(44))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: MWSimpleCollectionSectionHeader.defaultReuseIdentifier,
        alignment: .top)

      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [sectionHeader]
      section.orthogonalScrollingBehavior = .groupPaging

      return section
    }
    
    private func generateSmallImageLayout(isWide: Bool) -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalWidth(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Show 2 item plus peek on narrow screens,
        // 3 items plus peek on wider screens
        let groupFractionalWidth = isWide ? 0.32 : 0.48
        let groupFractionalHeight: Float = 1/2.5
        let groupSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(CGFloat(groupFractionalWidth)),
          heightDimension: .fractionalWidth(CGFloat(groupFractionalHeight)))
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: groupSize,
        subitem: item,
        count: 1)
      group.contentInsets = NSDirectionalEdgeInsets(
        top: 5,
        leading: 5,
        bottom: 5,
        trailing: 5)

      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(44))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: MWSimpleCollectionSectionHeader.defaultReuseIdentifier,
        alignment: .top)

      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [sectionHeader]
      section.orthogonalScrollingBehavior = .groupPaging

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
    
    private func update(sections: [Section]) {
        self.sections = sections
        self.reloadData()
    }
    
    //MARK: - Utils
    
    private func reloadData() {
        self.collectionView.reloadData()
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
        
        switch section.kind {
        case .carouselLarge:
            let cell: MWBigImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(viewData: MWBigImageCollectionViewCell.ViewData(item: item), imageLoader: self.imageLoader)
            result = cell
            
        case .carouselSmall:
            let cell: MWImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(viewData: MWImageCollectionViewCell.ViewData(item: item), imageLoader: self.imageLoader)
            result = cell
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
        let selected = self.castedStep.sections[indexPath.section].items[indexPath.item]
        let result = VideoGridStepResult(identifier: identifier, selected: selected)
        self.addResult(result)
        self.goForward()
    }
}

private extension MWBigImageCollectionViewCell.ViewData {
    
    init(item: MWVideoGridViewController.Item) {
        self.init(title: item.title, subtitle: item.subtitle, imageUrl: item.imageUrl)
    }
}

private extension MWImageCollectionViewCell.ViewData {
    
    init(item: MWVideoGridViewController.Item) {
        self.init(title: item.title, subtitle: item.subtitle, imageUrl: item.imageUrl)
    }
}

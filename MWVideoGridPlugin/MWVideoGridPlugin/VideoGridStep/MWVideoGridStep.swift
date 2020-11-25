//
//  MWVideoGridStep.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

public class MWVideoGridStep: ORKStep, VideoGridStep {
    
    let networkManager: NetworkManager
    let imageLoader: ImageLoader
    let secondaryWorkflowIDs: [Int]
    let items: [VideoGridStepItem]
    
    init(identifier: String, networkManager: NetworkManager, imageLoader: ImageLoader, secondaryWorkflowIDs: [Int], items: [VideoGridStepItem]) {
        self.networkManager = networkManager
        self.imageLoader = imageLoader
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.items = items
        
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWVideoGridViewController.self
    }
}

extension MWVideoGridStep: MobileWorkflowStep {
    
    public static func build(data: StepData, context: StepContext, networkManager: NetworkManager, imageLoader: ImageLoader, localizationManager: Localization) throws -> ORKStep {
        let secondaryWorkflowIDs: [Int] = (data.content["workflows"] as? [[String: Any]])?.compactMap({ $0["id"] as? Int }) ?? []
        let contentItems = data.content["items"] as? [[String: Any]] ?? []
        let items: [VideoGridStepItem] = contentItems.compactMap {
            let text = localizationManager.translate($0["text"] as? String)
            let detailText = localizationManager.translate($0["detailText"] as? String)

            guard
                let id = $0["id"] as? Int,
                let strongText = text
                else { return nil }
            return VideoGridStepItem(
                id: id,
                type: $0["type"] as? String,
                text: strongText,
                detailText: detailText,
                imageURL: $0["imageURL"] as? String
            )
        }
        let listStep = MWVideoGridStep(
            identifier: data.identifier,
            networkManager: networkManager,
            imageLoader: imageLoader,
            secondaryWorkflowIDs: secondaryWorkflowIDs,
            items: items
        )
        return listStep
    }
}

extension Array where Element: VideoGridStepItem {
    func asViewControllerSections() -> [MWVideoGridViewController.Section] {
        
        var vcSections = [MWVideoGridViewController.Section]()
        
        var currentSection: VideoGridStepItem?
        var currentItems = [VideoGridStepItem]()
        
        self.forEach { item in
            switch item.itemType {
            case .carouselLarge, .carouselSmall:
                if let currentSection = currentSection {
                    // complete current section before starting new one
                    vcSections.append(self.viewControllerSectionFromSection(currentSection, items: currentItems))
                    currentItems.removeAll()
                }
                currentSection = item
            case .item:
                currentItems.append(item)
            }
        }
        
        if let currentSection = currentSection {
            // complete final section
            vcSections.append(self.viewControllerSectionFromSection(currentSection, items: currentItems))
        }
        
        return vcSections
    }
    
    private func viewControllerSectionFromSection(_ section: VideoGridStepItem, items: [VideoGridStepItem]) -> MWVideoGridViewController.Section {
        
        let vcItems = items.map {
            MWVideoGridViewController.Item(
                id: $0.id,
                title: $0.text,
                subtitle: $0.detailText,
                imageUrl: $0.imageURL.flatMap { URL(string: $0) }
            )
        }
        
        let vcSection = MWVideoGridViewController.Section(
            id: section.id,
            type: section.itemType,
            title: section.text,
            items: vcItems
        )
        
        return vcSection
    }
}

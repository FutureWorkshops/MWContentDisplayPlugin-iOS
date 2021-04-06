//
//  MWVideoGridPlugin.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 24/11/2020.
//

import Foundation
import MobileWorkflowCore

public struct MWVideoGridPlugin: MobileWorkflowPlugin {
    
    public static var allStepsTypes: [MobileWorkflowStepType] {
        return MWVideoGridStepType.allCases
    }
}

enum MWVideoGridStepType: String, MobileWorkflowStepType, CaseIterable {
    case videoGrid = "videoGrid"
    case networkVideoGrid = "networkVideoGrid"
    case contentStack = "contentStack"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: MobileWorkflowStep.Type {
        switch self {
        case .videoGrid: return MWVideoGridStep.self
        case .networkVideoGrid: return MWNetworkVideoGridStep.self
        case .contentStack: return MWContentStackStep.self
        }
    }
}

protocol VideoGridStep: HasSecondaryWorkflows {
    var session: Session { get }
    var services: MobileWorkflowServices { get }
    var items: [VideoGridStepItem] { get }
    func viewControllerSections() -> [MWVideoGridViewController.Section]
}

extension VideoGridStep {
    func viewControllerSections() -> [MWVideoGridViewController.Section] {
        
        var vcSections = [MWVideoGridViewController.Section]()
        
        var currentSection: VideoGridStepItem?
        var currentItems = [VideoGridStepItem]()
        
        self.items.forEach { item in
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
        } else if !currentItems.isEmpty {
            // no sections found, add all to single section
            let section = VideoGridStepItem(id: "DEFAULT_SECTION", type: VideoGridItemType.carouselSmall.rawValue, text: L10n.VideoGrid.defaultSectionTitle, detailText: "", imageURL: "")
            vcSections.append(self.viewControllerSectionFromSection(section, items: currentItems))
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

enum L10n {
    enum VideoGrid {
        static let defaultSectionTitle = "Items"
    }
}

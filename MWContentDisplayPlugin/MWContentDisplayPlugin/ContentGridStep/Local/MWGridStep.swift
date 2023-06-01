//
//  MWGridStep.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

protocol GridStep {
    var items: [GridStepItem] { get set }
    var session: Session { get }
    var services: StepServices { get }
}

public class MWGridStep: MWStep, GridStep {
    
    public let session: Session
    public let services: StepServices
    public var items: [GridStepItem] = []
    
    init(identifier: String, session: Session, services: StepServices, theme: Theme, items: [GridStepItem]) {
        self.session = session
        self.services = services
        self.items = items
        super.init(identifier: identifier, theme: theme)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        return MWGridStepViewController(step: self)
    }
}

extension MWGridStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] {
        [["items": ["listItemId"]]]
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let contentItems = stepInfo.data.content["items"] as? [[String: Any]] ?? []
        let items: [GridStepItem] = try contentItems.compactMap {
            let text = services.localizationService.translate($0["text"] as? String)
            let detailText = services.localizationService.translate($0["detailText"] as? String)
            guard let id = $0.getString(key: "listItemId") ?? $0.getString(key: "id") else {
                throw ParseError.invalidStepData(cause: "Grid item has invalid id")
            }
            let actionMethod: HTTPMethod?
            if let stored = $0["actionMethod"] as? String {
                actionMethod = HTTPMethod(rawValue: stored)
            } else {
                actionMethod = nil
            }
            return GridStepItem(
                id: id,
                type: $0["type"] as? String,
                text: text,
                detailText: detailText,
                imageURL: $0["imageURL"] as? String,
                actionURL: $0["actionURL"] as? String,
                actionSFSymbolName: $0["actionSFSymbolName"] as? String,
                actionMethod: actionMethod
            )
        }
        return MWGridStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services, theme: stepInfo.context.theme, items: items)
    }
}

extension GridStep {
    func viewControllerSections() -> [MWGridStepViewController.Section] {
        
        var vcSections = [MWGridStepViewController.Section]()
        
        var currentSection: GridStepItem?
        var currentItems = [GridStepItem]()
        
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
            let section = GridStepItem(id: "DEFAULT_SECTION", type: GridItemType.carouselSmall.rawValue, text: nil, detailText: nil, imageURL: nil, actionURL: nil, actionSFSymbolName: nil, actionMethod: nil)
            vcSections.append(self.viewControllerSectionFromSection(section, items: currentItems))
        }
        
        return vcSections
    }
    
    private func viewControllerSectionFromSection(_ section: GridStepItem, items: [GridStepItem]) -> MWGridStepViewController.Section {
        
        let vcItems = items.map { MWGridStepViewController.Item(id: $0.id, title: $0.text, subtitle: $0.detailText, imageUrl: $0.imageURL.flatMap { URL(string: $0) }, actionURL: $0.actionURL, actionMethod: $0.actionMethod, actionSymbol: $0.actionSFSymbolName) }
        
        let vcSection = MWGridStepViewController.Section(id: section.id, type: section.itemType, title: section.text, items: vcItems)
        
        return vcSection
    }
    
}

public struct GridGridItem: Codable {
    let listItemId: Float
    let detailText: String?
    let imageURL: String?
    let text: String?
    let type: String?
    let favorite: Bool?
    let favoriteURL: String?
    
    public static func gridGridItem(
        listItemId: Float,
        detailText: String? = nil,
        favorite: Bool? = nil,
        favoriteURL: String? = nil,
        imageURL: String? = nil,
        text: String? = nil,
        type: String? = nil
    ) -> GridGridItem {
        GridGridItem(listItemId: listItemId, detailText: detailText, imageURL: imageURL, text: text, type: type, favorite: favorite, favoriteURL: favoriteURL)
    }
}

public class GridGridMetadata: StepMetadata {
    enum CodingKeys: String, CodingKey {
        case items
        case navigationItems = "_navigationItems"
    }
    
    let items: [GridGridItem]
    let navigationItems: [NavigationItemMetadata]?
    
    init(id: String, title: String, items: [GridGridItem], navigationItems: [NavigationItemMetadata]?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.items = items
        self.navigationItems = navigationItems
        super.init(id: id, type: "videoGrid", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([GridGridItem].self, forKey: .items)
        self.navigationItems = try container.decodeIfPresent([NavigationItemMetadata].self, forKey: .navigationItems)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.items, forKey: .items)
        try container.encodeIfPresent(self.navigationItems, forKey: .navigationItems)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func gridGrid(
        id: String,
        title: String,
        items: [GridGridItem],
        navigationItems: [NavigationItemMetadata]? = nil,
        next: PushLinkMetadata? = nil,
        links: [LinkMetadata] = []
    ) -> GridGridMetadata {
        GridGridMetadata(id: id, title: title, items: items, navigationItems: navigationItems, next: next, links: links)
    }
}

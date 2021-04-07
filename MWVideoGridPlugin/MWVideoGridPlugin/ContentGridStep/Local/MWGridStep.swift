//
//  MWGridStep.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

public class MWGridStep: ORKStep, HasSecondaryWorkflows, MobileWorkflowStep {
    
    public let session: Session
    public let services: MobileWorkflowServices
    public let secondaryWorkflowIDs: [String]
    public var items: [MWGridStepItem] = []
    
    init(identifier: String, session: Session, services: MobileWorkflowServices, secondaryWorkflowIDs: [String], items: [MWGridStepItem]) {
        self.session = session
        self.services = services
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.items = items
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWGridViewController.self
    }
    
    public static func build(stepInfo: StepInfo, services: MobileWorkflowServices) throws -> Step {
        
        let secondaryWorkflowIDs: [String] = (stepInfo.data.content["workflows"] as? [[String: Any]])?.compactMap({ $0.getString(key: "id") }) ?? []
        
        if stepInfo.data.type == MWContentDisplayStepType.grid.typeName {
            // Local grid (coming from the app.json)
            let contentItems = stepInfo.data.content["items"] as? [[String: Any]] ?? []
            let items: [MWGridStepItem] = try contentItems.compactMap {
                guard let text = services.localizationService.translate($0["text"] as? String) else { return nil }
                let detailText = services.localizationService.translate($0["detailText"] as? String)
                let id: String
                if let asInt = $0["id"] as? Int {
                    // legacy
                    id = String(asInt)
                } else if let asString = $0["id"] as? String {
                    id = asString
                } else {
                    throw ParseError.invalidStepData(cause: "Grid item has invalid id")
                }
                return MWGridStepItem(id: id, type: $0["type"] as? String, text: text, detailText: detailText, imageURL: $0["imageURL"] as? String)
            }
            return MWGridStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services, secondaryWorkflowIDs: secondaryWorkflowIDs, items: items)
        } else if stepInfo.data.type == MWContentDisplayStepType.networkGrid.typeName {
            // Remote grid (coming from a network call)
            let emptyText = services.localizationService.translate(stepInfo.data.content["emptyText"] as? String)
            let remoteURLString = stepInfo.data.content["url"] as? String
            return MWNetworkGridStep(identifier: stepInfo.data.identifier, stepInfo: stepInfo, services: services, secondaryWorkflowIDs: secondaryWorkflowIDs, url: remoteURLString, emptyText: emptyText)
        } else {
            throw ParseError.invalidStepData(cause: "Tried to create a grid that's not local nor remote.")
        }
    }
}

extension MWGridStep {
    func viewControllerSections() -> [MWGridViewController.Section] {
        
        var vcSections = [MWGridViewController.Section]()
        
        var currentSection: MWGridStepItem?
        var currentItems = [MWGridStepItem]()
        
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
            let section = MWGridStepItem(id: "DEFAULT_SECTION", type: MWGridItemType.carouselSmall.rawValue, text: L10n.VideoGrid.defaultSectionTitle, detailText: "", imageURL: "")
            vcSections.append(self.viewControllerSectionFromSection(section, items: currentItems))
        }
        
        return vcSections
    }
    
    private func viewControllerSectionFromSection(_ section: MWGridStepItem, items: [MWGridStepItem]) -> MWGridViewController.Section {
        
        let vcItems = items.map { MWGridViewController.Item(id: $0.id, title: $0.text, subtitle: $0.detailText, imageUrl: $0.imageURL.flatMap { URL(string: $0) }) }
        
        let vcSection = MWGridViewController.Section(id: section.id, type: section.itemType, title: section.text, items: vcItems)
        
        return vcSection
    }
    
}

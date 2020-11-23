//
//  MWVideoGridStep.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 27/10/2020.
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
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: MobileWorkflowStep.Type {
        return MWVideoGridStep.self
    }
}

public class MWVideoGridStep: ORKStep {
    
    private enum ListItemType: String {
        case largeSection = "largeSection"
        case smallSection = "smallSection"
        case item = "item"
    }
    
    let networkManager: NetworkManager
    let imageLoader: ImageLoader
    let secondaryWorkflowIDs: [Int]
    let sections: [VideoGridStepSection]
    
    init(identifier: String, networkManager: NetworkManager, imageLoader: ImageLoader, secondaryWorkflowIDs: [Int], sections: [VideoGridStepSection]) {
        self.networkManager = networkManager
        self.imageLoader = imageLoader
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.sections = sections
        
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
        let listItems = data.content["items"] as? [[String: Any]] ?? []
        var sections = [VideoGridStepSection]()
        
        listItems.forEach { (listItem) in
            
            guard let listItemTypeRaw = listItem["type"] as? String,
                  let listItemType = ListItemType(rawValue: listItemTypeRaw) else {
                return
            }
            
            let parseSection = { (jsonSection: [String : Any]) -> VideoGridStepSection? in
                guard let kindRaw = jsonSection["type"] as? String,
                      let kind = VideoGridStepSection.Kind(rawValue: kindRaw),
                      let id = jsonSection["listItemId"] as? Int,
                      let title = jsonSection["text"] as? String else {
                    return nil
                }
                
                //since the JSON format does not provide items embedded inside the section, we initialize with empty items, and the rest of the parser should append items as needed.
                return VideoGridStepSection(id: id, kind: kind, title: title, items: [])
            }
            
            let parseItem = { (jsonSection: [String : Any]) -> VideoGridStepItem? in
                guard let id = jsonSection["listItemId"] as? Int,
                      let title = jsonSection["text"] as? String else {
                    return nil
                }
                let subtitle = jsonSection["detailText"] as? String
                let imageUrlRaw = jsonSection["imageURL"] as? String
                let imageUrl = imageUrlRaw.flatMap({ URL(string: $0) })
                
                return VideoGridStepItem(id: id, title: title, subtitle: subtitle, imageURL: imageUrl)
            }
            
            switch listItemType {
            case .largeSection:
                guard let section = parseSection(listItem) else { return }
                sections.append(section)
            case .smallSection:
                guard let section = parseSection(listItem) else { return }
                sections.append(section)
            case .item:
                //the section an item belongs to, is assumed to be the last parsed section
                guard let item = parseItem(listItem),
                      let currentSection = sections.last else {
                    return
                }
                currentSection.items.append(item)
            }
        }
        
        let listStep = MWVideoGridStep(identifier: data.identifier,
                                                    networkManager: networkManager,
                                                    imageLoader: imageLoader,
                                                    secondaryWorkflowIDs: secondaryWorkflowIDs,
                                                    sections: sections)
        return listStep
    }
}

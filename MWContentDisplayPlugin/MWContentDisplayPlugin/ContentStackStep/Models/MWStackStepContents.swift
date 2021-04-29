//
//  MWStackStepContents.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import Foundation
import MobileWorkflowCore

/// Describes the data model for the vertical stack. It includes the header + items data
struct MWStackStepContents {
    let headerTitle: String?
    let headerImageURL: URL?
    let items: [MWStackStepItem]
    
    init(json: [String:Any], localizationService: LocalizationService) {
        self.headerTitle = localizationService.translate(json["title"] as? String)
        self.headerImageURL = (json["imageURL"] as? String).flatMap{ URL(string: $0) }
        
        let jsonItems = (json["items"] as? Array<[String:Any]>) ?? []
        self.items = jsonItems.compactMap { MWStackStepItem(json: $0, localizationService: localizationService) }
    }
}

// Describes all the supported types of item that can be shown vertically stacked.
// For now, just title, text and listItem
// Every case includes the model that defines the concrete implementation as an associated type
enum MWStackStepItem: Identifiable {
    
    case title(MWStackStepItemTitle)
    case text(MWStackStepItemText)
    case listItem(MWStackStepStepItemListItem)
    case button(MWStackStepItemButton)
    
    public var id: String {
        switch self {
        case .title(let item): return item.id
        case .text(let item): return item.id
        case .listItem(let item): return item.id
        case .button(let item): return item.id
        }
    }
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        if let stepTypeTitle = MWStackStepItemTitle(json: json, localizationService: localizationService) {
            self = .title(stepTypeTitle)
        } else if let stepTypeText = MWStackStepItemText(json: json, localizationService: localizationService) {
            self = .text(stepTypeText)
        } else if let stepTypeListItem = MWStackStepStepItemListItem(json: json, localizationService: localizationService) {
            self = .listItem(stepTypeListItem)
        } else if let stepTypeButtom = MWStackStepItemButton(json: json, localizationService: localizationService) {
            self = .button(stepTypeButtom)
        } else {
            return nil
        }
    }
}

struct MWStackStepItemTitle: Identifiable {
    let id: String
    let title: String
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("title") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        guard let title = localizationService.translate(json["title"] as? String) else {
            return nil
        }
        
        self.id = id
        self.title = title
    }
}

struct MWStackStepItemText: Identifiable {
    let id: String
    let text: String
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("text") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        guard let text = localizationService.translate(json["text"] as? String) else {
            return nil
        }
        self.id = id
        self.text = text
    }
}

struct MWStackStepStepItemListItem: Identifiable {
    let id: String
    let title: String?
    let detailText: String?
    let imageURL: URL?
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("listItem") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        self.id = id
        self.title = localizationService.translate(json["text"] as? String)
        self.detailText = localizationService.translate(json["detailText"] as? String)
        if let imageURLString = json["imageURL"] as? String {
            self.imageURL = URL(string: imageURLString)
        } else {
            self.imageURL = nil
        }
    }
}

struct MWStackStepItemButton: Identifiable {
    let id: String
    let label: String
        
    // Action: Open a modal workflow
    let modalWorkflow: String?
    
    // Action: Perform a request to the given URL
    let remoteURL: URL?
    let remoteURLMethod: HTTPMethod?
    
    // Action: Open the URL to the system
    let systemURL: URL?
    
    // What to do after performing the action
    let sucessAction: SuccessAction
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("button") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        
        self.id = id
        self.label = localizationService.translate(json["label"] as? String) ?? ""
        self.modalWorkflow = json["modalWorkflow"] as? String
        self.remoteURL = (json["url"] as? String).flatMap{ URL(string: $0) }
        self.remoteURLMethod = (json["method"] as? String).flatMap{HTTPMethod(rawValue: $0.uppercased())}
        self.systemURL = (json["appleSystemURL"] as? String).flatMap{ URL(string: $0) }
        self.sucessAction = SuccessAction(rawValue: json["onSuccess"] as? String ?? "") ?? .none
    }
}

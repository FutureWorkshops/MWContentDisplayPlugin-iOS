//
//  GridStepItem.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import MobileWorkflowCore

public enum GridItemType: String, Codable {
    case carouselLarge = "largeSection"
    case carouselSmall = "smallSection"
    case item = "item"
    
    var isSection: Bool {
        switch self {
        case .carouselLarge, .carouselSmall:
            return true
        case .item:
            return false
        }
    }
}

public class GridStepItem: Codable {

    public let id: String
    public let type: String?
    public let text: String?
    public let detailText: String?
    public let imageURL: String?
    public let actionURL: String?
    public let actionSFSymbolName: String?
    public let actionMethod: HTTPMethod?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeAsString(key: .id)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.actionURL = try container.decodeIfPresent(String.self, forKey: .actionURL)
        self.actionSFSymbolName = try container.decodeIfPresent(String.self, forKey: .actionSFSymbolName)
        if let stored = try container.decodeIfPresent(String.self, forKey: .actionMethod) {
            self.actionMethod = HTTPMethod(rawValue: stored)
        } else {
            self.actionMethod = nil
        }
    }
    
    public init(id: String, type: String?, text: String?, detailText: String?, imageURL: String?, actionURL: String?, actionSFSymbolName: String?, actionMethod: HTTPMethod?) {
        self.id = id
        self.type = type
        self.text = text
        self.detailText = detailText
        self.imageURL = imageURL
        self.actionURL = actionURL
        self.actionSFSymbolName = actionSFSymbolName
        self.actionMethod = actionMethod
    }
}

extension GridStepItem {
    public var itemType: GridItemType {
        // default to item if type not found
        GridItemType(rawValue: self.type ?? "item") ?? .item
    }
}

extension GridStepItem: ValueProvider {
    public func fetchValue(for path: String) -> Any? {
        if path == CodingKeys.id.stringValue { return self.id }
        if path == CodingKeys.type.stringValue { return self.type }
        if path == CodingKeys.text.stringValue { return self.text }
        if path == CodingKeys.detailText.stringValue { return self.detailText }
        if path == CodingKeys.imageURL.stringValue { return self.imageURL }
        return nil
    }
    
    public func fetchProvider(for path: String) -> ValueProvider? {
        return nil
    }
}

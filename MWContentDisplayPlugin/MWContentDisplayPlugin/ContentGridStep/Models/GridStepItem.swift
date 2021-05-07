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
    public let text: String
    public let detailText: String?
    public let imageURL: String?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeAsString(key: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
    }
    
    public init(id: String, type: String?, text: String, detailText: String?, imageURL: String?) {
        self.id = id
        self.type = type
        self.text = text
        self.detailText = detailText
        self.imageURL = imageURL
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
    
    public var content: [AnyHashable : Codable] {
        return [CodingKeys.id.stringValue: self.id,
                CodingKeys.type.stringValue: self.type,
                CodingKeys.text.stringValue: self.text,
                CodingKeys.detailText.stringValue: self.detailText,
                CodingKeys.imageURL.stringValue: self.imageURL]
    }
}

//
//  MWGridStepItem.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import MobileWorkflowCore

private let kId = "id"
private let kType = "type"
private let kText = "text"
private let kDetailText = "detailText"
private let kImageURL = "imageURL"

public enum MWGridItemType: String, Codable {
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

public class MWGridStepItem: NSObject, Codable, NSCopying, NSCoding, NSSecureCoding {
    public static var supportsSecureCoding: Bool { true }
    
    public let id: String
    public let type: String?
    public let text: String
    public let detailText: String?
    public let imageURL: String?
    
    public required convenience init?(coder: NSCoder) {
        guard let id = coder.decodeAsString(key: kId) else {
            return nil
        }
        guard let text = coder.decodeObject(of: NSString.self, forKey: kText) else {
            return nil
        }
        let type = coder.decodeObject(of: NSString.self, forKey: kType)
        let detailText = coder.decodeObject(of: NSString.self, forKey: kDetailText)
        let imageURL = coder.decodeObject(of: NSString.self, forKey: kImageURL)
        
        self.init(id: id, type: type as String?, text: text as String, detailText: detailText as String?, imageURL: imageURL as String?)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys.self)
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
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.id as NSString, forKey: kId)
        coder.encode(self.type as NSString?, forKey: kType)
        coder.encode(self.text as NSString, forKey: kText)
        coder.encode(self.detailText as NSString?, forKey: kDetailText)
        coder.encode(self.imageURL as NSString?, forKey: kImageURL)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return MWGridStepItem(id: self.id, type: self.type, text: self.text, detailText: self.detailText, imageURL: self.imageURL)
    }
}

extension MWGridStepItem {
    public override var description: String {
        return "GridItem \(self.id): \(self.text)"
    }
    
    public var itemType: MWGridItemType {
        // default to item if type not found
        MWGridItemType(rawValue: self.type ?? "item") ?? .item
    }
}

extension MWGridStepItem: ValueProvider {
    public func fetchValue(for path: String) -> Any? {
        if path == kId { return self.id }
        if path == kType { return self.type }
        if path == kText { return self.text }
        if path == kDetailText { return self.detailText }
        return nil
    }
    
    public func fetchProvider(for path: String) -> ValueProvider? {
        return nil
    }
    
    public var content: [AnyHashable : Codable] {
        return [
            kId: self.id,
            kType: self.type,
            kText: self.text,
            kDetailText: self.detailText,
            kImageURL: self.imageURL
        ]
    }
}

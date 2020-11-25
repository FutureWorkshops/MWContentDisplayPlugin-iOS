//
//  VideoGridStepItem.swift
//  MobileWorkflowCore
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

enum VideoGridItemType: String, Codable {
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

class VideoGridStepItem: NSObject, Codable, NSCopying, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }
    
    let id: Int
    let type: String?
    let text: String
    let detailText: String?
    let imageURL: String?
    
    required convenience init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: kId) as? Int else {
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
    
    init(id: Int, type: String?, text: String, detailText: String?, imageURL: String?) {
        self.id = id
        self.type = type
        self.text = text
        self.detailText = detailText
        self.imageURL = imageURL
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id as Int, forKey: kId)
        coder.encode(self.type as NSString?, forKey: kType)
        coder.encode(self.text as NSString, forKey: kText)
        coder.encode(self.detailText as NSString?, forKey: kDetailText)
        coder.encode(self.imageURL as NSString?, forKey: kImageURL)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return VideoGridStepItem(id: self.id, type: self.type, text: self.text, detailText: self.detailText, imageURL: self.imageURL)
    }
}

extension VideoGridStepItem {
    override var description: String {
        return "GridItem \(self.id): \(self.text)"
    }
    
    var itemType: VideoGridItemType {
        // default to item if type not found
        VideoGridItemType(rawValue: self.type ?? "item") ?? .item
    }
}

extension VideoGridStepItem: ValueProvider {
    func fetchValue(for path: String) -> Any? {
        if path == "id" { return self.id }
        if path == kType { return self.type }
        if path == kText { return self.text }
        if path == kDetailText { return self.detailText }
        return nil
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        return nil
    }
    
    var content: [AnyHashable : Codable] {
        return [
            kId: self.id,
            kType: self.type,
            kText: self.text,
            kDetailText: self.detailText,
            kImageURL: self.imageURL
        ]
    }
}

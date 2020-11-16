//
//  VideoGridStepSection.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation

private let kId = "id"
private let kKind = "type"
private let kTitle = "title"
private let kItems = "items"

class VideoGridStepSection: NSObject, Codable, NSCopying, NSCoding, NSSecureCoding {
    
    enum Kind: String, Codable {
        case carouselLarge = "largeSection"
        case carouselSmall = "smallSection"
    }
    
    static var supportsSecureCoding: Bool { true }
    
    let id: Int
    let kind: Kind
    let title: String
    var items: [VideoGridStepItem]
    
    required convenience init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: kId) as? Int else {
            return nil
        }
        guard let kindRaw = coder.decodeObject(of: NSString.self, forKey: kKind),
              let kind = Kind(rawValue: kindRaw as String) else {
            return nil
        }
        guard let title = coder.decodeObject(of: NSString.self, forKey: kTitle) else {
            return nil
        }
        guard let items = coder.decodeObject(of: NSArray.self, forKey: kItems) as? [VideoGridStepItem] else {
            return nil
        }
        
        self.init(id: id, kind: kind, title: title as String, items: items)
    }
    
    init(id: Int, kind: Kind, title: String, items: [VideoGridStepItem]) {
        self.id = id
        self.kind = kind
        self.title = title
        self.items = items

        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id as Int, forKey: kId)
        coder.encode(self.kind.rawValue as NSString, forKey: kKind)
        coder.encode(self.title as NSString, forKey: kTitle)
        coder.encode(self.items as NSArray, forKey: kItems)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return VideoGridStepSection(id: self.id, kind: self.kind, title: self.title, items: self.items)
    }
}

extension VideoGridStepSection {
    override var description: String {
        return "VideoGridStepSection \(self.id) : \(self.kind) : \(self.title)"
    }
}

extension VideoGridStepSection: ValueProvider {
    func fetchValue(for path: String) -> Any? {
        if path == kId { return self.id }
        if path == kKind { return self.kind }
        if path == kTitle { return self.title }
        if path == kItems { return self.items }
        return nil
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        return nil
    }
    
    var content: [AnyHashable : Codable] {
        return [kId: self.id,
                kKind: self.kind,
                kTitle: self.title,
                kItems: self.items,]
    }
}

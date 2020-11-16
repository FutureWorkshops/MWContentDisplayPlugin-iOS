//
//  VideoGridStepItem.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import MobileWorkflowCore

private let kId = "id"
private let kTitle = "title"
private let kSubtitle = "subtitle"
private let kImageURL = "imageURL"

class VideoGridStepItem: NSObject, Codable, NSCopying, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }
    
    let id: Int
    let title: String
    let subtitle: String?
    let imageURL: URL?
    
    required convenience init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: kId) as? Int else {
            return nil
        }
        guard let title = coder.decodeObject(of: NSString.self, forKey: kTitle) else {
            return nil
        }
        let subtitle = coder.decodeObject(of: NSString.self, forKey: kSubtitle)
        let imageURL = coder.decodeObject(of: NSURL.self, forKey: kImageURL)
        
        self.init(id: id, title: title as String, subtitle: subtitle as String?, imageURL: imageURL as URL?)
    }
    
    init(id: Int, title: String, subtitle: String?, imageURL: URL?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id as Int, forKey: kId)
        coder.encode(self.title as NSString, forKey: kTitle)
        coder.encode(self.subtitle as NSString?, forKey: kSubtitle)
        coder.encode(self.imageURL as NSURL?, forKey: kImageURL)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return VideoGridStepItem(id: self.id, title: self.title, subtitle: self.subtitle, imageURL: self.imageURL)
    }
}

extension VideoGridStepItem {
    override var description: String {
        return "GridItem \(self.id): \(self.title)"
    }
}

extension VideoGridStepItem: ValueProvider {
    func fetchValue(for path: String) -> Any? {
        if path == kId { return self.id }
        if path == kTitle { return self.title }
        if path == kSubtitle { return self.subtitle }
        return nil
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        return nil
    }
    
    var content: [AnyHashable : Codable] {
        return [kId: self.id,
                kTitle: self.title,
                kSubtitle: self.subtitle,]
    }
}

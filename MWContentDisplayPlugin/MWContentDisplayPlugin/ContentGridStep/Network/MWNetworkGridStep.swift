//
//  MWNetworkGridStep.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import Foundation
import MobileWorkflowCore

public struct NetworkGridStepItemTask: CredentializedAsyncTask, URLAsyncTaskConvertible {
    public typealias Response = [GridStepItem]
    public let input: URL
    public let credential: Credential?
}

public class MWNetworkGridStep: MWStep, GridStep, RemoteContentStep, SyncableContentSource {
    
    public typealias ResponseType = [GridStepItem]
    
    let url: String?
    let emptyText: String?
    public let stepContext: StepContext
    public let session: Session
    public let services: StepServices
    public var items: [GridStepItem] = []
    public var contentURL: String? { self.url }
    public var resolvedURL: URL?
    
    init(identifier: String, stepInfo: StepInfo, services: StepServices, url: String? = nil, emptyText: String? = nil) {
        self.stepContext = stepInfo.context
        self.session = stepInfo.session
        self.services = services
        self.url = url
        self.emptyText = emptyText
        super.init(identifier: identifier, theme: stepInfo.context.theme)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        return MWNetworkGridStepViewController(step: self)
    }
    
    public func loadContent(completion: @escaping (Result<[GridStepItem], Error>) -> Void) {
        guard let contentURL = self.url else {
            return completion(.failure(URLError(.badURL)))
        }
        guard let url = self.session.resolve(url: contentURL) else {
            return completion(.failure(URLError(.badURL)))
        }
        do {
            let credential = try self.services.credentialStore.retrieveCredential(.token, isRequired: false).get()
            let task = NetworkGridStepItemTask(input: url, credential: credential)
            self.services.perform(task: task, session: self.session, completion: completion)
        } catch (let error) {
            completion(.failure(error))
        }
    }
}

extension MWNetworkGridStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] {
        ["url"] // see 'loadContent'
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let emptyText = services.localizationService.translate(stepInfo.data.content["emptyText"] as? String)
        let remoteURLString = stepInfo.data.content["url"] as? String
        return MWNetworkGridStep(identifier: stepInfo.data.identifier, stepInfo: stepInfo, services: services, url: remoteURLString, emptyText: emptyText)
    }
}

public class GridNetworkGridMetadata: StepMetadata {
    enum CodingKeys: String, CodingKey {
        case url
        case emptyText
        case navigationItems = "_navigationItems"
    }
    
    let url: String
    let emptyText: String?
    let navigationItems: [NavigationItemMetadata]?
    
    init(id: String, title: String, url: String, emptyText: String?, navigationItems: [NavigationItemMetadata]?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.url = url
        self.emptyText = emptyText
        self.navigationItems = navigationItems
        super.init(id: id, type: "networkVideoGrid", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.emptyText = try container.decodeIfPresent(String.self, forKey: .emptyText)
        self.navigationItems = try container.decodeIfPresent([NavigationItemMetadata].self, forKey: .navigationItems)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.url, forKey: .url)
        try container.encodeIfPresent(self.emptyText, forKey: .emptyText)
        try container.encodeIfPresent(self.navigationItems, forKey: .navigationItems)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func gridNetworkGrid(
        id: String,
        title: String,
        url: String,
        emptyText: String? = nil,
        navigationItems: [NavigationItemMetadata]? = nil,
        next: PushLinkMetadata? = nil,
        links: [LinkMetadata] = []
    ) -> GridNetworkGridMetadata {
        GridNetworkGridMetadata(id: id, title: title, url: url, emptyText: emptyText, navigationItems: navigationItems, next: next, links: links)
    }
}

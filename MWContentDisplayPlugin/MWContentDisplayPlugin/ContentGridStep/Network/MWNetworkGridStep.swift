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

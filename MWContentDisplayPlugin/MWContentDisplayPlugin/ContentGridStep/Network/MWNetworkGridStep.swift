//
//  MWNetworkGridStep.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import Foundation
import MobileWorkflowCore

public struct MWNetworkGridItemTask: CredentializedAsyncTask, URLAsyncTaskConvertible {
    public typealias Response = [MWGridStepItem]
    public let input: URL
    public let credential: Credential?
}

public class MWNetworkGridStep: MWGridStep, RemoteContentStep, SyncableContentSource {
    
    public typealias ResponseType = [MWGridStepItem]
    
    let url: String?
    let emptyText: String?
    public let stepContext: StepContext
    public var contentURL: String? { self.url }
    public var resolvedURL: URL?
    
    init(identifier: String, stepInfo: StepInfo, services: MobileWorkflowServices, secondaryWorkflowIDs: [String], url: String? = nil, emptyText: String? = nil) {
        self.stepContext = stepInfo.context
        self.url = url
        self.emptyText = emptyText
        super.init(identifier: identifier, session: stepInfo.session, services: services, secondaryWorkflowIDs: secondaryWorkflowIDs, items: [])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWNetworkGridViewController.self
    }
    
    public func loadContent(completion: @escaping (Result<[MWGridStepItem], Error>) -> Void) {
        guard let contentURL = self.url else {
            return completion(.failure(URLError(.badURL)))
        }
        guard let url = self.session.resolve(url: contentURL) else {
            return completion(.failure(URLError(.badURL)))
        }
        do {
            let credential = try self.services.credentialStore.retrieveCredential(.token, isRequired: false).get()
            let task = MWNetworkGridItemTask(input: url, credential: credential)
            self.services.perform(task: task, session: self.session, completion: completion)
        } catch (let error) {
            completion(.failure(error))
        }
    }
}

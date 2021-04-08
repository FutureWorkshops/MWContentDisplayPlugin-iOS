//
//  MWNetworkStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import Foundation
import MobileWorkflowCore

public struct MWNetworkStackItemTask: CredentializedAsyncTask, URLAsyncTaskConvertible {
    public typealias Response = [MWStackItem]
    public let input: URL
    public let credential: Credential?
    
    public func convertToURLAsyncTask<T>(using session: ContentProvider) -> T? where T : AsyncTask {
        return nil
    }
}

public class MWNetworkStackStep: MWStackStep, RemoteContentStep, SyncableContentSource {
    
    // Syncable Content
    public typealias ResponseType = [MWStackItem]
    public var resolvedURL: URL?
    
    // Remote Content
    public var stepContext: StepContext
    public var session: Session
    public var services: MobileWorkflowServices
    public var contentURL: String?
    
    init(identifier: String, headerImageURL: URL?, contentURLString: String?, stepContext: StepContext, session: Session, services: MobileWorkflowServices) {
        self.stepContext = stepContext
        self.session = session
        self.services = services
        self.contentURL = contentURLString
        super.init(identifier: identifier, headerImageURL: headerImageURL, items: [])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWNetworkStackViewController.self
    }
    
    public func loadContent(completion: @escaping (Result<[MWStackItem], Error>) -> Void) {
        guard let contentURL = self.contentURL else {
            return completion(.failure(URLError(.badURL)))
        }
        guard let url = self.session.resolve(url: contentURL) else {
            return completion(.failure(URLError(.badURL)))
        }
        do {
            let credential = try self.services.credentialStore.retrieveCredential(.token, isRequired: false).get()
            let task = MWNetworkStackItemTask(input: url, credential: credential)
            self.services.perform(task: task, session: self.session, completion: completion)
        } catch (let error) {
            completion(.failure(error))
        }
    }
}

//
//  MWNetworkVideoGridStep.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import Foundation
import MobileWorkflowCore

class MWNetworkVideoGridStep: ORKStep, VideoGridStep, RemoteContentStep, SyncableContentSource {
    
    static let defaultEmptyText = "No Content"
    
    typealias ResponseType = [VideoGridStepItem]
    
    let url: String?
    let emptyText: String?
    let stepContext: StepContext
    let session: Session
    let services: MobileWorkflowServices
    let secondaryWorkflowIDs: [Int]
    var contentURL: String? { self.url }
    var resolvedURL: URL?
    var items: [VideoGridStepItem] = []
    
    init(identifier: String, stepInfo: StepInfo, services: MobileWorkflowServices, secondaryWorkflowIDs: [Int], url: String? = nil, emptyText: String? = nil) {
        self.stepContext = stepInfo.context
        self.session = stepInfo.session
        self.services = services
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.url = url
        self.emptyText = emptyText
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func stepViewControllerClass() -> AnyClass {
        return MWNetworkVideoGridViewController.self
    }
    
    func loadContent(completion: @escaping (Result<[VideoGridStepItem], Error>) -> Void) {
        guard let contentURL = self.url else {
            return completion(.failure(URLError(.badURL)))
        }
        guard let url = self.session.resolve(url: contentURL) else {
            return completion(.failure(URLError(.badURL)))
        }
        do {
            let credential = try self.services.credentialStore.retrieveCredential(.token, isRequired: false).get()
            let task = NetworkVideoGridItemTask(input: url, credential: credential)
            self.services.perform(task: task, session: self.session, completion: completion)
        } catch (let error) {
            completion(.failure(error))
        }
    }
}

extension MWNetworkVideoGridStep: MobileWorkflowStep {
    
    static func build(step: StepInfo, services: MobileWorkflowServices) throws -> ORKStep {
        
        let url = step.data.content["url"] as? String
        let emptyText = services.localizationService.translate(step.data.content["emptyText"] as? String)
        let secondaryWorkflowIDs: [Int] = (step.data.content["workflows"] as? [[String: Any]])?.compactMap({ $0["id"] as? Int }) ?? []
        
        let step = MWNetworkVideoGridStep(
            identifier: step.data.identifier,
            stepInfo: step,
            services: services,
            secondaryWorkflowIDs: secondaryWorkflowIDs,
            url: url,
            emptyText: emptyText
        )
        return step
    }
}

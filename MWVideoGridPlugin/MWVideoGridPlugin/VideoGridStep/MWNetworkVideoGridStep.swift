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
    let services: MobileWorkflowServices
    let secondaryWorkflowIDs: [Int]
    var contentURL: String? { self.url }
    var authenticationWorkflowId: Int?
    var resolvedURL: URL?
    var items: [VideoGridStepItem] = []
    
    init(identifier: String, services: MobileWorkflowServices, secondaryWorkflowIDs: [Int], url: String? = nil, authenticationWorkflowId: Int?, emptyText: String? = nil) {
        self.services = services
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.url = url
        self.authenticationWorkflowId = authenticationWorkflowId
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
        guard let url = self.url else {
            return completion(.failure(URLError(.badURL)))
        }
        self.perform(url: url, method: .GET, completion: completion)
    }
}

extension MWNetworkVideoGridStep: MobileWorkflowStep {
    
    static func build(step: StepInfo, services: MobileWorkflowServices) throws -> ORKStep {
        
        let url = step.data.content["url"] as? String
        let emptyText = services.localizationService.translate(step.data.content["emptyText"] as? String)
        let secondaryWorkflowIDs: [Int] = (step.data.content["workflows"] as? [[String: Any]])?.compactMap({ $0["id"] as? Int }) ?? []
        
        let step = MWNetworkVideoGridStep(
            identifier: step.data.identifier,
            services: services,
            secondaryWorkflowIDs: secondaryWorkflowIDs,
            url: url,
            authenticationWorkflowId: step.data.content["authenticationWorkflowId"] as? Int,
            emptyText: emptyText
        )
        return step
    }
}

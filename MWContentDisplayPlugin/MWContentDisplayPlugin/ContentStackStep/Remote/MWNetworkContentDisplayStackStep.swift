//
//  MWNetworkContentDisplayStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import Foundation
import MobileWorkflowCore

class MWNetworkContentDisplayStackStep: MWStep, ContentDisplayStackStep, RemoteContentStep, SyncableContentSource {
    
    // Syncable Content
    typealias ResponseType = MWStackStepContents
    var resolvedURL: URL?
    
    // Remote Content
    let stepContext: StepContext
    let session: Session
    let services: StepServices
    var contentURL: String?
    
    var contents: MWStackStepContents
    
    init(identifier: String, contentURLString: String?, contents: MWStackStepContents, theme: Theme, stepContext: StepContext, session: Session, services: StepServices) {
        self.stepContext = stepContext
        self.session = session
        self.services = services
        self.contentURL = contentURLString
        self.contents = contents
        super.init(identifier: identifier, theme: theme)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func instantiateViewController() -> StepViewController {
        return MWNetworkContentDisplayStackViewController(step: self)
    }
    
    func loadContent(completion: @escaping (Result<MWStackStepContents, Error>) -> Void) {
        
        guard let contentURL = self.contentURL else {
            return completion(.failure(URLError(.badURL)))
        }
        guard let url = self.session.resolve(url: contentURL) else {
            return completion(.failure(URLError(.badURL)))
        }
        
        let task = URLAsyncTask<MWStackStepContents>.build(url: url, method: .GET, session: self.session) { data -> MWStackStepContents in
            let json = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]) ?? [:]
            return MWStackStepContents(json: json, localizationService: self.services.localizationService)
        }
        
        self.services.perform(task: task, session: self.session, completion: completion)
    }
}

extension MWNetworkContentDisplayStackStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] {
        ["url"] // see 'loadContent'
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        
        let contents = MWStackStepContents(json: stepInfo.data.content, localizationService: services.localizationService)
        
        return MWNetworkContentDisplayStackStep(
            identifier: stepInfo.data.identifier,
            contentURLString: stepInfo.data.content["url"] as? String,
            contents: contents,
            theme: stepInfo.context.theme,
            stepContext: stepInfo.context,
            session: stepInfo.session,
            services: services
        )
    }
}

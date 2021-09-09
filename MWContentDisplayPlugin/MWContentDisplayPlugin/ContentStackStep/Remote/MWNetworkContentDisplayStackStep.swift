//
//  MWNetworkContentDisplayStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import Foundation
import MobileWorkflowCore

class MWNetworkContentDisplayStackStep: MWContentDisplayStackStep, RemoteContentStep, SyncableContentSource {
    
    let session: Session
    let services: StepServices
    
    // Syncable Content
    typealias ResponseType = MWStackStepContents
    var resolvedURL: URL?
    
    // Remote Content
    var stepContext: StepContext
    var contentURL: String?
    
    init(identifier: String, contentURLString: String?, contents: MWStackStepContents, stepContext: StepContext, session: Session, services: StepServices) {
        self.session = session
        self.services = services
        self.stepContext = stepContext
        self.contentURL = contentURLString
        super.init(identifier: identifier, contents: contents, tintColor: stepContext.systemTintColor)
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

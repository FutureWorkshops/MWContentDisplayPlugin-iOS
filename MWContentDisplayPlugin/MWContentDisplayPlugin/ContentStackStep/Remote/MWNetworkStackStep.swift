//
//  MWNetworkStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import Foundation
import MobileWorkflowCore

class MWNetworkStackStep: MWStackStep, RemoteContentStep, SyncableContentSource {
    
    // Syncable Content
    typealias ResponseType = [MWStackItem]
    var resolvedURL: URL?
    
    // Remote Content
    var stepContext: StepContext
    var session: Session
    var services: MobileWorkflowServices
    var contentURL: String?
    
    init(identifier: String, headerTitle: String?, headerImageURL: URL?, contentURLString: String?, stepContext: StepContext, session: Session, services: MobileWorkflowServices) {
        self.stepContext = stepContext
        self.session = session
        self.services = services
        self.contentURL = contentURLString
        super.init(identifier: identifier, headerTitle: headerTitle, headerImageURL: headerImageURL, items: [])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func stepViewControllerClass() -> AnyClass {
        return MWNetworkStackViewController.self
    }
    
    func loadContent(completion: @escaping (Result<[MWStackItem], Error>) -> Void) {
        guard let contentURL = self.contentURL else {
            return completion(.failure(URLError(.badURL)))
        }
        guard let url = self.session.resolve(url: contentURL) else {
            return completion(.failure(URLError(.badURL)))
        }
        
        let task = URLAsyncTask<[MWStackItem]>.build(url: url, method: .GET, session: self.session) { data -> [MWStackItem] in
            #warning("parse the json here")
            return []
        }
        
        self.services.perform(task: task, session: self.session, completion: completion)
    }
}

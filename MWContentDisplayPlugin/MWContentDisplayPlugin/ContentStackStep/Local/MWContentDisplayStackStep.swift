//
//  MWContentDisplayStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import Foundation
import UIKit
import MobileWorkflowCore

protocol ContentDisplayStackStep {
    var contents: MWStackStepContents { get set }
    var session: Session { get }
    var services: StepServices { get }
}

public class MWContentDisplayStackStep: MWStep, ContentDisplayStackStep {
    
    var contents: MWStackStepContents
    let session: Session
    let services: StepServices
    
    init(identifier: String, contents: MWStackStepContents, theme: Theme, session: Session, services: StepServices) {
        self.contents = contents
        self.session = session
        self.services = services
        super.init(identifier: identifier, theme: theme)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWContentDisplayStackViewController(step: self)
    }
}

extension MWContentDisplayStackStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] { [] }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        
        let contents = MWStackStepContents(json: stepInfo.data.content, localizationService: services.localizationService)
        
        return MWContentDisplayStackStep(
            identifier: stepInfo.data.identifier,
            contents: contents,
            theme: stepInfo.context.theme,
            session: stepInfo.session,
            services: services
        )
    }
}

extension ContentDisplayStackStep {
    func downloadShareableImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let finalURL = self.session.resolve(url: url.absoluteString) else {
            return completion(.failure(URLError(.badURL)))
        }
        
        let task = URLAsyncTask<UIImage>.build(url: finalURL, method: .GET, session: self.session) { data -> UIImage in
            if let image = UIImage(data: data) {
                return image
            } else {
                throw ParseError.invalidServerData(cause: "Failed to download the image to share.")
            }
        }
        
        self.services.perform(task: task, session: self.session) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


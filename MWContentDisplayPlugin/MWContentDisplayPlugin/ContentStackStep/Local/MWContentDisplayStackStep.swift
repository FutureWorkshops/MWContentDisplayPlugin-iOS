//
//  MWContentDisplayStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import Foundation
import MobileWorkflowCore

public class MWContentDisplayStackStep: MWStep {
    
    var contents: MWStackStepContents
    let tintColor: UIColor
    let session: Session
    let services: StepServices
    
    init(identifier: String, contents: MWStackStepContents, tintColor: UIColor, session: Session, services: StepServices) {
        self.contents = contents
        self.tintColor = tintColor
        self.session = session
        self.services = services
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWContentDisplayStackViewController(step: self)
    }
}

extension MWContentDisplayStackStep: BuildableStep {
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        
        let contents = MWStackStepContents(json: stepInfo.data.content, localizationService: services.localizationService)
        
        if stepInfo.data.type == MWContentDisplayStepType.stack.typeName {
            return MWContentDisplayStackStep(identifier: stepInfo.data.identifier,
                                             contents: contents,
                                             tintColor: stepInfo.context.systemTintColor,
                                             session: stepInfo.session,
                                             services: services)
        } else if stepInfo.data.type == MWContentDisplayStepType.networkStack.typeName {
            return MWNetworkContentDisplayStackStep(identifier: stepInfo.data.identifier,
                                      contentURLString: stepInfo.data.content["url"] as? String,
                                      contents: contents,
                                      stepContext: stepInfo.context,
                                      session: stepInfo.session,
                                      services: services)
        } else {
            throw ParseError.invalidStepData(cause: "Tried to create a stack that's not local nor remote.")
        }
    }
}

extension MWContentDisplayStackStep {
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


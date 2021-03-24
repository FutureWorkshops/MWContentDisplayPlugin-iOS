//
//  MWVideoGridStep.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

public class MWVideoGridStep: ORKStep, VideoGridStep {
    
    let session: Session
    let services: MobileWorkflowServices
    public let secondaryWorkflowIDs: [String]
    let items: [VideoGridStepItem]
    
    init(identifier: String, session: Session, services: MobileWorkflowServices, secondaryWorkflowIDs: [String], items: [VideoGridStepItem]) {
        self.session = session
        self.services = services
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.items = items
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWVideoGridViewController.self
    }
}

extension MWVideoGridStep: MobileWorkflowStep {
    
    public static func build(stepInfo: StepInfo, services: MobileWorkflowServices) throws -> Step {
        
        let secondaryWorkflowIDs: [String] = (stepInfo.data.content["workflows"] as? [[String: Any]])?.compactMap({ $0.getString(key: "id") }) ?? []
        let contentItems = stepInfo.data.content["items"] as? [[String: Any]] ?? []
        let items: [VideoGridStepItem] = try contentItems.compactMap {
            guard let text = services.localizationService.translate($0["text"] as? String) else { return nil }
            let detailText = services.localizationService.translate($0["detailText"] as? String)
            let id: String
            if let asInt = $0["id"] as? Int {
                // legacy
                id = String(asInt)
            } else if let asString = $0["id"] as? String {
                id = asString
            } else {
                throw ParseError.invalidStepData(cause: "Video grid item has invalid id")
            }
            return VideoGridStepItem(
                id: id,
                type: $0["type"] as? String,
                text: text,
                detailText: detailText,
                imageURL: $0["imageURL"] as? String
            )
        }
        let listStep = MWVideoGridStep(
            identifier: stepInfo.data.identifier,
            session: stepInfo.session,
            services: services,
            secondaryWorkflowIDs: secondaryWorkflowIDs,
            items: items
        )
        return listStep
    }
}

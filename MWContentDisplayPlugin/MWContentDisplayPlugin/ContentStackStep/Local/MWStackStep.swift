//
//  MWStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import Foundation
import MobileWorkflowCore

public class MWStackStep: ORKStep {
    
    let headerImageURL: URL?
    let items: [MWStackItem]
    
    init(identifier: String, headerImageURL: URL?, items: [MWStackItem]) {
        self.items = items
        self.headerImageURL = headerImageURL
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWStackViewController.self
    }
}

extension MWStackStep: MobileWorkflowStep {
    public static func build(stepInfo: StepInfo, services: MobileWorkflowServices) throws -> Step {
        let jsonItems = (stepInfo.data.content["items"] as? Array<[String:Any]>) ?? []
        var headerImageURL: URL?
        if let headerImageURLString = stepInfo.data.content["imageURL"] as? String {
            headerImageURL = URL(string: headerImageURLString)
        }
        return MWStackStep(identifier: stepInfo.data.identifier,
                                  headerImageURL: headerImageURL,
                                  items: jsonItems.compactMap { MWStackItem(json: $0, localizationService: services.localizationService) })
    }
}


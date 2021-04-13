//
//  MWStackStep.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import Foundation
import MobileWorkflowCore

public class MWStackStep: ORKStep {
    
    var contents: MWStackStepContents
    
    init(identifier: String, contents: MWStackStepContents) {
        self.contents = contents
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
        
        let contents = MWStackStepContents(json: stepInfo.data.content, localizationService: services.localizationService)
        
        if stepInfo.data.type == MWContentDisplayStepType.stack.typeName {
            return MWStackStep(identifier: stepInfo.data.identifier,
                               contents: contents)
        } else if stepInfo.data.type == MWContentDisplayStepType.networkStack.typeName {
            return MWNetworkStackStep(identifier: stepInfo.data.identifier,
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


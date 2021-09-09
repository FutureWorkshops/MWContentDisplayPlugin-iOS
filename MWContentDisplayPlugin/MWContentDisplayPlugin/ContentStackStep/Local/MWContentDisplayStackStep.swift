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
    
    init(identifier: String, contents: MWStackStepContents, tintColor: UIColor) {
        self.contents = contents
        self.tintColor = tintColor
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
                               tintColor: stepInfo.context.systemTintColor)
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


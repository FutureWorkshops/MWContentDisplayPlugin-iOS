//
//  MWContentStackStep.swift
//  MWVideoGridPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import Foundation
import MobileWorkflowCore

public class MWContentStackStep: ORKStep {
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWContentStackViewController.self
    }
}

extension MWContentStackStep: MobileWorkflowStep {
    public static func build(stepInfo: StepInfo, services: MobileWorkflowServices) throws -> Step {
        throw ParseError.invalidServerData(cause: "NOT HANDLED YET")
    }
}


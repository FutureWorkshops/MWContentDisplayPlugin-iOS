//
//  MWVideoGridPlugin.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 24/11/2020.
//

import Foundation
import MobileWorkflowCore

public struct MWVideoGridPlugin: MobileWorkflowPlugin {
    
    public static var allStepsTypes: [MobileWorkflowStepType] {
        return MWVideoGridStepType.allCases
    }
}

enum MWVideoGridStepType: String, MobileWorkflowStepType, CaseIterable {
    case videoGrid = "videoGrid"
    case networkVideoGrid = "networkVideoGrid"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: MobileWorkflowStep.Type {
        switch self {
        case .videoGrid: return MWVideoGridStep.self
        case .networkVideoGrid: return MWNetworkVideoGridStep.self
        }
    }
}

protocol VideoGridStep: HasSecondaryWorkflows {
    var services: MobileWorkflowServices { get }
    var items: [VideoGridStepItem] { get }
}

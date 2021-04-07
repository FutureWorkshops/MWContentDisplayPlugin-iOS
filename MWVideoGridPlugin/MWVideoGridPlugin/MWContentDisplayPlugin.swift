//
//  MWContentGridPlugin.swift
//  MWVideoGridPlugin
//
//  Created by Xavi Moll on 7/4/21.
//

import Foundation
import MobileWorkflowCore

public struct MWContentDisplayPlugin: MobileWorkflowPlugin {
    public static var allStepsTypes: [MobileWorkflowStepType] {
        return MWContentDisplayStepType.allCases
    }
}

enum MWContentDisplayStepType: String, MobileWorkflowStepType, CaseIterable {
    case videoGrid = "videoGrid"
    case networkVideoGrid = "networkVideoGrid"
    case contentStack = "io.mobileworkflow.ContentStack"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: MobileWorkflowStep.Type {
        switch self {
        case .videoGrid: return MWVideoGridStep.self
        case .networkVideoGrid: return MWNetworkVideoGridStep.self
        case .contentStack: return MWContentStackStep.self
        }
    }
}

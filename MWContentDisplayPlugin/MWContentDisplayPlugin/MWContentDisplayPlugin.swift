//
//  MWContentGridPlugin.swift
//  MWContentDisplayPlugin
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
    case grid = "videoGrid"
    case networkGrid = "networkVideoGrid"
    case stack = "io.mobileworkflow.ContentStack"
    case networkStack = "io.mobileworkflow.NetworkStyledStack"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: MobileWorkflowStep.Type {
        switch self {
        case .grid: return MWGridStep.self
        case .networkGrid: return MWNetworkGridStep.self
        case .stack: return MWStackStep.self
        case .networkStack: return MWNetworkStackStep.self
        }
    }
}

enum L10n {
    static let defaultSectionTitle = "Items"
    static let noContent = "No Content"
    static let `continue` = "Continue"
}

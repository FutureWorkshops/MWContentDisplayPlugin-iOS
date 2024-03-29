//
//  MWContentGridPlugin.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 7/4/21.
//

import Foundation
import MobileWorkflowCore

public struct MWContentDisplayPluginStruct: Plugin {
    public static var allStepsTypes: [StepType] {
        return MWContentDisplayStepType.allCases
    }
}

enum MWContentDisplayStepType: String, StepType, CaseIterable {
    case grid = "videoGrid"
    case networkGrid = "networkVideoGrid"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: BuildableStep.Type {
        switch self {
        case .grid: return MWGridStep.self
        case .networkGrid: return MWNetworkGridStep.self
        }
    }
}

enum L10n {
    static let defaultSectionTitle = "Items"
    static let noContent = "No Content"
    static let `continue` = "Continue"
    static let loading = "Loading..."
}

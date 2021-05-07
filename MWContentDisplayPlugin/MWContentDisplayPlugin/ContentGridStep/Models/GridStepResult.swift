//
//  GridStepResult.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 11/11/2020.
//

import MobileWorkflowCore

extension GridStepItem: SelectionItem {
    public var resultKey: String? {
        return self.text
    }
}

class GridStepResult: SelectionResult<GridStepItem> { }

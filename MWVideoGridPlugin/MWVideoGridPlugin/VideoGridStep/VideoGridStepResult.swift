//
//  VideoGridStepResult.swift
//  MobileWorkflowCore
//
//  Created by Roberto Arreaza on 11/11/2020.
//
import MobileWorkflowCore
import ResearchKit

private let kSelected = "selected"

class VideoGridStepResult: ORKResult, Codable {
    let selected: VideoGridStepItem?
    
    init(identifier: String, selected: VideoGridStepItem?) {
        self.selected = selected
        super.init(identifier: identifier)
    }
    
    override func copy() -> Any {
        return VideoGridStepResult(identifier: self.identifier, selected: self.selected)
    }
    
    required init?(coder: NSCoder) {
        self.selected = coder.decodeObject(of: VideoGridStepItem.self, forKey: kSelected)
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.selected, forKey: kSelected)
        super.encode(with: coder)
    }
}

extension VideoGridStepResult: NavigationTriggerResult {
    var navigationDestinationKey: String? {
        return self.selected?.title
    }
}

extension VideoGridStepResult: JSONRepresentable {
    var jsonContent: String? {
        guard let _ = self.selected else { return nil }
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension VideoGridStepResult: ValueProvider {
    var content: [AnyHashable : Codable] {
        if let selected = self.selected {
            return [self.identifier: [kSelected: selected]]
        } else {
            return [:]
        }
    }
    
    func fetchValue(for path: String) -> Any? {
        if path == kSelected {
            return self.selected
        } else {
            return nil
        }
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        if path == kSelected {
            return self.selected
        } else {
            return nil
        }
    }
}

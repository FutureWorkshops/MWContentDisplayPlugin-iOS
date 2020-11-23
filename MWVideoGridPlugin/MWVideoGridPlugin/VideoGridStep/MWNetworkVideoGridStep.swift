//
//  MWNetworkVideoGridStep.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import Foundation
import MobileWorkflowCore

class MWNetworkVideoGridStep: ORKStep, RemoteContentStep, SyncableContentSource {
    
    static let defaultEmptyText = "No Content"
    
    typealias ResponseType = [VideoGridStepSection]
    
    let url: String?
    let emptyText: String?
    let networkManager: NetworkManager
    let imageLoader: ImageLoader
    let secondaryWorkflowIDs: [Int]
    var contentURL: String? { self.url }
    var resolvedURL: URL?
    
    init(identifier: String, networkManager: NetworkManager, imageLoader: ImageLoader, secondaryWorkflowIDs: [Int], url: String? = nil, emptyText: String? = nil) {
        self.networkManager = networkManager
        self.imageLoader = imageLoader
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.url = url
        self.emptyText = emptyText
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func stepViewControllerClass() -> AnyClass {
        return MWNetworkVideoGridViewController.self
    }
}

extension MWNetworkVideoGridStep: MobileWorkflowStep {
    
    static func build(data: StepData, context: StepContext, networkManager: NetworkManager, imageLoader: ImageLoader, localizationManager: Localization) throws -> ORKStep {
        
        let url = data.content["url"] as? String
        let emptyText = localizationManager.translate(data.content["emptyText"] as? String)
        let secondaryWorkflowIDs: [Int] = (data.content["workflows"] as? [[String: Any]])?.compactMap({ $0["id"] as? Int }) ?? []
        
        let step = MWNetworkVideoGridStep(
            identifier: data.identifier,
            networkManager: networkManager,
            imageLoader: imageLoader,
            secondaryWorkflowIDs: secondaryWorkflowIDs,
            url: url,
            emptyText: emptyText
        )
        return step
    }
}

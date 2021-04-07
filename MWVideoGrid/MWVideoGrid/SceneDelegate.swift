//
//  SceneDelegate.swift
//  MWVideoGrid
//
//  Created by Igor Ferreira on 11/05/2020.
//  Copyright © 2020 Future Workshops. All rights reserved.
//

import UIKit
import MobileWorkflowCore
import MWContentDisplayPlugin

class SceneDelegate: MobileWorkflowSceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        self.dependencies.plugins = [
            MWContentDisplayPlugin.self
        ]
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func preferredConfigurations(urlContexts: Set<UIOpenURLContext>) -> [AppConfigurationContext] {
        var preferredConfigurations = [AppConfigurationContext]()
        if let filePath = Bundle.main.path(forResource: "app", ofType: "json") {
            preferredConfigurations.append(.file(path: filePath, serverId: 128, workflowId: nil, sessionValues: nil))
        }
        return preferredConfigurations
    }
}

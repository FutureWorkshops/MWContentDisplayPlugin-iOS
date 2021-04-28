//
//  MWStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

public class MWStackViewController: MWStepViewController {
    
    var contentStackStep: MWStackStep { self.mwStep as! MWStackStep }
    var hostingController: UIHostingController<MWStackView>? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.installSwiftUIView()
    }
    
    func installSwiftUIView() {
        if let previousHostingController = self.hostingController {
            self.removeCovering(childViewController: previousHostingController)
        }
        
        let swiftUIRootView = MWStackView(contents: self.contentStackStep.contents, backButtonTapped: { [weak self] in
            self?.handleBackButtonTapped()
        }, buttonTapped: { buttonItem in
            print("Tapped \(buttonItem.title ?? "")")
        })
        self.hostingController = UIHostingController(rootView: swiftUIRootView)
        self.addCovering(childViewController: self.hostingController!)
    }
    
    func handleBackButtonTapped() {
        if let navController = self.navigationController, navController.viewControllers.count > 1 {
            self.goBackward()
        } else {
            if let target = self.cancelButtonItem?.target, let action = self.cancelButtonItem?.action {
                UIApplication.shared.sendAction(action, to: target, from: nil, for: nil)
            }
        }
    }
}


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
        let swiftUIRootView = MWStackView(contents: self.contentStackStep.contents)
        self.hostingController = UIHostingController(rootView: swiftUIRootView)
        self.addCovering(childViewController: self.hostingController!)
    }
}


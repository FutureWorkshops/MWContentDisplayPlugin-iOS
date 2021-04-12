//
//  MWStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

public class MWStackViewController: ORKStepViewController {
    
    var contentStackStep: MWStackStep { self.step as! MWStackStep }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(rootView: MWStackView(contents: self.contentStackStep.contents)))
    }
    
}


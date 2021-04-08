//
//  MWContentStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

final class MWContentStackViewController: ORKStepViewController {
    
    var contentStackStep: MWContentStackStep { self.step as! MWContentStackStep }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(rootView: MWContentStackView(step: self.contentStackStep)))
    }
    
}


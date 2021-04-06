//
//  MWContentStackViewController.swift
//  MWVideoGridPlugin
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
        self.addCovering(childViewController: UIHostingController(rootView: ContentView(step: self.contentStackStep)))
    }
    
}

struct ContentView: View {
    
    @State var step: MWContentStackStep
    
    var body: some View {
        Text(step.title ?? "No Title")
    }
}

//
//  MWNetworkStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import UIKit
import SwiftUI
import Foundation
import MobileWorkflowCore

class MWNetworkStackViewController: MWStackViewController, RemoteContentStepViewController {
    
    //MARK: Views
    private let stateView = StateView(frame: .zero)
    
    //MARK: Properties
    var remoteContentStep: MWNetworkStackStep! { self.step as? MWNetworkStackStep }
    weak var workflowPresentationDelegate: WorkflowPresentationDelegate?
    
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadContent()
    }
    
    // MARK: RemoteContentStepViewController
    func loadContent() {
        self.remoteContentStep.loadContent { [weak self] result in
            switch result {
            case .success(let items): self?.update(content: items)
            case .failure(let error): self?.show(error)
            }
        }
    }
    
    func update(content: [MWStackItem]) {
        self.remoteContentStep.items = content
        self.addCovering(childViewController: UIHostingController(rootView: MWStackView(step: self.remoteContentStep)))
        
        if content.isEmpty {
            self.stateView.configure(isLoading: false, title: L10n.noContent, subtitle: nil, buttonConfig: nil)
        }
    }
    
    func showLoading() {
        self.stateView.configure(isLoading: true, title: nil, subtitle: nil, buttonConfig: nil)
    }
    
    func hideLoading() {
        self.stateView.configure(isLoading: false, title: nil, subtitle: nil, buttonConfig: nil)
    }
    
}

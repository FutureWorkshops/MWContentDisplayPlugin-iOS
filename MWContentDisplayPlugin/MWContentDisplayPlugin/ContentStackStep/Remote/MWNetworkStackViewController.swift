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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stateView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.stateView)
        self.stateView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.stateView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        self.loadContent()
    }
    
    // MARK: RemoteContentStepViewController
    func loadContent() {
        self.showLoading()
        self.remoteContentStep.loadContent { [weak self] result in
            self?.hideLoading()
            switch result {
            case .success(let items): self?.update(content: items)
            case .failure(let error): self?.show(error)
            }
        }
    }
    
    func update(content: MWStackContents) {
        self.remoteContentStep.contents = content
        self.addCovering(childViewController: UIHostingController(rootView: MWStackView(contents: self.remoteContentStep.contents)))
        
        if content.items.isEmpty {
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

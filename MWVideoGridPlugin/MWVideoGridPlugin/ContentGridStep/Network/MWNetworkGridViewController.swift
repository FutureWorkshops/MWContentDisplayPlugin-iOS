//
//  MWNetworkGridViewController.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import UIKit
import MobileWorkflowCore

class MWNetworkGridViewController: MWGridViewController, RemoteContentStepViewController, ContentClearable {
    
    weak var workflowPresentationDelegate: WorkflowPresentationDelegate?
    
    var remoteContentStep: MWNetworkGridStep! { self.step as? MWNetworkGridStep }
    
    private lazy var stateView: StateView = {
        let stateView = StateView(frame: .zero)
        stateView.translatesAutoresizingMaskIntoConstraints = true // needs to be true when used as collectionView backgroundView
        return stateView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadContent), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resyncContent()
    }
    
    @objc func reloadContent() {
        self.loadContent()
    }
    
    func clearContent() {
        self.update(content: [])
    }
    
    func update(content: [MWGridStepItem]) {
        self.remoteContentStep.items = content
        self.update(items: content)
        
        if content.isEmpty {
            self.stateView.configure(isLoading: false, title: self.remoteContentStep.emptyText ?? MWNetworkGridStep.defaultEmptyText, subtitle: nil, buttonConfig: nil)
            self.collectionView.backgroundView = self.stateView
        }
    }
    
    func showLoading() {
        if self.refreshControl.isRefreshing == false,
            self.sections.isEmpty {
            self.stateView.configure(isLoading: true, title: nil, subtitle: nil, buttonConfig: nil)
            self.collectionView.backgroundView = self.stateView
            self.collectionView.refreshControl = nil // don't allow pull-to-refresh when loading from empty
        }
    }
    
    func hideLoading() {
        self.collectionView.backgroundView = nil
        self.refreshControl.endRefreshing()
        self.collectionView.refreshControl = self.refreshControl // set/restore this
    }
}

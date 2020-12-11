//
//  MWNetworkVideoGridViewController.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import UIKit
import MobileWorkflowCore

class MWNetworkVideoGridViewController: MWVideoGridViewController, RemoteContentStepViewController, ContentClearable {
    
    weak var workflowPresentationDelegate: WorkflowPresentationDelegate?
    
    var remoteContentStep: MWNetworkVideoGridStep! { self.step as? MWNetworkVideoGridStep }
    
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
    
    func update(content: [VideoGridStepItem]) {
        self.remoteContentStep.items = content
        self.update(items: content)
        
        if content.isEmpty {
            let messageStateView = MessageStateView(frame: .zero, message: self.remoteContentStep.emptyText ?? MWNetworkVideoGridStep.defaultEmptyText)
            self.collectionView.backgroundView = messageStateView
        }
    }
    
    func showLoading() {
        if self.refreshControl.isRefreshing == false,
            self.sections.isEmpty {
            self.collectionView.backgroundView = LoadingStateView(frame: .zero)
            self.collectionView.refreshControl = nil // don't allow pull-to-refresh when loading from empty
        }
    }
    
    func hideLoading() {
        self.collectionView.backgroundView = nil
        self.refreshControl.endRefreshing()
        self.collectionView.refreshControl = self.refreshControl // set/restore this
    }
}

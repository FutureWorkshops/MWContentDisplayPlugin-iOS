//
//  MWNetworkGridStepViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 23/11/2020.
//

import UIKit
import MobileWorkflowCore

class MWNetworkGridStepViewController: MWGridStepViewController, RemoteContentStepViewController, ContentClearable {
    
    weak var presentationDelegate: PresentationDelegate?
    
    var remoteContentStep: MWNetworkGridStep! { self.gridStep as? MWNetworkGridStep }
    
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
        self.reloadContent()
    }
    
    @objc func reloadContent() {
        self.loadContent()
    }
    
    func clearContent() {
        self.update(content: [])
    }
    
    override func performRemoteAction(item: MWGridStepViewController.Item) async -> Void {
        guard let actionURL = item.actionURL,
              let actionMethod = item.actionMethod,
              let resolvedURL = self.gridStep.session.resolve(url: actionURL) else {
            return
        }
        
        let currentState = self.remoteContentStep.items
        
        do {
            let task: URLAsyncTask<Void> = URLAsyncTask<Void>.build(
                url: resolvedURL,
                method: actionMethod,
                session: self.gridStep.session,
                parser: { _ in () }
            )
            try await self.gridStep.services.perform(task: task, session: self.gridStep.session)
            self.loadContent()
        } catch {
            self.update(content: currentState)
            await self.show(error)
        }
    }
    
    func update(content: [GridStepItem]) {
        self.remoteContentStep.items = content
        self.update(items: content)
        
        if content.isEmpty {
            self.stateView.configure(isLoading: false, title: self.remoteContentStep.emptyText ?? L10n.noContent, subtitle: nil, buttonConfig: nil)
            self.collectionView.backgroundView = self.stateView
        }
    }
    
    @MainActor
    func showLoading() {
        if self.refreshControl.isRefreshing == false,
            self.sections.isEmpty {
            self.stateView.configure(isLoading: true, title: nil, subtitle: nil, buttonConfig: nil)
            self.collectionView.backgroundView = self.stateView
            self.collectionView.refreshControl = nil // don't allow pull-to-refresh when loading from empty
        }
    }
    
    @MainActor
    func hideLoading() {
        self.collectionView.backgroundView = nil
        self.refreshControl.endRefreshing()
        self.collectionView.refreshControl = self.refreshControl // set/restore this
    }
}

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
    
    override func favorite(item: GridStepItem) {
        guard let favorite = item.favorite,
              let favoriteURL = item.favoriteURL,
              let resolvedURL = self.gridStep.session.resolve(url: favoriteURL) else {
            return
        }
        Task { await self.toggle(favorite: favorite, url: resolvedURL) }
    }
    
    private func toggle(favorite: Bool, url: URL) async {
        self.showLoading()
        do {
            let task: URLAsyncTask<Data> = URLAsyncTask<Data>.build(url: url, method: favorite ? .PUT : .DELETE, session: self.gridStep.session)
            let _ = try await self.gridStep.services.perform(task: task, session: self.gridStep.session)
            self.loadContent()
        } catch {
            self.hideLoading()
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

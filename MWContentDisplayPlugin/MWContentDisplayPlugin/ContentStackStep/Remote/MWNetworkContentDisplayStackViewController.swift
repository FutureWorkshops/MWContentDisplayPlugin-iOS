//
//  MWNetworkContentDisplayStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import UIKit
import SwiftUI
import Foundation
import MobileWorkflowCore

class MWNetworkContentDisplayStackViewController: MWContentDisplayStackViewController, RemoteContentStepViewController {
    
    //MARK: Views
    private let stateView = StateView(frame: .zero)
    
    //MARK: Properties
    var remoteContentStep: MWNetworkContentDisplayStackStep! { self.mwStep as? MWNetworkContentDisplayStackStep }

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
            case .failure(let error): self?.show(error) { [weak self] in self?.goBackward() }
            }
        }
    }
    
    func update(content: MWStackStepContents) {
        self.remoteContentStep.contents = content
        
        self.installSwiftUIView()
        
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
    
    override func handleButtonItemTapped(_ item: MWStackStepItemButton, in rect: CGRect) {
        if let remoteURL = item.remoteURL, let httpMethod = item.remoteURLMethod {
            // Show alert if confirmation title is present
            if let title = item.confirmTitle {
                self.showConfirmationAlert(title: title, message: item.confirmText, confirmTitle: item.confirmTitle, isDestructive: item.style == .danger) { [weak self] didConfirm in
                    if didConfirm {
                        self?.performButtonRemoteRequest(to: remoteURL, usingHTTPMethod: httpMethod, successAction: item.sucessAction)
                    }
                }
            } else {
                self.performButtonRemoteRequest(to: remoteURL, usingHTTPMethod: httpMethod, successAction: item.sucessAction)
            }
        } else {
            super.handleButtonItemTapped(item, in: rect)
        }
    }
    
    private func performButtonRemoteRequest(to url: URL, usingHTTPMethod httpMethod: HTTPMethod, successAction: SuccessAction) {
        guard let url = self.remoteContentStep.session.resolve(url: url.absoluteString) else { return }
        // Only PUT/DELETE are supported on buttons
        guard httpMethod == .PUT || httpMethod == .DELETE else { return }
        do {
            let credential = try self.remoteContentStep.services.credentialStore.retrieveCredential(.token, isRequired: false).get()
            let task = URLAsyncTask<MWStackStepContents?>.build(url: url, method: httpMethod, session: self.remoteContentStep.session, credential: credential, headers: [:]) { data -> MWStackStepContents? in
                if httpMethod == .PUT {
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
                        throw ParseError.invalidServerData(cause: "Unexpected JSON format.")
                    }
                    return MWStackStepContents(json: json, localizationService: self.remoteContentStep.services.localizationService)
                } else {
                    // For delete we don't need to parse the JSON
                    return nil
                }
            }
            self.remoteContentStep.services.perform(task: task, session: self.remoteContentStep.session) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let newContents):
                    if let newContents = newContents {
                        self.update(content: newContents)
                    }
                    self.handleSuccessAction(successAction)
                case .failure(let error):
                    self.show(error)
                }
            }
        } catch (let error) {
            self.show(error)
        }
    }
    
    public override func handleSuccessAction(_ action: SuccessAction) {
        switch action {
        case .none: break
        case .forward: self.goForward()
        case .backward: self.goBackward()
        case .reload: self.loadContent()
        @unknown default:
            fatalError("Unhandled action: \(action.rawValue)")
        }
    }
}

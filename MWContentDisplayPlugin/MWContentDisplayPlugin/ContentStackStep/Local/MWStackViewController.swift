//
//  MWStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

public class MWStackViewController: MWStepViewController, WorkflowPresentationDelegator, SuccessActionHandler {
    
    //MARK: Public properties (WorkflowPresentationDelegator)
    public weak var workflowPresentationDelegate: WorkflowPresentationDelegate?
    
    //MARK: Properties
    var contentStackStep: MWStackStep { self.mwStep as! MWStackStep }
    var hostingController: UIHostingController<MWStackView>? = nil
    
    //MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.installSwiftUIView()
    }
    
    // MARK: Methods
    func installSwiftUIView() {
        if let previousHostingController = self.hostingController {
            self.removeCovering(childViewController: previousHostingController)
        }
        
        let swiftUIRootView = MWStackView(contents: self.contentStackStep.contents, backButtonTapped: { [weak self] in
            self?.handleBackButtonTapped()
        }, buttonTapped: { [weak self] item in
            self?.handleButtonItemTapped(item)
        })
        self.hostingController = UIHostingController(rootView: swiftUIRootView)
        self.addCovering(childViewController: self.hostingController!)
    }
    
    func handleBackButtonTapped() {
        if let navController = self.navigationController, navController.viewControllers.count > 1 {
            self.goBackward()
        } else {
            if let target = self.cancelButtonItem?.target, let action = self.cancelButtonItem?.action {
                UIApplication.shared.sendAction(action, to: target, from: nil, for: nil)
            }
        }
    }
    
    func handleButtonItemTapped(_ item: MWStackStepItemButton) {
        if let modalWorkflow = item.modalWorkflow {
            self.workflowPresentationDelegate?.presentWorkflowWithName(modalWorkflow, isDiscardable: true, animated: true) { [weak self] reason in
                if reason == .completed {
                    self?.handleSuccessAction(item.sucessAction)
                }
            }
        } else if let remoteURL = item.remoteURL, let httpMethod = item.remoteURLMethod {
            self.performRequest(to: remoteURL, usingHTTPMethod: httpMethod) { result in
                //TODO: Handle result
                dump(result)
            }
        } else if let systemURL = item.systemURL {
            do {
                try self.performSystemAction(systemURL.absoluteString)
            } catch {
                self.show(error)
            }
        } else {
            self.handleSuccessAction(item.sucessAction)
        }
    }
    
    func performRequest(to url: URL, usingHTTPMethod httpMethod: HTTPMethod, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = self.contentStackStep.session.resolve(url: url.absoluteString) else {
            return completion(.failure(URLError(.badURL)))
        }
        do {
            let credential = try self.contentStackStep.services.credentialStore.retrieveCredential(.token, isRequired: false).get()
            let task = URLAsyncTask<Data?>.build(url: url,
                                          method: httpMethod,
                                          body: nil,
                                          session: self.contentStackStep.session,
                                          credential: credential,
                                          headers: [:]) { data in
                //TODO: Parse the response
                throw ParseError.invalidAppData(cause: "UNHANDLED")
            }
            self.contentStackStep.services.perform(task: task, session: self.contentStackStep.session) { result in
                //TODO: Handle result
                dump(result)
            }
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    //MARK: SuccessActionHandler
    public func handleSuccessAction(_ action: SuccessAction) {
        switch action {
        case .none: break
        case .forward: self.goForward()
        case .backward: self.goBackward()
        case .reload: self.installSwiftUIView()
        @unknown default:
            fatalError("Unhandled action: \(action.rawValue)")
        }
    }
}

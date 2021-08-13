//
//  MWStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

// MARK: - MAGIC FOR SWIFTUI. Check if it doesn't collide with any other code in Core

extension MWStackViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is MWStackViewController {
            navigationController.isNavigationBarHidden = true
        }
    }
}

public class MWStackViewController: MWStepViewController, WorkflowPresentationDelegator, SuccessActionHandler {
    
    //MARK: Public properties (WorkflowPresentationDelegator)
    public weak var workflowPresentationDelegate: WorkflowPresentationDelegate?
    
    public override var titleMode: StepViewControllerTitleMode {
        .customOrNone
    }
    
    //MARK: Properties
    var contentStackStep: MWStackStep { self.mwStep as! MWStackStep }
    var hostingController: UIHostingController<MWStackView>? = nil
    
    // Enable per default. Will only be shown if back button is disabled.
    private var isCloseButtonEnabled: Bool {
        return true
    }
    
    private var isBackButtonEnabled: Bool {
        if let navController = self.navigationController {
            return navController.viewControllers.count > 1
        } else {
            return false
        }
    }
    
    //MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.installSwiftUIView()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Methods
    func installSwiftUIView() {
        self.navigationController?.delegate = self
        
        // Enable swipe back if back button is enabled
        if self.isBackButtonEnabled {
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
        if let previousHostingController = self.hostingController {
            self.removeCovering(childViewController: previousHostingController)
        }
        
        let swiftUIRootView = MWStackView(screenSize: self.view.frame.size, contents: self.contentStackStep.contents, backButtonTapped: { [weak self] in
            self?.handleBackButtonTapped()
        }, buttonTapped: { [weak self] item, rect in
            self?.handleButtonItemTapped(item, in: rect)
        }, tintColor: self.contentStackStep.tintColor,
        isCloseButtonEnabled: self.isCloseButtonEnabled,
        isBackButtonEnabled: self.isBackButtonEnabled)
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
    
    func handleButtonItemTapped(_ item: MWStackStepItemButton, in rect: CGRect) {
        if let modalWorkflow = item.modalWorkflow {
            self.workflowPresentationDelegate?.presentWorkflowWithName(modalWorkflow, isDiscardable: true, animated: true) { [weak self] reason in
                if reason == .completed {
                    self?.handleSuccessAction(item.sucessAction)
                }
            }
        } else if let systemURL = item.systemURL {
            do {
                try self.performSystemAction(systemURL.absoluteString)
            } catch {
                self.show(error)
            }
        } else if let linkURL = item.linkURL {
            self.presentActivitySheet(with: [linkURL], sourceRect: rect)
        }
        else {
            self.handleSuccessAction(item.sucessAction)
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

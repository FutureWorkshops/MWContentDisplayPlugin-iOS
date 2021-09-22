//
//  MWContentDisplayStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

public class MWContentDisplayStackViewController: MWStepViewController, WorkflowPresentationDelegator, SuccessActionHandler {
    
    //MARK: Public properties (WorkflowPresentationDelegator)
    public weak var workflowPresentationDelegate: WorkflowPresentationDelegate?
    
    public override var titleMode: StepViewControllerTitleMode {
        .customOrNone
    }
    
    // Hide Navigation Bar
    public override func configureNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.isHidden = true // navBars are now re-shown by default, so we shouldn't need to worry about subsequent steps
    }
    
    //MARK: Properties
    var contentStackStep: MWContentDisplayStackStep { self.mwStep as! MWContentDisplayStackStep }
    var hostingController: UIHostingController<MWStackView>? = nil
    
    // Will only be shown if true and back button is disabled.
    private var isCloseButtonEnabled: Bool {
        guard let presentedWorkflow = self.parent as? PresentedWorkflow else {
            return false
        }
        
        return presentedWorkflow.shouldDismiss
    }
    
    private var isBackButtonEnabled: Bool {
        let shouldHideBackButton = self.mwDelegate?.mwStepViewControllerShouldHideBackButton(self) ?? false
        return !shouldHideBackButton
    }
    
    //MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.installSwiftUIView()
    }
    
    // MARK: Methods
    func installSwiftUIView() {
        #warning("This should not casue any issues with other gesture recognizers. Please bear in mind to check this code if future issues related to navigation gestures arise.")
        // Enable swipe back if back button is enabled
        if self.isBackButtonEnabled {
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
        if let previousHostingController = self.hostingController {
            self.removeCovering(childViewController: previousHostingController)
        }
        
        let swiftUIRootView = MWStackView(contents: self.contentStackStep.contents, backButtonTapped: { [weak self] in
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
            } else if isCloseButtonEnabled {
                // Dismiss Modal Workflow
                self.goForward()
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

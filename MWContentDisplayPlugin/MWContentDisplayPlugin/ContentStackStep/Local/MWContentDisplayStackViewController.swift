//
//  MWContentDisplayStackViewController.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

public class MWContentDisplayStackViewController: MWStepViewController, PresentationDelegator, SuccessActionHandler {
    
    //MARK: Public properties (PresentationDelegator)
    public weak var presentationDelegate: PresentationDelegate?
    
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
    private var blurView: UIView?
    
    // Will only be shown if true and back button is disabled.
    private var isCloseButtonEnabled: Bool {
        guard let nc = self.parent as? StepNavigationViewController else {
            return false
        }
        
        return nc.isDiscardable
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
        
        if let actionSheetButtons = item.actionSheetButtons {
        
            self.presentActionSheet(actionSheetButtons, from: item, rect: rect)
        
        } else if let linkId = item.linkId {
            self.presentationDelegate?.presentStepForLinkId(linkId, isDiscardable: true, animated: true, willDismiss: nil) { [weak self] reason in
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
        } else if (item.linkURL != nil || item.shareText != nil || item.shareImageURL != nil) {
            
            // Block that can be called from multiple places due to the async nature of downloading the image (if present)
            let triggerShareSheet: (([Any]) -> Void) = { [weak self] itemsToShare in
                self?.hideLoadingIndicator()
                // Present the share sheet when everything is ready
                guard let self = self, !itemsToShare.isEmpty else { return }
                UIPasteboard.general.string = itemsToShare.compactMap{ $0 as? String }.joined(separator: " ")
                self.presentActivitySheet(with: itemsToShare, sourceRect: rect)
            }
            
            // Collect all the shareable items
            self.showLoadingIndicator()
            var itemsToShare: [Any] = []
            
            if let text = item.shareText {
                itemsToShare.append(text)
            }
            
            if let link = item.linkURL {
                // We need to share the link as a String, otherwise lots of apps that can't handle URLs (Instagram for example)
                // don't appear on the share sheet. If we share it as text, they do appear because they know how to handle it.
                itemsToShare.append(link.absoluteString)
            }
            
            if let imageURL = item.shareImageURL {
                self.contentStackStep.downloadShareableImage(from: imageURL) { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            // Always add it as the first element
                            itemsToShare.insert(image, at: 0)
                        case .failure(let error):
                            self.show(error)
                        }
                        triggerShareSheet(itemsToShare)
                    }
                }
            } else {
                triggerShareSheet(itemsToShare)
            }
        }
        else {
            self.handleSuccessAction(item.sucessAction)
        }
    }
    
    private func presentActionSheet(_ buttons: [MWStackStepItemButton], from buttonItem: MWStackStepItemButton, rect: CGRect) {
        
        let controller = UIAlertController(title: buttonItem.label, message: nil, preferredStyle: .actionSheet)
        
        buttons.forEach { button in
            let style : UIAlertAction.Style = button.style == .danger ? .destructive : .default
            let buttonAction = UIAlertAction(title: button.label, style: style, handler: { [weak self] _ in
                                                  self?.handleButtonItemTapped(button, in: rect)
                                             })
            controller.addAction(buttonAction)
        }
        
        let cancelAction = UIAlertAction(title: MobileWorkflowCore.L10n.Alert.cancelTitle, style: .cancel)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
        
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
    
    private func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.textAlignment = .center
        label.text = L10n.loading
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let VStack = UIStackView(arrangedSubviews: [activityIndicator, label])
        VStack.distribution = .fill
        VStack.alignment = .center
        VStack.axis = .vertical
        VStack.spacing = 8
        VStack.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 12
        blurView.layer.masksToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(VStack)
        NSLayoutConstraint.activate([
            VStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            VStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            VStack.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])
        
        self.view.addSubview(blurView)
        self.view.bringSubviewToFront(blurView)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalToConstant: 180),
            blurView.widthAnchor.constraint(equalToConstant: 180),
            blurView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            blurView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        self.blurView = blurView
    }
    
    private func hideLoadingIndicator() {
        self.blurView?.removeFromSuperview()
        self.blurView = nil
    }
}

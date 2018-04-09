//
//  RootViewController.swift
//  FileProviderUI
//
//  Created by Ian McDowell on 4/6/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit
import FileProviderUI

class RootViewController: FPUIActionExtensionViewController {

    var visibleViewController: UIViewController? = nil {
        didSet {
            oldValue?.removeFromParentViewController()
            oldValue?.view.removeFromSuperview()
            oldValue?.didMove(toParentViewController: nil)

            if let visibleViewController = visibleViewController {
                visibleViewController.willMove(toParentViewController: self)
                self.view.addSubview(visibleViewController.view)
                self.addChildViewController(visibleViewController)
            }
        }
    }

    override func prepare(forAction actionIdentifier: String, itemIdentifiers: [NSFileProviderItemIdentifier]) {

    }
    
    override func prepare(forError error: Error) {
        visibleViewController = UINavigationController.init(rootViewController: UIViewController.init(nibName: nil, bundle: nil))
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        // Perform the action and call the completion block. If an unrecoverable error occurs you must still call the completion block with an error. Use the error code FPUIExtensionErrorCode.failed to signal the failure.
        extensionContext.completeRequest()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        extensionContext.cancelRequest(withError: NSError(domain: FPUIErrorDomain, code: Int(FPUIExtensionErrorCode.userCancelled.rawValue), userInfo: nil))
    }
    
}


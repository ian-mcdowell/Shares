//
//  RootViewController.swift
//  FileProviderUI
//
//  Created by Ian McDowell on 4/6/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit
import FileProviderUI
import SharesUI
import SharesData

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        FileProviderDomainManager.syncDomains()
    }

    override func prepare(forAction actionIdentifier: String, itemIdentifiers: [NSFileProviderItemIdentifier]) {

    }
    
    override func prepare(forError error: Error) {
        let accounts = AccountListViewController()
        accounts.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.close, style: .plain, target: self, action: #selector(close))
        visibleViewController = UINavigationController.init(rootViewController: accounts)
    }

    override func close() {
        extensionContext.completeRequest()
    }

}


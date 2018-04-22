//
//  AccountListViewController.swift
//  SharesUI
//
//  Created by Ian McDowell on 4/9/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit
import UserInterface
import SharesData

public class AccountListViewController: PropertiesViewController {
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Accounts"
		navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addAccount))
	}
	
	public override func emptyString() -> String {
		return "Welcome to Shares!\n\nTap the \"+\" button at the top to add an account."
	}
	
	public override func loadProperties() -> Properties {
		let accounts = Account.all
		return .properties([
			PropertySection(
				items: accounts.map { account in
					Property(
						name: account.name
					)
				}
			)
		])
	}
	
	@objc private func addAccount() {
		let addAccountVC = AddAccountViewController()
		
		self.present(UINavigationController.init(rootViewController: addAccountVC), animated: true, completion: nil)
	}
}


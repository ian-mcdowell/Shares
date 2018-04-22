//
//  AddAccountViewController.swift
//  SharesUI
//
//  Created by Ian McDowell on 4/9/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit
import UserInterface
import SharesData
import ConnectionKit

public class AddAccountViewController: PropertiesViewController {
	
	private let saveButtonItem: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(save))
	
	private var connection: ConnectionManager.Connection? {
		didSet {
			self.reload()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Add Account"
		navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
		navigationItem.rightBarButtonItem = saveButtonItem
		
		addCloseButtonIfNeeded()
	}
	
	@objc
	private func cancelButtonTapped() {
		close()
	}
	
	public override func willReload() {
		saveButtonItem.isEnabled = connection != nil
	}
	
	public override func loadProperties() -> Properties {
		
		let connections = ConnectionManager.availableConnections
		
		let connectionPropertiesSection: PropertySection
		
		if let connection = self.connection {
			connectionPropertiesSection = PropertySection(
				items: [
					TextProperty(
						ID: "username",
						name: "Username",
						autoCorrect: .no,
						autoCapitalize: .none,
						placeholder: "John"
					),
					TextProperty(
						ID: "password",
						name: "Password",
						secure: true,
						placeholder: "••••••••"
					)
				]
			)
		} else {
			connectionPropertiesSection = PropertySection()
		}
		
		return .properties([
			PropertySection(
				items: [
					TextProperty(
						ID: "name",
						name: "Connection Name",
						placeholder: "My Server"
					)
				]
			),
			PropertySection(
				name: "Select a Protocol",
				items: connections.map { connection in
					Property(
						name: connection.type.displayName,
						action: PropertyAction(block: { [weak self] in
							self?.connection = connection
						}),
						selected: self.connection?.bundleID == connection.bundleID
					)
				},
				emptyString: "Unable to find any protocols.",
				selectionStyle: .single
			),
			connectionPropertiesSection
		])
	}
	
	@objc private func save() {
		guard let connection = self.connection else { return }
		
		guard let name = self.property(withID: "name")?.value?.ifNotEmpty else { self.showAlert("Error", text: "Connection Name is required."); return }
		guard let username = self.property(withID: "username")?.value?.ifNotEmpty else { self.showAlert("Error", text: "Username is required."); return }
		guard let password = self.property(withID: "username")?.value?.ifNotEmpty else { self.showAlert("Error", text: "Password is required."); return }

		
		do {
			let _ = try Account.create(
				name: name,
				type: connection,
				username: username,
				password: password,
				addresses: ["10.1.1.1"],
				port: 22
			)
			self.close()
		} catch {
			self.showAlert("Unable to create account", text: error.localizedDescription)
		}
	}
}


//
//  SharesDataTests.swift
//  SharesDataTests
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import XCTest
@testable import SharesData

class SharesDataTests: XCTestCase {

    var account: Account!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        account = try! Account.create(name: "Test", type: .sftp, username: "Test", password: "test", addresses: [], port: 22)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        account.delete()
    }
    
    func testCreateFile() {
        let file = createFile(named: "test.txt", in: nil)

        let context = Persistence.container.viewContext
        context.delete(file)
        try! context.save()
    }

    func testCreateFolder() {
        let folder = createFolder(named: "Test", in: nil)

        let context = Persistence.container.viewContext
        context.delete(folder)
        try! context.save()
    }

    func testCreateFileInFolder() {
        let folder = createFolder(named: "Test", in: nil)
        let file = createFile(named: "test.txt", in: folder)

        let context = Persistence.container.viewContext
        context.delete(folder)
        context.delete(file)
        try! context.save()
    }


    private func createFile(named name: String, in parent: Folder?) -> File {
        let context = Persistence.container.viewContext
        let file = File(context: context)

        file.name = name
        file.size = 500
        file.parent = parent
        file.account = account

        try! context.save()
        return file
    }

    private func createFolder(named name: String, in parent: Folder?) -> Folder {
        return try! Folder.create(name: name, parent: parent, account: account)
    }
}

//
//  Account+Type.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation

public extension Account {

    public var connectionType: ConnectionType {
        guard let type = ConnectionType.init(rawValue: self.type) else {
            fatalError("Invalid connection type found in core data value")
        }
        return type
    }

    public enum ConnectionType: String {
        case sftp, smb, s3
    }
}

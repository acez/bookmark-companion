//
// CoreDataMigration1To2.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

class CoreDataMigration1To2: NSEntityMigrationPolicy {
    @objc func initInternalId() -> NSUUID {
        return NSUUID()
    }
}

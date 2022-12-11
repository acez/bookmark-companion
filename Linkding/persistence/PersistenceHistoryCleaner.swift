//
// PersistenceHistoryCleaner.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

struct PersistenceHistoryCleaner {
    let timestampKey: String = LinkdingSettingKeys.persistenceHistoryLastTransactionTimestamp.rawValue
    let context: NSManagedObjectContext

    func cleanPersistenceHistory() throws {
        guard let fromDate = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return
        }

        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: fromDate)
        try context.execute(deleteHistoryRequest)

        UserDefaults.standard.set(nil, forKey: timestampKey)
    }
}

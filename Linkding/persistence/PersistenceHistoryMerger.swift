//
// PersistenceHistoryMerger.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

struct PersistenceHistoryMerger {
    let timestampKey: String = LinkdingSettingKeys.persistenceHistoryLastTransactionTimestamp.rawValue

    let backgroundContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext

    func mergeHistory() throws {
        let fromDate = UserDefaults.standard.object(forKey: timestampKey) as? Date  ?? .distantPast

        let fetcher = PersistenceHistoryFetcher(context: backgroundContext, fromDate: fromDate)
        let history = try fetcher.fetchHistoryTransactions()

        guard !history.isEmpty else {
            return
        }

        history.merge(into: backgroundContext)
        viewContext.perform {
            history.merge(into: self.viewContext)
        }

        guard let lastTimestamp = history.last?.timestamp else {
            return
        }
        UserDefaults.standard.set(lastTimestamp, forKey: timestampKey)
    }

}

extension Collection where Element == NSPersistentHistoryTransaction {
    func merge(into context: NSManagedObjectContext) {
        forEach { transaction in
            guard let userInfo = transaction.objectIDNotification().userInfo else { return }
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [context])
        }
    }
}

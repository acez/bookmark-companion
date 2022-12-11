//
// PersistenceHistoryFetcher.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

struct PersistenceHistoryFetcher {
    enum Error: Swift.Error {
        case historyTransactionFailed
    }

    let context: NSManagedObjectContext
    let fromDate: Date

    func fetchHistoryTransactions() throws -> [NSPersistentHistoryTransaction] {
        let fetchRequest = self.buildFetchRequest()

        guard let historyResult = try context.execute(fetchRequest) as? NSPersistentHistoryResult, let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            throw Error.historyTransactionFailed
        }

        return history
    }

    func buildFetchRequest() -> NSPersistentHistoryChangeRequest {
        let historyFetchRequest = NSPersistentHistoryChangeRequest
            .fetchHistory(after: fromDate)

        if let fetchRequest = NSPersistentHistoryTransaction.fetchRequest {
            var predicates: [NSPredicate] = []

            if let transactionAuthor = context.transactionAuthor {
                predicates.append(NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.author), transactionAuthor))
            }
            if let contextName = context.name {
                predicates.append(NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.contextName), contextName))
            }

            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
            historyFetchRequest.fetchRequest = fetchRequest
        }

        return historyFetchRequest
    }
}

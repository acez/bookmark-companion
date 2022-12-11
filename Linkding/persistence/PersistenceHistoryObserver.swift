//
// PersistenceHistoryObserver.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

public class PersistenceHistoryObserver {
    private let container: NSPersistentContainer

    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    public init(container: NSPersistentContainer) {
        self.container = container
    }

    public func start() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(processStoreRemoteChanges),
            name: .NSPersistentStoreRemoteChange,
            object: self.container.persistentStoreCoordinator
        )
    }

    @objc private func processStoreRemoteChanges(_ notification: Notification) {
        historyQueue.addOperation { [weak self] in
            self?.processPersistentHistory()
        }
    }

    @objc private func processPersistentHistory() {
        let context = self.container.newBackgroundContext()
        context.performAndWait {
            do {
                let merger = PersistenceHistoryMerger(backgroundContext: context, viewContext: LinkdingPersistenceController.shared.viewContext)
                try merger.mergeHistory()

                let cleaner = PersistenceHistoryCleaner(context: context)
                try cleaner.cleanPersistenceHistory()
            } catch {
                debugPrint("Error receiving persistence history.")
            }
        }
    }
}

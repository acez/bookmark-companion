//
//  BackendSyncWorker.swift
//  Created by Christian Wilhelm
//

import Foundation

public protocol BackendSyncWorkerPackage {
    func run()
}

public class BackendSyncWorker {
    func queueWorkPackage(package: BackendSyncWorkerPackage) {
        // TODO: Implement background sync
    }
}

//
//  SyncService.swift
//  Created by Christian Wilhelm
//

import Foundation

protocol SyncService {
    func runFullSync() async -> Void
}

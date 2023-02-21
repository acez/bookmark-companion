//
//  BackendSupportClient.swift
//  Created by Christian Wilhelm
//

import Foundation

public protocol BackendSupportClientProtocol {
    func isBackendAvailable() async -> Bool
}

//
//  NetworkMonitor.swift
//  LifeLog
//
//  Created by Genki on 12/22/23.
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    @Published var isConnected: Bool

    init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "NetworkMonitor")
        self.isConnected = false

        self.monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }

        self.monitor.start(queue: self.queue)
    }
}

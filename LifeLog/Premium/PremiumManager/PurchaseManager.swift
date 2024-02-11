//
//  Store.swift
//  LifeLog
//
//  Created by Genki on 11/29/23.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class PurchaseManager: ObservableObject {
    private let productIds = ["com.genki.LifeLog.subscription.monthly"]
    @Published
    private(set) var products: [Product] = []
    private let entitlementManager: EntitlementManager
    private var productsLoaded = false
    private var updates: Task<Void, Never>?
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        self.updates = observeTransactionUpdates()
    }
    deinit {
        updates?.cancel()
    }
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(.verified(let transaction)):
            await transaction.finish()
            await self.updatePurchasedProducts()
        case .success(.unverified):
            break
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    @Published
    private(set) var purchasedProductIDs = Set<String>()
    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        self.entitlementManager.hasPro = !self.purchasedProductIDs.isEmpty
    }
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}

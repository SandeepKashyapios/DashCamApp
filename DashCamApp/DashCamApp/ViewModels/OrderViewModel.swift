//
//  OrderViewModel.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isPlacingOrder = false
    @Published var orderPlaced = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService()
    
    func placeOrder(cart: [CartItem], totalAmount: Double) async -> Bool {
        isPlacingOrder = true
        defer { isPlacingOrder = false }
        
        let order = Order(
            id: nil,
            items: cart,
            totalAmount: totalAmount,
            orderDate: Date(),
            status: .pending
        )
        
        do {
            try await firebaseService.saveOrder(order)
            orderPlaced = true
            return true
        } catch {
            errorMessage = "Failed to place order: \(error.localizedDescription)"
            return false
        }
    }
    
    func loadOrders() async {
        // Implement loading orders from Firestore if needed
    }
}

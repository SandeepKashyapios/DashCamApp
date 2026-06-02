//
//  Order.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    let items: [CartItem]
    let totalAmount: Double
    let orderDate: Date
    let status: OrderStatus
    
    enum OrderStatus: String, Codable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case shipped = "Shipped"
        case delivered = "Delivered"
    }
}



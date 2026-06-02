//
//  CartItem.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        product.price * Double(quantity)
    }
}

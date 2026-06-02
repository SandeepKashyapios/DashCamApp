//
//  Product.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let price: Double
    let imageURL: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case imageURL
        case description
    }
}

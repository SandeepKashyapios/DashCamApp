//
//  FirebaseService.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Fetch products from Firestore
    func fetchProducts() async throws -> [Product] {
        let snapshot = try await db.collection(Constants.firestoreProductsCollection).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Product.self)
        }
    }
    
    // Save order to Firestore
    func saveOrder(_ order: Order) async throws {
        guard let orderData = try? Firestore.Encoder().encode(order) else {
            throw NSError(domain: "Encoding error", code: -1)
        }
        try await db.collection(Constants.firestoreOrdersCollection).addDocument(data: orderData)
    }
    
}

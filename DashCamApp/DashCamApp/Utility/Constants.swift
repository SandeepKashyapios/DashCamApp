//
//  Constants.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation

struct Constants {
    static let firestoreProductsCollection = "products"
    static let firestoreOrdersCollection = "orders"
    
    struct DashCam {
        static let defaultIP = "http://172.20.10.4:8080"
        static let connectionTimeout: TimeInterval = 5.0
    }
}

//
//  ProductCard.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    let onAddToCart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Dynamic image based on product type
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 150)
                
                // Product image
                Image(systemName: getImageName(for: product.imageURL))
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            Text(product.name)
                .font(.headline)
                .lineLimit(1)
            
            Text("$\(product.price, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Button(action: onAddToCart) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Map product imageURL to SF Symbol name. Using system default images As we don't have working image urls
    private func getImageName(for imageURL: String) -> String {
        switch imageURL.lowercased() {
        case "sd_card", "sdcard", "sd card":
            return "memorychip"
        case "charger":
            return "battery.100.bolt"
        case "gps":
            return "location.fill"
        case "hardwire":
            return "cable.connector"
        case "filter":
            return "camera.filters"
        default:
            return "camera.fill"
        }
    }
}

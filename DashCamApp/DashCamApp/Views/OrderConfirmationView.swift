//
//  OrderConfirmationView.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 02/06/26.
//
import SwiftUI

struct OrderConfirmationView: View {
    let totalAmount: Double
    let onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var orderPlaced = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if orderPlaced {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Order Confirmed!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Thank you for your purchase")
                        .foregroundColor(.gray)
                    
                    Text("Total: $\(totalAmount, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button("Continue Shopping") {
                        onComplete()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Processing your order...")
                        .font(.headline)
                        .padding()
                }
            }
            .navigationTitle("Order Status")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Simulate order processing
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                orderPlaced = true
            }
        }
    }
}

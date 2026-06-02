//
//  OrderView.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import SwiftUI

struct OrderView: View {
    @StateObject private var viewModel = OrderViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.orders) { order in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Order #\(order.id?.prefix(8) ?? "N/A")")
                            .font(.headline)
                        Spacer()
                        Text(order.status.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor(order.status))
                            .cornerRadius(5)
                    }
                    
                    Text("Date: \(order.orderDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Items: \(order.items.count)")
                        .font(.caption)
                    
                    Text("Total: $\(order.totalAmount, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("My Orders")
            .overlay {
                if viewModel.orders.isEmpty {
                    ContentUnavailableView(
                        "No Orders",
                        systemImage: "bag",
                        description: Text("Your order history will appear here")
                    )
                }
            }
            .task {
                await viewModel.loadOrders()
            }
        }
    }
    
    private func statusColor(_ status: Order.OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

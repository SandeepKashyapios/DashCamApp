//
//  CartView.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 02/06/26.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: ShopViewModel
    let onCheckout: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cart.indices, id: \.self) { index in
                    let item = viewModel.cart[index]
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.product.name)
                                .font(.headline)
                            Text("$\(item.product.price, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                // Decrease quantity
                                let newQuantity = item.quantity - 1
                                if newQuantity > 0 {
                                    viewModel.updateQuantity(at: index, quantity: newQuantity)
                                } else {
                                    viewModel.removeFromCart(at: index)
                                }
                            }) {
                                Image(systemName: "minus.circle")
                                    .font(.title3)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Text("\(item.quantity)")
                                .font(.headline)
                                .frame(width: 40)
                            
                            Button(action: {
                                // Increase quantity
                                viewModel.updateQuantity(at: index, quantity: item.quantity + 1)
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        
                        Text("$\(item.totalPrice, specifier: "%.2f")")
                            .font(.headline)
                            .frame(width: 70)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet.sorted(by: >) {
                        viewModel.removeFromCart(at: index)
                    }
                }
                
                Section {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("$\(viewModel.totalAmount, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onCheckout) {
                        HStack {
                            Spacer()
                            Text("Proceed to Checkout")
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(viewModel.cart.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.cart.isEmpty)
                }
            }
            .navigationTitle("Cart (\(viewModel.cart.count) items)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

//
//  ShopView.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import SwiftUI

struct ShopView: View {
    @StateObject private var viewModel = ShopViewModel()
    @State private var showingCart = false
    @State private var showingOrderConfirmation = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.products) { product in
                            ProductCard(product: product) {
                                viewModel.addToCart(product: product)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Accessories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCart = true }) {
                        ZStack {
                            Image(systemName: "cart")
                            if viewModel.cart.count > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Text("\(viewModel.cart.count)")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCart) {
                CartView(viewModel: viewModel, onCheckout: {
                    showingCart = false
                    showingOrderConfirmation = true
                })
            }
            .sheet(isPresented: $showingOrderConfirmation) {
                OrderConfirmationView(
                    totalAmount: viewModel.totalAmount,
                    onComplete: {
                        viewModel.cart.removeAll()
                    }
                )
            }
            .task {
                await viewModel.loadProducts()
            }
        }
    }
}


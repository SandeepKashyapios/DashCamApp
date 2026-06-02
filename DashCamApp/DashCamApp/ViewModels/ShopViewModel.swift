//
//  ShopViewModel.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

/*import Foundation
import Combine

@MainActor
class ShopViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var cart: [CartItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService()
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await firebaseService.fetchProducts()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            let cartItem = CartItem(id: UUID().uuidString, product: product, quantity: 1)
            cart.append(cartItem)
        }
    }
    
    func removeFromCart(item: CartItem) {
        cart.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(item: CartItem, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                cart.remove(at: index)
            } else {
                cart[index].quantity = quantity
            }
        }
    }
    
    var totalAmount: Double {
        cart.reduce(0) { $0 + $1.totalPrice }
    }
}
*/
import Foundation
import Combine

@MainActor
class ShopViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var cart: [CartItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService()
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await firebaseService.fetchProducts()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            let cartItem = CartItem(id: UUID().uuidString, product: product, quantity: 1)
            cart.append(cartItem)
        }
    }
    
    func removeFromCart(at index: Int) {
        guard index >= 0 && index < cart.count else { return }
        cart.remove(at: index)
    }
    
    func removeFromCart(item: CartItem) {
        cart.removeAll { $0.id == item.id }
    }
    
    func updateQuantity(at index: Int, quantity: Int) {
        guard index >= 0 && index < cart.count else { return }
        cart[index].quantity = quantity
    }
    
    func updateQuantity(item: CartItem, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                cart.remove(at: index)
            } else {
                cart[index].quantity = quantity
            }
        }
    }
    
    var totalAmount: Double {
        cart.reduce(0) { $0 + $1.totalPrice }
    }
}

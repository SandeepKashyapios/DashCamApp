//
//  ContentView.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashCamView()
                .tabItem {
                    Label("Dash Cam", systemImage: "camera.viewfinder")
                }
                .tag(0)
            
            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "bag")
                }
                .tag(1)
            
            OrderView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet.clipboard")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}

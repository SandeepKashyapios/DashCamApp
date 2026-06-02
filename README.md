#  📱 Dash Cam App - Complete Assignment Documentation

## Table of Contents
1. Project Overview
2. Features
3. Technical Stack
4. Project Structure
5. Setup Instructions
6. Firebase Configuration
7. Running the App
8. Demo Video
9. Improvements Needed/Can do more

## Project Overview
This is a comprehensive iOS application built with SwiftUI that simulates a dash cam system with e-commerce integration. The app demonstrates modern iOS development practices including MVVM architecture, async/await patterns, real-time camera feed, and Firebase Firestore backend integration.

## Key Functionality:
- Dash Cam Simulation: Real camera feed with IP Webcam 
- E-Commerce Shop: Browse products, add to cart, checkout process
- Order Management: View order history with real-time updates
- Firebase Integration: Products and orders stored in Cloud Firestore

## Features
1. Dash Cam Module
✅ Real camera access using AVFoundation
✅ Live video feed with HUD overlay
✅ Connection status indicators
✅ Recording animation

2. E-Commerce Module
✅ Product listing from Firestore
✅ Add/remove items from cart
✅ Cart quantity management
✅ Order placement with Firestore storage
✅ Real-time order updates


3. UI/UX Features
✅ Tab-based navigation
✅ Modern card-based design
✅ Loading states and animations
✅ Error handling with alerts
✅ Empty states
✅ Pull-to-refresh


## Project Structure
DashCamApp/
├── Models/
│   ├── Product.swift
│   ├── CartItem.swift
│   └── Order.swift
├── ViewModels/
│   ├── DashCamViewModel.swift
│   ├── ShopViewModel.swift
│   └── OrderViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── DashCamView.swift
│   ├── ShopView.swift
│   ├── CartView.swift
│   ├── OrderView.swift
│   ├── OrderConfirmationView.swift
│   └── Components/
│       ├── ProductCard.swift
│       ├── LoadingView.swift
│       ├── OrderCard.swift
│       └── FilterChip.swift
├── Services/
│   ├── FirebaseService.swift
│   └── DashCamService.swift
├── Utils/
│   └── Constants.swift
└── DashCamApp.swift

# Setup Instructions
## Prerequisites
- Xcode 26.0 or later (Download from Mac App Store)
- iOS 18.0 or later deployment target
- Apple ID 
- Firebase account (free tier)
- iOS device

# Firebase Configuration
## Step 1: Create Firebase Project
- Go to Firebase Console
- Click "Create Project"
- Project name: DashCamApp
- Click "Create Project"

## Step 2: Register iOS App
- In Firebase Console, click "Add app" → Select iOS icon
- iOS bundle ID: Use your Xcode project's bundle ID
- Find it in Xcode: Select project → General → Bundle Identifier
- Example: com.yourcompany.DashCamApp
- App nickname: DashCamApp
- Click "Register app"
- Download GoogleService-Info.plist
- Drag the file into your Xcode project (check "Copy items if needed")

## Step 3: Enable Firestore
- In Firebase Console: Build → Firestore Database
- Click "Create Database"
- Start in test mode (for development)
- Choose database location (closest to you)

## Step 4: Add Products to Firestore
- Method A - Manual (Recommended):
- In Firestore console, click "Start collection"
- Collection ID: products
##Add first document:
- text
- name: "32GB SD Card"
- price: 29.99
- imageURL: "sd_card"
- description: "High-speed memory card"
- Click "Save"

Repeat for other products:

# Running the App
## On Physical Device:
- Connect iPhone via USB
- Select your device from scheme dropdown
- Press Cmd + R
- Grant camera permission when prompted
- You'll see real camera feed

# Usage Guide
## Dash Cam Module
- Connect to Camera:
- Launch app → Dash Cam tab
- Tap "Start Dash Cam"
- Wait 2 seconds for connection
- Camera feed appears with HUD overlay

## Shop Module
- Browse Products:
- Tap Shop tab
- Scroll through product grid
- Each card shows name, price, and Add to Cart button

## Add to Cart:
- Tap "Add to Cart" on any product
- Cart badge updates with item count
- Notification count confirms addition

## Manage Cart:
- Tap cart icon (top right)
- Adjust quantities with +/- buttons
- Swipe to delete items
- View total amount

## Checkout:
- Tap "Proceed to Checkout"
- See order processing animation
- Order confirmation appears
- Cart automatically clears

##  Orders Module
- See list of purchased orders. Currently this functionality is not implemented, Only static message is displayed for better user experience

## Demo Video

https://github.com/user-attachments/assets/4863058f-9f43-4669-8335-28f6adf9598e



## Improvements Needed/Can do more
- Can Implement fallback device camera. If IP Webcam connection is not established.
- Can Impelement mock Camera for run in simulator
- Fetch Order history from firebase and display in Order History
- Can use Async Image to download product images in background thread. Currently using system images
- Can add static strings in constant file

## Author
Sandeep Kumar


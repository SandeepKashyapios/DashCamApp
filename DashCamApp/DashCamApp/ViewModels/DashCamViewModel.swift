//
//  DashCamViewModel.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation
import UIKit
import AVFoundation
import Combine

@MainActor
class DashCamViewModel: ObservableObject {
    @Published var connectionState: DashCamService.ConnectionState = .disconnected
    @Published var currentFrame: UIImage?
    @Published var isConnecting = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isRecording = false
    
    private let dashCamService = DashCamService()
    private var frameObserver: NSObjectProtocol?
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        frameObserver = NotificationCenter.default.addObserver(
            forName: .didReceiveVideoFrame,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateCurrentFrame()
            }
        }
    }
    
    func connectToDashCam() async {
        await MainActor.run {
            self.isConnecting = true
        }
        
        do {
            try await dashCamService.connectToCamera()
            await updateConnectionState()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to connect: \(error.localizedDescription)"
                self.showError = true
                self.isRecording = false
            }
        }
        
        await MainActor.run {
            self.isConnecting = false
        }
    }
    
    private func updateConnectionState() async {
        await MainActor.run {
            self.connectionState = dashCamService.connectionState
            // Fix: Use switch statement instead of == operator
            switch self.connectionState {
            case .connected:
                self.isRecording = true
            default:
                self.isRecording = false
            }
        }
    }
    
    private func updateCurrentFrame() {
        currentFrame = dashCamService.currentFrame
    }
    
    func disconnect() {
        Task { @MainActor in
            dashCamService.disconnect()
            self.connectionState = .disconnected
            self.currentFrame = nil
            self.isRecording = false
        }
    }
    
    func switchCamera() {
        dashCamService.switchCamera()
    }
    
   /* func toggleTorch() {
        dashCamService.toggleTorch()
    }*/
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return dashCamService.getPreviewLayer()
    }
    
    deinit {
        // Remove observer first (this is safe in deinit)
        if let observer = frameObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // For disconnect, we need to handle it carefully in deinit
        // Since we can't use async in deinit, we'll call a synchronous cleanup
        // We'll use Task but without awaiting (fire and forget)
        Task { [dashCamService] in
            await MainActor.run {
                dashCamService.disconnect()
            }
        }
    }
}

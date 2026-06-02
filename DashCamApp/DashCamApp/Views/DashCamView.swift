//
//  DashCamView.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import SwiftUI
import AVFoundation

struct DashCamView: View {
    @StateObject private var viewModel = DashCamViewModel()
    @State private var showingAlert = false
    @State private var showCameraControls = false
    
    var body: some View {
        ZStack {
            // Video Feed Area
            if case .connected = viewModel.connectionState {
                if let previewLayer = viewModel.getPreviewLayer() {
                    CameraPreviewView(previewLayer: previewLayer)
                        .edgesIgnoringSafeArea(.all)
                } else if let frame = viewModel.currentFrame {
                    // Fallback to UIImage view if preview layer isn't available
                    Image(uiImage: frame)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.all)
                }
            
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 20) {
                            Image(systemName: "video.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            Text("No Video Feed")
                                .foregroundColor(.white)
                        }
                    )
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                HStack {
                    if case .connecting = viewModel.connectionState {
                        ConnectingAnimationView()
                            .padding()
                    }
                    Spacer()
                    
                    if case .connected = viewModel.connectionState {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .opacity(viewModel.isRecording ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(), value: viewModel.isRecording)
                            
                            Text("REC")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.trailing)
                        .padding(.top, 50)
                    }
                }
                Spacer()
                
                // Connection Controls
                VStack(spacing: 20) {
                    if case .disconnected = viewModel.connectionState {
                        Button(action: connectToCamera) {
                            Label("Start Dash Cam", systemImage: "camera.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                    } else if case .connected = viewModel.connectionState {
                        Button(action: disconnectCamera) {
                            Label("Stop Recording", systemImage: "stop.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Connection Status
                    HStack {
                        Image(systemName: connectionIcon)
                            .foregroundColor(connectionColor)
                        Text(connectionText)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 30)
                }
                //.background(Color.black.opacity(0.7))
            }
            .padding()
            
            if viewModel.isConnecting {
                LoadingView()
            }
        }
        .alert("Connection Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            checkCameraPermissionAndConnect()
        }
    }
    
    private func checkCameraPermissionAndConnect() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            connectToCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.connectToCamera()
                    }
                }
            }
        default:
            viewModel.errorMessage = "Camera access denied. Please enable in Settings"
            viewModel.showError = true
        }
    }
    
    private func connectToCamera() {
        Task {
            await viewModel.connectToDashCam()
        }
    }
    
    private func disconnectCamera() {
        viewModel.disconnect()
    }
    
    private var connectionIcon: String {
        switch viewModel.connectionState {
        case .disconnected: return "camera.slash"
        case .connecting: return "circle.dashed"
        case .connected: return "camera.fill"
        case .failed: return "exclamationmark.triangle"
        }
    }
    
    private var connectionColor: Color {
        switch viewModel.connectionState {
        case .disconnected: return .gray
        case .connecting: return .yellow
        case .connected: return .green
        case .failed: return .red
        }
    }
    
    private var connectionText: String {
        switch viewModel.connectionState {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Recording"
        case .failed(let msg): return "Failed: \(msg)"
        }
    }
}

// MARK: - Camera Preview UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}

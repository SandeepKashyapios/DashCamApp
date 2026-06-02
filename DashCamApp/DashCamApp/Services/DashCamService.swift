//
//  DashCamService.swift
//  DashCamApp
//
//  Created by Sandeep Kumar on 31/05/26.
//

import Foundation
import AVFoundation
import UIKit
import Combine

@MainActor
class DashCamService: NSObject, ObservableObject {
    @Published var connectionState: ConnectionState = .disconnected
    @Published var isStreaming = false
    @Published var errorMessage: String?
    @Published var currentFrame: UIImage?
    
    // Camera capture session for device camera
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var isSessionRunning = false
    
    // IP Camera streaming
    private var ipCameraURL: URL?
    private var imageView: UIImageView?
    private var streamTimer: Timer?
    private var isUsingIPCamera = false
  //  private var isUsingRealDeviceCamera = false
    
    // Mock streaming fallback
   // private var mockStreamTimer: Timer?
   // private var isUsingMockCamera = false
    
    // URLSession for IP camera
    private var urlSession: URLSession?
    private var streamTask: URLSessionDataTask?
    
    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case failed(String)
        
        static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected, .disconnected):
                return true
            case (.connecting, .connecting):
                return true
            case (.connected, .connected):
                return true
            case (.failed(let lhsMsg), .failed(let rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }
    
    override init() {
        super.init()
        checkCameraPermissions()
        setupURLSession()
    }
    
    private func setupURLSession() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Camera Permissions
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access authorized")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    Task { @MainActor in
                        self.errorMessage = "Camera access is required for dash cam feature"
                        self.connectionState = .failed("Camera permission denied")
                    }
                }
            }
        case .denied, .restricted:
            Task { @MainActor in
                self.errorMessage = "Please enable camera access in Settings"
                self.connectionState = .failed("Camera access denied")
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Public Methods
    func connectToCamera(ipAddress: String = "http://172.20.10.4:8080") async throws {
        // Update state to connecting
        await MainActor.run {
            connectionState = .connecting
            isStreaming = false
        }
        
        // Parse IP address
        let baseURL = ipAddress.hasPrefix("http") ? ipAddress : "http://\(ipAddress)"
        
        // Try IP Camera first (Android IP Webcam)
        if await setupIPCamera(urlString: baseURL) {
            await MainActor.run {
                connectionState = .connected
                isStreaming = true
                isUsingIPCamera = true
                //isUsingRealDeviceCamera = false
                //isUsingMockCamera = false
                startIPCameraStream()
            }
            return
        }
    }
    
    // MARK: - IP Camera Setup
    private func setupIPCamera(urlString: String) async -> Bool {
        // Test different endpoints for IP Webcam
        let endpoints = [
            "\(urlString)/shot.jpg",           // IP Webcam default
            "\(urlString)/photo.jpg",           // Alternative
            "\(urlString)/video",               // MJPEG stream
            "\(urlString)/picture/1"            // Another format
        ]
        
        for endpoint in endpoints {
            if let url = URL(string: endpoint) {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode == 200,
                       UIImage(data: data) != nil {
                        ipCameraURL = URL(string: endpoint)
                        print("✅ Connected to IP Camera at: \(endpoint)")
                        return true
                    }
                } catch {
                    print("Failed to connect to \(endpoint): \(error.localizedDescription)")
                }
            }
        }
        
        return false
    }
    
    private func startIPCameraStream() {
        guard let baseURL = ipCameraURL else { return }
        
        // For MJPEG streaming
        if baseURL.absoluteString.contains("video") {
            startMJPEGStream(url: baseURL)
        } else {
            // For snapshot-based streaming
            startSnapshotStream(baseURL: baseURL)
        }
    }
    
    private func startMJPEGStream(url: URL) {
        // For MJPEG streaming, we need to handle the stream differently
        let streamURL = url
        var request = URLRequest(url: streamURL)
        request.timeoutInterval = 5.0
        
        streamTask = urlSession?.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Stream error: \(error.localizedDescription)")
                Task { @MainActor in
                    self.handleStreamError()
                }
                return
            }
            
            // Process MJPEG data
            if let data = data, let image = UIImage(data: data) {
                Task { @MainActor in
                    self.currentFrame = image
                    NotificationCenter.default.post(name: .didReceiveVideoFrame, object: nil)
                }
            }
        }
        
        streamTask?.resume()
        
        // Refresh stream periodically
        streamTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { [weak self] _ in
            self?.refreshStream()
        }
    }
    
    private func startSnapshotStream(baseURL: URL) {
        // For snapshot-based IP cameras, fetch frames at 30 FPS
        streamTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { [weak self] _ in
            self?.fetchSnapshot()
        }
    }
    
    private func fetchSnapshot() {
        guard let url = ipCameraURL else { return }
        
        let task = urlSession?.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            Task { @MainActor in
                self.currentFrame = image
                NotificationCenter.default.post(name: .didReceiveVideoFrame, object: nil)
            }
        }
        
        task?.resume()
    }
    
    private func refreshStream() {
        // Reconnect stream if needed
        if streamTask?.state == .completed {
            startIPCameraStream()
        }
    }
    
    private func handleStreamError() {
        // Try to reconnect
        if isUsingIPCamera {
            print("Stream lost, attempting to reconnect...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.reconnectIPCamera()
            }
        }
    }
    
    private func reconnectIPCamera() {
        guard let url = ipCameraURL else { return }
        
        Task {
            if await setupIPCamera(urlString: url.absoluteString) {
                await MainActor.run {
                    startIPCameraStream()
                }
            } else {
                await MainActor.run {
                    connectionState = .failed("IP Camera connection lost")
                    isStreaming = false
                }
            }
        }
    }
    
    // MARK: - Device Camera Setup
    private func setupRealCamera() async -> Bool {
        return await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }
                
                let success = self.configureCaptureSession()
                continuation.resume(returning: success)
            }
        }
    }
    
    private func configureCaptureSession() -> Bool {
        if captureSession != nil && isSessionRunning {
            return true
        }
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No back camera available")
            return false
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                return false
            }
        } catch {
            print("Failed to create camera input: \(error.localizedDescription)")
            return false
        }
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.frame.queue"))
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            videoOutput = output
        } else {
            return false
        }
        
        if let connection = output.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = false
            }
        }
        
        captureSession = session
        return true
    }
    
    private func startCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, let session = self.captureSession, !self.isSessionRunning else { return }
            
            session.startRunning()
            self.isSessionRunning = true
            print("Device camera session started successfully")
        }
    }
    
    private func stopCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, let session = self.captureSession, self.isSessionRunning else { return }
            
            session.stopRunning()
            self.isSessionRunning = false
            print("Device camera session stopped")
        }
    }
    
    // MARK: - Disconnect
    func disconnect() {
        // Stop IP camera stream
        if isUsingIPCamera {
            streamTimer?.invalidate()
            streamTimer = nil
            streamTask?.cancel()
            streamTask = nil
        }
        captureSession = nil
        videoOutput = nil
        connectionState = .disconnected
        isStreaming = false
        currentFrame = nil
        isUsingIPCamera = false
    }

    // MARK: - Camera Controls (Device Camera only)
    func switchCamera() {
        guard !isUsingIPCamera else {
            print("Camera switching only available for device camera")
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let session = self.captureSession,
                  let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
            
            session.beginConfiguration()
            session.removeInput(currentInput)
            
            let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
            
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
                session.commitConfiguration()
                return
            }
            
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            }
            
            if let output = self.videoOutput,
               let connection = output.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = (newPosition == .front)
                }
            }
            
            session.commitConfiguration()
        }
    }
    
   /* func toggleTorch() {
        guard !isUsingIPCamera else {
            print("Torch only available for device camera")
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let camera = AVCaptureDevice.default(for: .video) else { return }
            
            do {
                try camera.lockForConfiguration()
                let newState = !camera.isTorchActive
                camera.torchMode = newState ? .on : .off
                camera.unlockForConfiguration()
            } catch {
                print("Failed to toggle torch: \(error.localizedDescription)")
            }
        }
    }*/
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let session = captureSession, !isUsingIPCamera else { return nil }
        
        if previewLayer == nil {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            previewLayer = layer
        }
        
        return previewLayer
    }
    
    // MARK: - Helper Methods
    func getCurrentCameraType() -> String {
        if isUsingIPCamera {
            return "IP Camera"
        } else {
            return "Simulator"
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension DashCamService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        let image = UIImage(cgImage: cgImage)
        
        Task { @MainActor in
            self.currentFrame = image
            NotificationCenter.default.post(name: .didReceiveVideoFrame, object: nil)
        }
    }
}

extension Notification.Name {
    static let didReceiveVideoFrame = Notification.Name("didReceiveVideoFrame")
}

//
//  CameraController.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 23/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    var previewContainerView: PreviewPhotoContainerView?

    func handleCapturePhoto(isFrontCamera: Bool) {
        let settings = AVCapturePhotoSettings()

            guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }

            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]

            output.capturePhoto(with: settings, delegate: self)

    }

    func stopRunning() {
        captureSession.stopRunning()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let previewImage = UIImage(data: imageData) else { return }

         if captureSession.inputs.contains(frontCameraDeviceInput!) == true {
            previewContainerView?.previewImageView.image = UIImage(cgImage: previewImage.cgImage!,
                                                                   scale: CGFloat(1),
                                                                   orientation: .leftMirrored)
         } else {
            previewContainerView?.previewImageView.image = previewImage
        }

    }

    var captureSession = AVCaptureSession()
    var currentCamera: AVCaptureDevice?
    var output = AVCapturePhotoOutput()
    var frontCameraDeviceInput: AVCaptureDeviceInput?
    var backCameraDeviceInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    fileprivate func setupCaptureSession() {
        captureSession.sessionPreset = .photo
    }

    fileprivate func setupDevice() {
        // 1. setup inputs
        guard let frontCamera = AVCaptureDevice.default( .builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else { return }
        guard let backCamera = AVCaptureDevice.default( .builtInWideAngleCamera,
                                                         for: .video,
                                                         position: .back) else { return }

        frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCamera)
        backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCamera)
    }

    func setupInputOutput() {
        captureSession.addInput(frontCameraDeviceInput!)
        output = AVCapturePhotoOutput()
        output.setPreparedPhotoSettingsArray(
            [AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])],
            completionHandler: nil)
        captureSession.addOutput(output)
    }

    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        previewLayer?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        view.layer.addSublayer(previewLayer!)
    }

    func startRunningCaptureSession() {
        captureSession.startRunning()
    }

    func swapCamera(isFrontCamera: Bool) {
        captureSession.beginConfiguration()
        //Change camera device inputs from back to front or opposite
        if captureSession.inputs.contains(frontCameraDeviceInput!) == true {
            captureSession.removeInput(frontCameraDeviceInput!)
            captureSession.addInput(backCameraDeviceInput!)
        } else if captureSession.inputs.contains(backCameraDeviceInput!) == true {
            captureSession.removeInput(backCameraDeviceInput!)
            captureSession.addInput(frontCameraDeviceInput!)
        }
        //Commit all the configuration changes at once
        captureSession.commitConfiguration();
    }
}

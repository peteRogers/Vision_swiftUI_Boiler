//
//  CameraViewController.swift
//  vision_swiftUI
//
//  Created by Peter Rogers on 07/12/2022.
//


import UIKit
import AVFoundation
import Vision

final class CameraViewController: UIViewController {
    
    private var cameraView: CameraPreview { view as! CameraPreview }
    
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedOutput",
        qos: .userInteractive
    )
    private var cameraFeedSession: AVCaptureSession?
//    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
//        let request = VNDetectHumanHandPoseRequest()
//        request.maximumHandCount = 2
//        return request
//    }()
    
    private let bodyPoseRequest: VNDetectHumanBodyPoseRequest = {
        let request = VNDetectHumanBodyPoseRequest()
        
        return request
    }()
    
    private let facePoseRequest: VNDetectFaceLandmarksRequest = {
        let request = VNDetectFaceLandmarksRequest()
        
        return request
    }()
    
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    override func loadView() {
        
        view = CameraPreview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession()
               // cameraView.previewLayer.connection?.videoOrientation = .portrait
                cameraView.previewLayer.session = cameraFeedSession
                //cameraView.previewLayer.videoGravity = .resizeAspect
                
            }
            DispatchQueue.global(qos: .userInitiated).async{
                self.cameraFeedSession?.startRunning()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front)
        else {
            throw AppError.captureSessionSetup(
                reason: "Could not find a front facing camera."
            )
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(
            device: videoDevice
        ) else {
            throw AppError.captureSessionSetup(
                reason: "Could not create video device input."
            )
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(
                reason: "Could not add video device input to the session"
            )
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(
                reason: "Could not add video data output to the session"
            )
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func processPoints(_ fingerTips: [CGPoint]) {
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        
        let convertedPoints = fingerTips.map {
            cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        pointsProcessorHandler?(convertedPoints)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    //  func captureOutput(
    //    _ output: AVCaptureOutput,
    //    didOutput sampleBuffer: CMSampleBuffer,
    //    from connection: AVCaptureConnection
    //  ) {
    //    var fingerTips: [CGPoint] = []
    //
    //    defer {
    //      DispatchQueue.main.sync {
    //        self.processPoints(fingerTips)
    //      }
    //    }
    //
    //    let handler = VNImageRequestHandler(
    //      cmSampleBuffer: sampleBuffer,
    //      orientation: .up,
    //      options: [:]
    //    )
    //    do {
    //      // Perform VNDetectHumanHandPoseRequest
    //      try handler.perform([handPoseRequest])
    //
    //      // Continue only when at least a hand was detected in the frame. We're interested in maximum of two hands.
    //      guard
    //        let results = handPoseRequest.results?.prefix(2),
    //        !results.isEmpty
    //      else {
    //        return
    //      }
    //
    //      var recognizedPoints: [VNRecognizedPoint] = []
    //        print(recognizedPoints.description)
    //      try results.forEach { observation in
    //        // Get points for all fingers.
    //        let fingers = try observation.recognizedPoints(.all)
    //
    //        // Look for tip points.
    //        if let thumbTipPoint = fingers[.thumbTip] {
    //          print(thumbTipPoint.x)
    //          recognizedPoints.append(thumbTipPoint)
    //        }
    //        if let indexTipPoint = fingers[.indexTip] {
    //          recognizedPoints.append(indexTipPoint)
    //        }
    //        if let middleTipPoint = fingers[.middleTip] {
    //          recognizedPoints.append(middleTipPoint)
    //        }
    //        if let ringTipPoint = fingers[.ringTip] {
    //          recognizedPoints.append(ringTipPoint)
    //        }
    //        if let littleTipPoint = fingers[.littleTip] {
    //          recognizedPoints.append(littleTipPoint)
    //        }
    //      }
    //
    //      fingerTips = recognizedPoints.filter {
    //        // Ignore low confidence points.
    //        $0.confidence > 0.9
    //      }
    //      .map {
    //        // Convert points from Vision coordinates to AVFoundation coordinates.
    //        CGPoint(x: $0.location.x, y: 1 - $0.location.y)
    //      }
    //    } catch {
    //      cameraFeedSession?.stopRunning()
    //      print(error.localizedDescription)
    //    }
    //  }
    
//    func captureOutput(
//        _ output: AVCaptureOutput,
//        didOutput sampleBuffer: CMSampleBuffer,
//        from connection: AVCaptureConnection
//    ) {
//        var bodyPoints: [CGPoint] = []
//
//        defer {
//            DispatchQueue.main.sync {
//                self.processPoints(bodyPoints)
//            }
//        }
//
//        let handler = VNImageRequestHandler(
//            cmSampleBuffer: sampleBuffer,
//            orientation: .up,
//            options: [:]
//        )
//        do {
//            // Perform VNDetectHumanHandPoseRequest
//            try handler.perform([bodyPoseRequest])
//
//            // Continue only when at least a hand was detected in the frame. We're interested in maximum of two hands.
//            guard
//                let results = bodyPoseRequest.results?.prefix(1),
//                !results.isEmpty
//            else {
//                return
//            }
//
//            var recognizedPoints: [VNRecognizedPoint] = []
//            //print(recognizedPoints.description)
//            try results.forEach { observation in
//                // Get points for all fingers.
//                let bodyPoints = try observation.recognizedPoints(.face)
//
//                // Look for tip points.
//                if let leftShoulder = bodyPoints[.leftEye] {
//                    //print(leftShoulder.x)
//                    recognizedPoints.append(leftShoulder)
//                }
//                if let leftEar = bodyPoints[.leftEar] {
//                    recognizedPoints.append(leftEar)
//                }
//                //          if let middleTipPoint = fingers[.middleTip] {
//                //            recognizedPoints.append(middleTipPoint)
//                //          }
//                //          if let ringTipPoint = fingers[.ringTip] {
//                //            recognizedPoints.append(ringTipPoint)
//                //          }
//                //          if let littleTipPoint = fingers[.littleTip] {
//                //            recognizedPoints.append(littleTipPoint)
//                //          }
//            }
//            print(recognizedPoints)
//
//            bodyPoints = recognizedPoints.filter {
//                // Ignore low confidence points.
//                $0.confidence > 0.5
//
//            }
//            .map {
//                // Convert points from Vision coordinates to AVFoundation coordinates.
//
//                CGPoint(x: $0.location.x, y: 1 - $0.location.y)
//            }
//        } catch {
//            cameraFeedSession?.stopRunning()
//            print(error.localizedDescription)
//        }
//    }
    
   
  
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        var bodyPoints: [CGPoint] = []
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(bodyPoints)
            }
        }
        
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .up,
            options: [:]
        )
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([facePoseRequest])
            
            // Continue only when at least a hand was detected in the frame. We're interested in maximum of two hands.
            guard
                let results = facePoseRequest.results?.prefix(1),
                !results.isEmpty
            else {
                return
            }
            
//            guard let faceDetectionRequest = request as? VNDetectFaceLandmarksRequest,
//                            let results = faceDetectionRequest.results as? [VNFaceObservation] else {
//                                return
//                        }
            if let face = results.first  {
                let affineTransform = CGAffineTransform(translationX: face.boundingBox.origin.x, y: face.boundingBox.origin.y)
                    .scaledBy(x: face.boundingBox.size.width, y: face.boundingBox.size.height)
                var recognizedPoints: [CGPoint] = []
                if let leftEye = face.landmarks?.leftEye{
                    
                   
                    //print(leftShoulder.x)
                    

                    let p = leftEye.normalizedPoints[0].applying(affineTransform)
                    recognizedPoints.append(p)
                }
                bodyPoints = recognizedPoints
                .map {
                    // Convert points from Vision coordinates to AVFoundation coordinates.

                    CGPoint(x: $0.x, y: 1 - $0.y)
                }
            }
        } catch {
            cameraFeedSession?.stopRunning()
            print(error.localizedDescription)
        }
    }
}

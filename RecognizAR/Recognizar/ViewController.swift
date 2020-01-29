//
//  ViewController.swift
//  RecognizAR
//
//  Created by Tanishq Gautam on 11/02/19.
//  Copyright © 2019 Tanishq Gautam. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    

    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        captureSession.addOutput(dataOutput)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model) { ( finishedReq , Error) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            
            print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async { // Correct
                 self.label.text = "\(firstObservation.identifier), \(firstObservation.confidence)"
            }
           
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
        

}


}

//
//  ViewController.swift
//  Raptter
//
//  Created by matsuosh on 2016/09/24.
//  Copyright © 2016年 matsuosh. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class RecordingViewController: UIViewController {

    @IBOutlet weak var recordingButton: UIButton! {
        didSet {
            recordingButton.addTarget(
                self,
                action: #selector(RecordingViewController.recordingButtonTapped(button:)),
                for: .touchUpInside)
        }
    }

    var isRecoding = false
    var output: AVCaptureMovieFileOutput?

    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // AVCaptureSessionを作る。
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        session.addInput({
            let device = AVCaptureDevice.defaultDevice(
                withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                mediaType: AVMediaTypeVideo,
                position: AVCaptureDevicePosition.front)
            return try! AVCaptureDeviceInput(device: device)
            }())
        session.addInput({
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            return try! AVCaptureDeviceInput(device: device)
            }())
        output = AVCaptureMovieFileOutput()
        session.addOutput(output)
        
        // VideoPreviewLayerを作る。
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = view.layer.frame
        view.layer.addSublayer(previewLayer!)
        view.bringSubview(toFront: recordingButton)

        // トラックを読み込む。
        let resource = "coldcut1"
        if let bundle = Bundle.main.path(forResource: resource, ofType: "mp3") {
            let fileURL = URL(fileURLWithPath: bundle)
            audioPlayer = try! AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        }
        session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func recordingButtonTapped(button: UIButton) {
        if !isRecoding {
            isRecoding = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: { 
                self.recordingButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: nil)
            startRecording()
        } else {
//            isRecoding = false
//            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { 
//                self.recordingButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                }, completion: nil)
//            recordingButton.layer.removeAllAnimations()
            stopRecording()
        }
    }

    func startRecording() {
        let fileURL: URL = {
            let filename: String = {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYYMMddHHmmss"
                return formatter.string(from: Date()) + ".mov"
            }()
            return URL(fileURLWithPath: NSTemporaryDirectory() + filename)
        }()
        output?.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)
    }

    func stopRecording() {
        isRecoding = false
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
            self.recordingButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        recordingButton.layer.removeAllAnimations()
        output?.stopRecording()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playMovie" {
            let controller = segue.destination as! MovieViewController
            controller.fileURLs = [sender as! URL]
        }
    }

}

extension RecordingViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("fileURL: \(fileURL)")
        audioPlayer?.play()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error) != nil {
            return
        }
        performSegue(withIdentifier: "playMovie", sender: outputFileURL)
    }

}

extension RecordingViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopRecording()
    }

}

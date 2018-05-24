//
//  ViewController.swift
//  ReplyKitScreenRecordApp
//
//  Created by GLB-311-PC on 17/05/18.
//  Copyright © 2018 Globussoft. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController,RPPreviewViewControllerDelegate {
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var colorPicker: UISegmentedControl!
    @IBOutlet var colorDisplay: UIView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var micToggle: UISwitch!
    let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       recordButton.layer.cornerRadius = 30
    }

    @IBAction func colorChangeSegmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            colorDisplay.backgroundColor = UIColor.red
        case 1:
            colorDisplay.backgroundColor = UIColor.blue
        case 2:
            colorDisplay.backgroundColor = UIColor.green
        case 3:
            colorDisplay.backgroundColor = UIColor.orange
        case 4:
            colorDisplay.backgroundColor = UIColor.purple
        default:
            break
        }
    }
    
    func viewReset(){
        DispatchQueue.main.async {
            self.micToggle.isEnabled = true
            self.statusLabel.text = "Ready to Record"
            self.statusLabel.textColor = UIColor.black
            self.recordButton.backgroundColor = UIColor.green
        }
    }
    
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        
        if !isRecording {
            startRecording()
        }else{
            stopRecording()
        }
    }
  
    func startRecording() {
        guard recorder.isAvailable else {
            print("Recording is not available at this time")
            return
        }
        if micToggle.isOn {
            recorder.isMicrophoneEnabled = true
        }else{
            recorder.isMicrophoneEnabled = false
        }
        
        if #available(iOS 10.0, *) {
            recorder.startRecording{ [unowned self] (error) in
                guard error==nil else{
                    print("There is an error start the recording")
                    return
                }
                print("Started the recording successfully")
                DispatchQueue.main.async {
                    self.micToggle.isEnabled = false
                    self.recordButton.backgroundColor = UIColor.red
                    self.statusLabel.textColor = UIColor.red
                    self.statusLabel.text = "Recording...."
                    self.isRecording=true
                }
  
            }
        } else {
             print("not supported it is accepted for ios 10 and newer")
        }
        
    }
    
    func stopRecording() {
        if #available(iOS 10.0, *) {
            recorder.stopRecording { [unowned self] (preview, error) in
                print("Stop recording")
                guard preview != nil else {
                    print("Preview controller is not available")
                    let alert = UIAlertController(title: "sorry", message:"This video can not Saved!!Please try again later!!" , preferredStyle: .alert)
                    
                    let editAction = UIAlertAction(title: "Okay", style:.default, handler: {(action :UIAlertAction) -> Void in
                       
                    })
                    alert.addAction(editAction)
                    self.present(alert,animated: true,completion: nil)
                    self.isRecording = false
                    self.viewReset()
                    return
            }
                
                let alert = UIAlertController(title: "Recording finished", message:"Would you like to edit or delete your recording?" , preferredStyle: .alert)
                
                let deleteAction = UIAlertAction(title: "Delete", style:.destructive, handler: {(action :UIAlertAction) in
                    self.recorder.discardRecording(handler: {()-> Void in
                        print("Recording successfully deleted")
                    })
                })
                
                let editAction = UIAlertAction(title: "Edit", style:.default, handler: {(action :UIAlertAction) -> Void in
                    preview?.previewControllerDelegate = self
                    self.present(preview!,animated: true,completion: nil)
               })
                
                alert.addAction(editAction)
                alert.addAction(deleteAction)
                self.present(alert,animated: true,completion: nil)
                
                self.isRecording = false
                self.viewReset()
            }
        }else{
            print("not supported it is accepted for ios 10 and newer")
        }
        
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


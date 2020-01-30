//
//  ViewController.swift
//  Microphone
//
//  Created by Jennifer Mah on 1/29/20.
//  Copyright © 2020 Jennifer Mah. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    //instance variables
    let audioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    //audio recording filename constant
    let filename = "audio.m4a"

    var RecButton = UIButton(frame: CGRect(x: 150, y: 300, width: 100, height: 50))
    var stopButton = UIButton(frame: CGRect(x: 150, y: 400, width: 100, height: 50))
    var playButton = UIButton(frame: CGRect(x: 150, y: 500, width: 100, height: 50))
    //Button actions
    
    @objc func RecButtonAction(sender: UIButton!) {
        if let recorder = audioRecorder {
            //check to make sure we aren't already recording
            if recorder.isRecording == false {
                //enable the stop button and start recording
                playButton.isEnabled = false
                stopButton.isEnabled = true
                recorder.delegate = self //allows recorder to respond to errors and complete the recording
                recorder.record()
                print("REACH")
            }
        } else {
            print("No audio recorder instance")
        }
    }

    @objc func playButtonAction(sender: UIButton!) {
        print("play")
      //make sure we aren't recording
      if audioRecorder?.isRecording == false {
          stopButton.isEnabled = true
          RecButton.isEnabled = false
          
          do {
              try audioPlayer = AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
              //set to playback mode for optimal volume
              try audioSession.setCategory(AVAudioSession.Category.playback)
              audioPlayer!.delegate = self
              audioPlayer!.prepareToPlay() // preload audio
              audioPlayer!.play() //plays audio file
            print("PLAY")
          } catch {
              print("audioPlayer error: \(error.localizedDescription)")
          }
      }
    }
    
    @objc func stopButtonAction(sender: UIButton!) {
      stopButton.isEnabled = false
      playButton.isEnabled = true
      RecButton.isEnabled = true
      print("stop")

      //stop recording if that's the current task
      if audioRecorder?.isRecording == true {
          audioRecorder?.stop()
      } else { // stop the playback and reset the audio session mode
          audioPlayer?.stop()
          //reset session mode
          do {
              try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            print("STOP")
          } catch {
              print(error.localizedDescription)
          }
      }
    }


    //audio player delegate method to change buttons when audio finishes playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        RecButton.isEnabled = true
        stopButton.isEnabled = false
        //reset av session mode to optimize recording
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
   override func viewDidLoad() {
      super.viewDidLoad()
    
    //MARK: UI FOR APP
    //Record button
    RecButton.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
    RecButton.setTitle("Record", for: .normal)
    RecButton.addTarget(self, action: #selector(RecButtonAction), for: .touchUpInside)
    self.view.addSubview(RecButton)
    
    //Stop Button
    stopButton.backgroundColor = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    stopButton.setTitle("Stop", for: .normal)
    stopButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
    self.view.addSubview(stopButton)
    
    //Play Button
    playButton.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    playButton.setTitle("Play", for: .normal)
    playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)

    self.view.addSubview(playButton)
    
    //MARK: Other Code in View Did Load
    
    // enable play and stop since we don't have any audio to work with on load
    playButton.isEnabled = false
    stopButton.isEnabled = false
    
    //get path for the audio file
    let dirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docDir = dirPath[0]
    let audioFileURL = docDir.appendingPathComponent(filename)
    print(audioFileURL)
    
    //configure our audioSession
    do {
        try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .init(rawValue: 1))
    } catch {
        print("audio session error: \(error.localizedDescription)")
    }
    
    //declare our settings in a dictionary
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // audio codec
        AVSampleRateKey: 1200, //sample rate in hZ
        AVNumberOfChannelsKey: 1, //num of channels
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // audio bit rate
    ]
    
    do{
        //create our recorder instance
        audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
        //get it ready for recording by creating the audio file at the specified location
        audioRecorder?.prepareToRecord()
        print("Audio recorder ready!")
    }catch {
        print("Audio recorder error: \(error.localizedDescription)")
    }
    

    }
    

}


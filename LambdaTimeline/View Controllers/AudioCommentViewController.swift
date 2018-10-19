//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Carolyn Lea on 10/16/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentViewController: UIViewController, AVAudioPlayerDelegate
{
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    var postController: PostController!
    var post: Post!
    
    private var playTimeTimer: Timer?
    {
        willSet
        {
            playTimeTimer?.invalidate()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func dismissView(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveRecording(_ sender: Any)
    {
        if post != nil 
        {
           postController.addAudioComment(with: newRecordingURL(), to: &post)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playRecording(_ sender: Any)
    {
        let isPlaying = player?.isPlaying ?? false
        
        if isPlaying
        {
            player?.pause()
            playTimeTimer = nil
        }
        else
        {
            player?.play()
            startPollingPlayTime()
        }
        updateViews()
    }
    
    @IBAction func startStopRecording(_ sender: Any)
    {
        let isRecording = recorder?.isRecording ?? false
        if isRecording
        {
            recorder?.stop()
            if let url = recorder?.url {
                player = try! AVAudioPlayer(contentsOf: url)
                player?.delegate = self
            }
        }
        else
        {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
            recorder = try! AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.record()
        }
        updateViews()
    }
    
    private func newRecordingURL() -> URL
    {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print(documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf"))
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    @IBAction func sliderChanged(_ sender: Any)
    {
        let duration = player?.duration ?? 0
        let sliderTime = TimeInterval(timeSlider.value) * duration
        player?.currentTime = sliderTime
    }
    
    private func updateViews()
    {
        guard isViewLoaded else {return}
        let isPlaying = player?.isPlaying ?? false
        let playButtonTitle = isPlaying ? "Pause" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
        
        let isRecording = recorder?.isRecording ?? false
        let recordButtonTitle = isRecording ? "Stop" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
        
        let currentTime = player?.currentTime ?? 0
        let duration = player?.duration ?? 0
        timerLabel.text = String(currentTime)
        timeSlider.value = Float (currentTime / duration)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        updateViews()
        playTimeTimer = nil
    }
    
    private func startPollingPlayTime()
    {
        playTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] (timer) in
            
            self?.updateViews()
            
        }
    }
    
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
}

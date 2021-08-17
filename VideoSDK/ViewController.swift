//
//  ViewController.swift
//  mediasoup-ios-cient-sample
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//

import Foundation
import UIKit
import WebRTC
import SwiftyJSON



func random(digits:Int) -> String {
    var number = String()
    for _ in 1...digits {
        number += "\(Int.random(in: 1...9))"
    }
    return number
}

func getGenerateRandomId() -> Int{
    return Int(random(digits: 6)) ?? 0
}

class ViewController : UIViewController, GetCosumerVideoTrack {
    
    
    private var socket: EchoSocket?
    private var client: RoomClient?
    @IBOutlet var localVideoView: RTCEAGLVideoView!
    @IBOutlet var remoteVideoView: RTCEAGLVideoView!
    @IBOutlet var resumeLocalButton: UIButton!
    @IBOutlet var pauseLocalButton: UIButton!
    @IBOutlet var pauseRemoteButton: UIButton!
    @IBOutlet var resumeRemoteButton: UIButton!
    
    private var delegate: RoomListener?
    var roomId = "cqtg-dgun-on1a"
    var meeting : Meeting?
    
    override func viewDidLoad() {
        print("viewDidLoad()")
        // Prioritize the local video to the front
        self.view.sendSubviewToBack(self.remoteVideoView)
        remoteVideoView.contentMode = .scaleAspectFit
        localVideoView.contentMode = .scaleAspectFit
        // Handle buttons
        self.pauseLocalButton.addTarget(self, action: #selector(closeLocalAudioStream), for: .touchUpInside)
        self.pauseRemoteButton.addTarget(self, action: #selector(closeLocalVideoStream), for: .touchUpInside)
        //        self.pauseLocalButton.addTarget(self, action: #selector(pauseLocalStream), for: .touchUpInside)
        //        self.resumeLocalButton.addTarget(self, action: #selector(resumeLocalStream), for: .touchUpInside)
        self.resumeLocalButton.addTarget(self, action: #selector(startAudio), for: .touchUpInside)
        
        //        self.pauseRemoteButton.addTarget(self, action: #selector(pauseRemoteStream), for: .touchUpInside)
        //        self.resumeRemoteButton.addTarget(self, action: #selector(resumeRemoteStream), for: .touchUpInside)
        self.resumeRemoteButton.addTarget(self, action: #selector(startVideo), for: .touchUpInside)
        
                AVCaptureDevice.requestAccess(for: .video) { granted in
                            if granted {
//                                self.connectWebSocket()
                            }
                }
        
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                        // Handle granted
        
                    })
//        self.connectWebSocket()
        
        let zujosdk = ZujoSdk(token:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIxMmQyNWZjZS0xZDY4LTRiZWItOWU0ZC0yMThmZWUzOWU0NDkiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIiwiYWxsb3dfbW9kIl0sImlhdCI6MTYyODg4NjA4MSwiZXhwIjoxNjI4ODg2NjgxfQ.jYwNNMN96AnBTV5_4_5tLd-zn-6AtWznfMlpRSL6ffw", delegate: self)
        meeting = zujosdk.initializeMeeting(meetingId: roomId, micEnabled: true, webcamEnabled: true)
        meeting!.join()
        
    }
    
    func getConsumerVideoTrack(videoTrack: RTCVideoTrack) {
        videoTrack.add(self.remoteVideoView)
    }
    
    func getProducerVideoTrack(videoTrack: RTCVideoTrack) {
        videoTrack.add(self.localVideoView)
    }
    
    // Get rid of the top status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnClose_Click(_ sender: Any) {
//        self.client?.close()
        meeting?.leave()
    }
    
    
    @objc private func pauseLocalStream() {
        self.pauseLocalVideo()
        self.pauseLocalAudio()
    }
    
    @objc private func resumeLocalStream() {
        self.resumeLocalVideo()
        self.resumeLocalAudio()
    }
    
    @objc private func startLocalVideo() {
        self.startVideo()
        
    }
    
    @objc private func pauseRemoteStream() {
        self.pauseRemoteVideo()
        self.pauseRemoteAudio()
    }
    
    @objc private func resumeRemoteStream() {
        self.resumeRemoteVideo()
        self.resumeRemoteAudio()
    }
    
    
    // Close local audio
    @objc private func closeLocalAudioStream() {
        self.closeLocalAudio()
    }
    
    // Close local video
    @objc private func closeLocalVideoStream() {
        self.closeLocalVideo()
    }
    
    private func pauseLocalVideo() {
        do {
            try self.client?.pauseLocalVideo()
        } catch {
            print("Failed to pause local video")
        }
    }
    
    private func resumeLocalVideo() {
        meeting?.enableWebcam()
//        meeting?.startVideo()
//        do {
//            try self.client?.resumeLocalVideo()
//        } catch {
//            print("Failed to resume local video")
//        }
    }
    
    
    private func closeLocalVideo() {
        meeting?.disableWebcam()
//        do {
//            try self.client?.closeLocalVideo()
//        } catch {
//            print("Failed to close local video")
//        }
    }
    
    private func pauseLocalAudio() {
        do {
            try self.client?.pauseLocalAudio()
        } catch {
            print("Failed to pause local audio")
        }
    }
    
    private func resumeLocalAudio() {
        meeting?.unmuteMic()
//        do {
//            try self.client?.resumeLocalAudio()
//        } catch {
//            print("Failed to resume local audio")
//        }
    }
    
    private func closeLocalAudio() {
        meeting?.muteMic()
//        do {
//            try self.client?.closeLocalAudio()
//        } catch {
//            print("Failed to close local audio")
//        }
    }
    
    private func pauseRemoteVideo() {
        do {
            try self.client?.pauseRemoteVideo()
        } catch {
            print("Failed to pause remote video")
        }
    }
    
    private func resumeRemoteVideo() {
        do {
            try self.client?.resumeRemoteVideo()
        } catch {
            print("Failed to resume remote video")
        }
    }
    
    private func pauseRemoteAudio() {
        do {
            try self.client?.pauseRemoteAudio()
        } catch {
            print("Failed to pause remote audio")
        }
    }
    
    private func resumeRemoteAudio() {
        do {
            try self.client?.resumeRemoteAudio()
        } catch {
            print("Failed to resume remote audio")
        }
    }
    
    private func connectWebSocket() {
        self.socket = EchoSocket.init();
        self.socket?.register(observer: self)
        
        let uuid = UUID().uuidString
        
        wss://call-api.zujonow.com/?roomId=cqtg-dgun-on1a&peerId=gzfrirbf&secret=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIxYTgyNjA2YS02MjcyLTQzZWItODZiYy0xYjE1OWM1ZDE2MWIiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sIm1lZXRpbmdJZCI6ImNxdGctZGd1bi1vbjFhIiwiaWF0IjoxNjI4Nzc0MTQ1LCJleHAiOjE2Mjg3OTU3NDV9.d3Ga00WuJfDboJ_XcWSpcROrU59rzY-sjeDfoEkcoTo
        
        do {
            try self.socket!.connect(wsUri: "wss://call-api.zujonow.com/?roomId=\(roomId)&peerId=gzfrirbf&secret=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIxYTgyNjA2YS02MjcyLTQzZWItODZiYy0xYjE1OWM1ZDE2MWIiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sIm1lZXRpbmdJZCI6ImNxdGctZGd1bi1vbjFhIiwiaWF0IjoxNjI4ODU1MjkwLCJleHAiOjE2Mjg4NzY4OTB9.mzYfhCDI5aKC1hUc3fJFN_g_9nTwOOf9IqoxCoYa2Ds")
        } catch {
            print("Failed to connect to server")
        }
    }
    
    private func handleWebSocketConnected() {
        // Initialize mediasoup client
        self.initializeMediasoup()
        
        // Get router rtp capabilities
        let getRoomRtpCapabilitiesResponse: JSON = Request.shared.sendGetRoomRtpCapabilitiesRequest(socket: self.socket!, roomId: roomId)
        print("response! " + getRoomRtpCapabilitiesResponse.description)
        let roomRtpCapabilities: JSON = getRoomRtpCapabilitiesResponse["data"]
        print("roomRtpCapabilities " + roomRtpCapabilities.description)
        
        
        
        let device: MediasoupDevice = MediasoupDevice.init()
        
        //        var dic = loadIntroJsonFile()
        device.load(roomRtpCapabilities.description)
        //        let encoder = JSONEncoder()
        //        if let jsonData = try? JSONSerialization.data(withJSONObject: dic!, options: [])  {
        //            if let str = String(data: jsonData, encoding: .utf8){
        //                device.load(str)
        //            }
        //        }
        
        
        print("handleWebSocketConnected() device loaded")
        
        self.delegate = self
        self.client = RoomClient.init(socket: self.socket!, device: device, roomId: roomId, roomListener: self.delegate!)
        
        
        
        // Create recv webrtcTransport
        self.client!.createRecvTransport()
        // Create send webrtcTransport
        self.client!.createSendTransport()
        
        // Join the room
        do {
            try self.client!.join()
        } catch {
            print("failed to join room")
            return
        }
        
        // Start media capture/sending
        self.displayLocalVideo()
    }
    
    //Load json file
    func loadIntroJsonFile() -> [String:Any]?{
        
        if let jsonResult = loadJsonFile("Resp") as?  [String:Any], jsonResult.count > 0{
            return jsonResult
        }
        
        return nil
    }
    
    func loadJsonFile(_ fileName : String) -> Any?{
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let result = jsonResult as? [[String:Any]], result.count > 0{
                    
                    return result
                }
                
                if let result = jsonResult as? [String:Any], result.count > 0{
                    
                    return result
                }
                
                return nil
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    private func initializeMediasoup() {
        Mediasoupclient.init()
        //        Mediasoupclient.initializePC()
        print("initializeMediasoup() client initialized")
        
        // Set mediasoup log
//        Logger.setLogLevel(LogLevel.WARN)
//        Logger.setDefaultHandler()
    }
    
    private func displayLocalVideo() {
        self.checkDevicePermissions()
    }
    
    private func checkDevicePermissions() {
        // Camera permission
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (isGranted: Bool) in
                self.startVideo()
            })
        } else {
            self.startVideo()
        }
        
        // Mic permission
        if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (isGranted: Bool) in
                self.startAudio()
            })
        }
    }
    
    @objc private func startVideo() {
        meeting?.startVideo()
    }
    
    @objc private func startAudio() {
        meeting?.startAudio()
    }
}

extension ViewController : MessageObserver {
    func on(event: String, data: JSON?) {
        switch event {
        case ActionEvent.OPEN:
            print("socket connected")
            self.handleWebSocketConnected()
            break
        case ActionEvent.NEW_USER:
            print("NEW_USER id =" + data!["userId"]["userId"].stringValue)
            break
        case ActionEvent.NEW_CONSUMER:
            print("NEW_CONSUMER data=" + data!.description)
            self.handleNewConsumerEvent(consumerInfo: data!["data"],requestId: data!["id"].stringValue ?? "")
            break
        default:
            print("Unknown event " + event)
        }
    }
    
    private func handleNewConsumerEvent(consumerInfo: JSON,requestId : String) {
        print("handleNewConsumerEvent info = " + consumerInfo.description)
        // Start consuming
        self.client!.consumeTrack(consumerInfo: consumerInfo,requestId : requestId)
    }
}

// Extension for RoomListener
extension ViewController : RoomListener {
    func onNewConsumer(consumer: Consumer) {
        print("RoomListener::onNewConsumer kind=" + consumer.getKind())
        
        if consumer.getKind() == "video" {
            let videoTrack: RTCVideoTrack = consumer.getTrack() as! RTCVideoTrack
            videoTrack.isEnabled = true
            videoTrack.add(self.remoteVideoView)
        }
        
        //        do {
        //            consumer.getKind() == "video"
        //                ? try self.client!.resumeRemoteVideo()
        //                : try self.client!.resumeRemoteAudio()
        //        } catch {
        //            print("onNewConsumer() failed to resume remote track")
        //        }
        //
        
    }
}

//
//  Meeting.swift
//  VideoSDKDemo
//
//  Created by Jecky Modi on 13/08/21.
//

import Foundation
import SwiftyJSON

//MARK: Meeing class
class Meeting{
    private var client: RoomClient?
    private var socket: EchoSocket?
    
    private var accessToken = String()
    private var meetingId = String()
    private var participantName = String()
    private var micEnabled = true
    private var webcamEnabled = true
    private var delegate: RoomListener?
    
    var videoTrackDelegate : GetCosumerVideoTrack?
    
    init() {
        
    }
    
    init(meetingId : String, participantName : String? = nil, micEnabled : Bool, webcamEnabled : Bool, accessToken : String) {
        self.meetingId = meetingId
        self.participantName = participantName ?? ""
        self.micEnabled = micEnabled
        self.webcamEnabled = webcamEnabled
        self.accessToken = accessToken
    }
    
    private func connectWebSocket() {
        self.socket = EchoSocket.init();
        self.socket?.register(observer: self)
        
        do {
            try self.socket!.connect(wsUri: "\(Constants.baseUrl)?roomId=\(meetingId)&peerId=\(getAutoGeneratesPeerId())&secret=\(self.accessToken)")
        } catch {
            print("Failed to connect to server")
        }
    }
    
    func join(){
        self.connectWebSocket()
    }
    
    func leave(){
        self.client?.close()
    }
    
    func startAudio() {
        do {
            try self.client!.produceAudio()
        } catch {
            print("failed to start audio")
        }
    }
    
    func startVideo(){
        do {
            let videoTrack: RTCVideoTrack = try self.client!.produceVideo()!
            videoTrackDelegate?.getProducerVideoTrack(videoTrack: videoTrack)
            
        } catch {
            print("failed to start video!")
        }
    }
    
    func disableWebcam(){
        do {
            try self.client?.closeLocalVideo()
        } catch {
            print("Failed to pause remote video")
        }
    }
    
    func enableWebcam(){
        do {
            try self.client?.resumeLocalVideo()
        } catch {
            print("Failed to pause remote video")
        }
    }
    
    func muteMic(){
        do {
            try self.client?.closeLocalAudio()
        } catch {
            print("Failed to pause remote audio")
        }
    }

    func unmuteMic(){
        do {
            try self.client?.resumeRemoteAudio()
        } catch {
            print("Failed to pause remote audio")
        }
    }
    
    private func getAutoGeneratesPeerId() -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<8).map{ _ in letters.randomElement()! })
    }
    
    private func getGenerateRandomId() -> Int{
        
        var number = String()
        for _ in 1...6 {
           number += "\(Int.random(in: 1...9))"
        }
        
        return Int(number) ?? 0
    }
    
    private func handleWebSocketConnected() {
        // Initialize mediasoup client
        self.initializeMediasoup()
        
        // Get router rtp capabilities
        let getRoomRtpCapabilitiesResponse: JSON = Request.shared.sendGetRoomRtpCapabilitiesRequest(socket: self.socket!, roomId: self.meetingId)
        let roomRtpCapabilities: JSON = getRoomRtpCapabilitiesResponse["data"]
        
        let device: MediasoupDevice = MediasoupDevice.init()
        device.load(roomRtpCapabilities.description)
            
        self.delegate = self
        self.client = RoomClient.init(socket: self.socket!, device: device, roomId: self.meetingId, roomListener: self.delegate!)
        
        self.client!.createRecvTransport()
        self.client!.createSendTransport()
        
        // Join the room
        do {
            try self.client!.join()
        } catch {
            print("failed to join room")
            return
        }
        
        if webcamEnabled{
            //Display local video
            checkDevicePermissions()
        }
    }
    
    private func checkDevicePermissions() {
        // Camera permission
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (isGranted: Bool) in
                self.startVideo()
            })
        }else{
            self.startVideo()
        }
        
        // Mic permission
        if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (isGranted: Bool) in
                self.startAudio()
            })
        }else{
            self.startAudio()
        }
    }
    
    private func initializeMediasoup() {
        _ = Mediasoupclient.init()
        
        // Set mediasoup log
        Logger.setLogLevel(LogLevel.WARN)
        Logger.setDefaultHandler()
    }
}

//MARK: Socket obeserver
extension Meeting : MessageObserver{
    
    //Socket event
    internal func on(event: String, data: JSON?) {
        switch event {
        case ActionEvent.OPEN:
            self.handleWebSocketConnected()
            break
        case ActionEvent.NEW_USER:
            print("NEW_USER id =" + data!["userId"]["userId"].stringValue)
            break
        case ActionEvent.NEW_CONSUMER:
            self.handleNewConsumerEvent(consumerInfo: data!["data"],requestId: data!["id"].stringValue)
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


//MARK: Room event listener
extension Meeting : RoomListener {
    internal func onNewConsumer(consumer: Consumer) {

        if consumer.getKind() == "video" {
            let videoTrack: RTCVideoTrack = consumer.getTrack() as! RTCVideoTrack
            videoTrack.isEnabled = true
            videoTrackDelegate?.getConsumerVideoTrack(videoTrack: videoTrack)
        }
    }
}

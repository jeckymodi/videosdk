//
//  MediaCapturer.swift
//  mediasoup-ios-cient-sample
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//

import Foundation
//import WebRTC
//import WebRTC
//import mediasoup_client_ios

public enum MediaError : Error {
    case CAMERA_DEVICE_NOT_FOUND
}

final internal class MediaCapturer : NSObject {
    private static let MEDIA_STREAM_ID: String = "ARDAMS"
    private static let VIDEO_TRACK_ID: String = "ARDAMSv0"
    private static let AUDIO_TRACK_ID: String = "ARDAMSa0"
    
    private let peerConnectionFactory: RTCPeerConnectionFactory
    private let mediaStream: RTCMediaStream
    
    private var videoCapturer: RTCCameraVideoCapturer?
    private var videoSource: RTCVideoSource?
    
    internal static let shared = MediaCapturer.init();
    
    private override init() {
        self.peerConnectionFactory = RTCPeerConnectionFactory.init();
        self.mediaStream = self.peerConnectionFactory.mediaStream(withStreamId: MediaCapturer.MEDIA_STREAM_ID)
    }
    
    internal func createVideoTrack() throws -> RTCVideoTrack {
        // Get the front camera for now
        var devices: [AVCaptureDevice]
        
        // If using iOS 10.2 or above use the new API
        if #available(iOS 10.2, *) {
            devices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices;
        } else {
            // Older than iOS 10.1
            devices = AVCaptureDevice.devices().filter({ $0.position == .front });
        }
        print("createVideoTrack() got device count = " + devices.count.description)
        
        // throw an error if there are no devices
        if (devices.count == 0) {
            throw MediaError.CAMERA_DEVICE_NOT_FOUND;
        }
        print("createVideoTrack() use device " + devices[0].description)
        
        // if there is a device start capturing it
        self.videoCapturer = RTCCameraVideoCapturer.init();
        self.videoCapturer!.delegate = self
        self.videoCapturer!.startCapture(with: devices[0], format: devices[0].activeFormat, fps: 30);
        self.videoSource = self.peerConnectionFactory.videoSource();
        self.videoSource!.adaptOutputFormat(toWidth: 640, height: 480, fps: 30);
        
        let videoTrack: RTCVideoTrack = self.peerConnectionFactory.videoTrack(with: self.videoSource!, trackId: MediaCapturer.VIDEO_TRACK_ID)
        self.mediaStream.addVideoTrack(videoTrack)
        
        videoTrack.isEnabled = true
        
//        videoTrack.add(videoView)
        
        return videoTrack
    }
    
    internal func createAudioTrack() -> RTCAudioTrack {
        let audioTrack: RTCAudioTrack = self.peerConnectionFactory.audioTrack(withTrackId: MediaCapturer.AUDIO_TRACK_ID)
        audioTrack.isEnabled = true
        self.mediaStream.addAudioTrack(audioTrack)
        
        return audioTrack
    }
}

extension MediaCapturer : RTCVideoCapturerDelegate {
    func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        self.videoSource?.capturer(capturer, didCapture: frame)
    }
}

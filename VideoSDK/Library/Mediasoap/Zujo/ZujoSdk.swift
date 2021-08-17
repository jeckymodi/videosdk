//
//  GetInputs.swift
//  Connectivity
//
//  Created by Jecky Modi on 13/08/21.
//

import Foundation
import SwiftyJSON

protocol GetCosumerVideoTrack{
    func getConsumerVideoTrack(videoTrack : RTCVideoTrack)
    func getProducerVideoTrack(videoTrack : RTCVideoTrack)
}


class ZujoSdk {
    
    var accessToken = String()
    var delegate : GetCosumerVideoTrack?
    
    init() {
    }
    
    init(token : String, delegate : GetCosumerVideoTrack) {
        self.accessToken = token
        self.delegate = delegate
    }
    
    func initializeMeeting(meetingId : String, participantName : String? = nil, micEnabled : Bool, webcamEnabled : Bool) -> Meeting{
        
        let meeting = Meeting(meetingId: meetingId, micEnabled: micEnabled, webcamEnabled: webcamEnabled, accessToken : accessToken)
        meeting.videoTrackDelegate = self.delegate
        return meeting
    }
}



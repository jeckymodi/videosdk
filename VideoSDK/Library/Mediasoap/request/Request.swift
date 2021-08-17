//
//  Request.swift
//  mediasoup-ios-cient-sample
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//

import Foundation
import SwiftyJSON

final internal class Request : NSObject {
    internal static let REQUEST_TIMEOUT_MS: NSInteger = 3000;
    
    internal static let shared = Request.init();
    
    private override init() {}
    
    // Send getRoomRtpCapabilitiesRequest
    func sendGetRoomRtpCapabilitiesRequest(socket: EchoSocket, roomId: String) -> JSON {
        let getRoomRtpCapabilitiesRequest: JSON = [
            "method": "getRouterRtpCapabilities",
            "roomId": roomId,
            "request": true,
            "id": getGenerateRandomId(),
            "data" : [:]
        ]
        
        return Request.shared.sendSocketAckRequest(socket: socket, data: getRoomRtpCapabilitiesRequest)
    }
    
    // Send getRoomRtpCapabilitiesRequest
    func sendAccept(socket: EchoSocket, requestId: String)  {
        let getRoomRtpCapabilitiesRequest: JSON = [
            "ok": true,
            "response": true,
            "id": Int(requestId) ?? 0,
            "data" : [:]
        ]
        
        socket.send(message: getRoomRtpCapabilitiesRequest)
//        return Request.shared.sendSocketAckRequest(socket: socket, data: getRoomRtpCapabilitiesRequest)
    }
    
    
    func sendLoginRoomRequest(socket: EchoSocket, roomId: String, deviceRtpCapabilities: String) -> JSON {
        let loginRoomRequest: JSON = [
            "method": ActionEvent.LOGIN_ROOM,
            "roomId": roomId,
            "request": true,
            "id": getGenerateRandomId(),
            "data" : ["displayName" : "ios","device" : "ios","secret" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIxYTgyNjA2YS02MjcyLTQzZWItODZiYy0xYjE1OWM1ZDE2MWIiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sIm1lZXRpbmdJZCI6ImNxdGctZGd1bi1vbjFhIiwiaWF0IjoxNjI4ODU1MjkwLCJleHAiOjE2Mjg4NzY4OTB9.mzYfhCDI5aKC1hUc3fJFN_g_9nTwOOf9IqoxCoYa2Ds","rtpCapabilities": JSON.init(parseJSON: deviceRtpCapabilities),
//                      "sctpCapabilities" : "" //For chat and data channenl
            ],
            
        ]
        
        return Request.shared.sendSocketAckRequest(socket: socket, data: loginRoomRequest)
    }
    
    func sendCreateWebRtcTransportRequest(socket: EchoSocket, roomId: String, direction: String) -> JSON {
        let createWebRtcTransportRequest: JSON = [
            "method": ActionEvent.CREATE_WEBRTC_TRANSPORT,
            "roomId": roomId,
            "request": true,
            "data" : [ "forceTcp" : false,
                       "producing" : direction == "send" ? true : false,
                       "consuming" : direction == "send" ? false :true],
//            "sctpCapabilities" : nil For Chat and data channel
            "id" : getGenerateRandomId(),
//            "direction": direction
        ]
        
        return Request.shared.sendSocketAckRequest(socket: socket, data: createWebRtcTransportRequest)
    }
    
    func sendConnectWebRtcTransportRequest(socket: EchoSocket, roomId: String, transportId: String, dtlsParameters: String) {
        let connectWebRtcTransportRequest: JSON = [
            "method": ActionEvent.CONNECT_WEBRTC_TRANSPORT,
            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["transportId": transportId, "dtlsParameters": JSON.init(parseJSON: dtlsParameters)],
        ]
        
        socket.send(message: connectWebRtcTransportRequest)
    }
    
    func sendProduceWebRtcTransportRequest(socket: EchoSocket, roomId: String, transportId: String, kind: String, rtpParameters: String) -> JSON {
        let produceWebRtcTransportRequest: JSON = [
            "method": ActionEvent.PRODUCE,
            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["transportId": transportId,
                      "kind": kind,
                      "rtpParameters": JSON.init(parseJSON: rtpParameters)]
            
        ]
        
        return Request.shared.sendSocketAckRequest(socket: socket, data: produceWebRtcTransportRequest)
    }
    
    func sendPauseProducerRequest(socket: EchoSocket, roomId: String, producerId: String) {
        let pauseProducerRequest: JSON = [
            "method": ActionEvent.PAUSE_PRODUCER,
//            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["producerId": producerId]
        ]
        
        socket.send(message: pauseProducerRequest)
    }
    
    func sendCloseProducerRequest(socket: EchoSocket, roomId: String, producerId: String) {
        let pauseProducerRequest: JSON = [
            "method": ActionEvent.CLOSE_PRODUCER,
//            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["producerId": producerId]
        ]
        
        
        
        socket.send(message: pauseProducerRequest)
    }
    
    func sendResumeProducerRequest(socket: EchoSocket, roomId: String, producerId: String) {
        let resumeProducerRequest: JSON = [
            "method": ActionEvent.RESUME_PRODUCER,
//            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["producerId": producerId]
        ]
        
        socket.send(message: resumeProducerRequest)
    }
    
    func sendPauseConsumerRequest(socket: EchoSocket, roomId: String, consumerId: String) {
        let pauseConsumerRequest: JSON = [
            "method": ActionEvent.PAUSE_CONSUMER,
//            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["consumerId": consumerId]
        ]
        
        socket.send(message: pauseConsumerRequest)
    }
    
    func sendResumeConsumerRequest(socket: EchoSocket, roomId: String, consumerId: String) {
        let resumeConsumerRequest: JSON = [
            "method": ActionEvent.RESUME_CONSUMER,
//            "roomId": roomId,
            "request": true,
            "id" : getGenerateRandomId(),
            "data" : ["consumerId": consumerId]
        ]
        
        socket.send(message: resumeConsumerRequest)
    }
    
    func sendRtcStatsReport(socket: EchoSocket, roomId: String, rtcStatsReport: String) {
        let rtcStatsReportRequest: JSON = [
            "action": ActionEvent.RTC_STATS,
            "roomId": roomId,
            "rtcStatsReport": rtcStatsReport
        ]
        
        socket.send(message: rtcStatsReportRequest)
    }
    
    private func sendSocketAckRequest(socket: EchoSocket, data: JSON) -> JSON {
        let semaphore: DispatchSemaphore = DispatchSemaphore.init(value: 0)
        
        var response: JSON?
        
        let queue: DispatchQueue = DispatchQueue.global()
        queue.async {
            socket.sendWithAck(message: data, completionHandler: {(res: JSON) in
                response = res
                semaphore.signal()
            })
        }
        
        _ = semaphore.wait(timeout: .now() + 10.0)
        
        return response ?? [:]
    }
}

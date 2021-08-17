//
//  RoomClient.swift
//  mediasoup-ios-cient-sample
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum RoomError : Error {
    case DEVICE_NOT_LOADED
    case SEND_TRANSPORT_NOT_CREATED
    case RECV_TRANSPORT_NOT_CREATED
    case DEVICE_CANNOT_PRODUCE_VIDEO
    case DEVICE_CANNOT_PRODUCE_AUDIO
    case PRODUCER_NOT_FOUND
    case CONSUMER_NOT_FOUND
}

final internal class RoomClient : NSObject {
    private static let STATS_INTERVAL_MS: NSInteger = 3000
    
    private let socket: EchoSocket
    private let roomId: String
    private let mediaCapturer: MediaCapturer
    private var producers: [String : Producer]
    private var consumers: [String : Consumer]
    private var consumersInfo: [JSON]
    private let device: MediasoupDevice
    
    private var joined: Bool
    private var sendTransport: SendTransport?
    private var recvTransport: RecvTransport?
    
    private var sendTransportHandler: SendTransportHandler?
    private var recvTransportHandler: RecvTransportHandler?
    private var producerHandler: ProducerHandler?
    private var consumerHandler: ConsumerHandler?
    
    private var roomListener: RoomListener?
    
    public init(socket: EchoSocket, device: MediasoupDevice, roomId: String, roomListener: RoomListener) {
        self.socket = socket
        self.device = device
        self.roomId = roomId
        self.roomListener = roomListener
        
        self.mediaCapturer = MediaCapturer.shared
        self.producers = [String : Producer]()
        self.consumers = [String : Consumer]()
        self.consumersInfo = [JSON]()
        self.joined = false
        
        super.init()
    }
    
    func join() throws {
        // Check if the device is loaded
        if !self.device.isLoaded() {
            throw RoomError.DEVICE_NOT_LOADED
        }
        
        // if the user is already joined do nothing
        if self.joined {
            return
        }
        
        _ = Request.shared.sendLoginRoomRequest(socket: self.socket, roomId: self.roomId, deviceRtpCapabilities: self.device.getRtpCapabilities())
        self.joined = true
        
        print("join() join success")
    }
    
    func close() {
        
        joined = false
        socket.disconnect()
//        sendTransport?.close()
//        recvTransport?.close()
    }
    
    func createSendTransport() {
        // Do nothing if send transport is already created
        if (self.sendTransport != nil) {
            print("createSendTransport() send transport is already created...")
            return
        }
        
        self.createWebRtcTransport(direction: "send")
        print("createSendTransport() send transport created")
    }
    
    func createRecvTransport() {
        // Do nothing if recv transport is already created
        if (self.recvTransport != nil) {
            print("createRecvTransport() recv transport is already created...")
            return
        }
        
        self.createWebRtcTransport(direction: "recv")
        print("createRecvTransport() recv transport created")
    }
    
    func produceVideo() throws -> RTCVideoTrack? {
        if self.sendTransport == nil {
            print("trasnport nil")
            throw RoomError.SEND_TRANSPORT_NOT_CREATED
        }
        
        if !self.device.canProduce("video") {
            print("cannot produce")
            throw RoomError.DEVICE_CANNOT_PRODUCE_VIDEO
        }
        
        do {
            let videoTrack: RTCVideoTrack = try self.mediaCapturer.createVideoTrack()
            
            let codecOptions: JSON = [
                "videoGoogleStartBitrate": 1000
            ]

            var encodings: Array = Array<RTCRtpEncodingParameters>.init()
            encodings.append(RTCUtils.genRtpEncodingParameters(true, maxBitrateBps: 500000, minBitrateBps: 0, maxFramerate: 60, numTemporalLayers: 0, scaleResolutionDownBy: 0))
            encodings.append(RTCUtils.genRtpEncodingParameters(true, maxBitrateBps: 1000000, minBitrateBps: 0, maxFramerate: 60, numTemporalLayers: 0, scaleResolutionDownBy: 0))
            encodings.append(RTCUtils.genRtpEncodingParameters(true, maxBitrateBps: 1500000, minBitrateBps: 0, maxFramerate: 60, numTemporalLayers: 0, scaleResolutionDownBy: 0))
            
            // TODO: encodings diesn't work with m79 branch?
            self.createProducer(track: videoTrack, codecOptions: codecOptions.description, encodings: nil)
            
            return videoTrack
        } catch {
            print("failed to create video track")
            return nil
        }
    }
    
    func produceAudio() throws {
        if self.sendTransport == nil {
            throw RoomError.SEND_TRANSPORT_NOT_CREATED
        }
        
        if !self.device.canProduce("audio") {
            throw RoomError.DEVICE_CANNOT_PRODUCE_AUDIO
        }
        
        let audioTrack: RTCAudioTrack = self.mediaCapturer.createAudioTrack()
        self.createProducer(track: audioTrack, codecOptions: nil, encodings: nil)
    }
    
    func pauseLocalVideo() throws {
        print("pauseLocalVideo()")
        let producer: Producer = try self.getProducerByKind(kind: "video")
        Request.shared.sendPauseProducerRequest(socket: self.socket, roomId: self.roomId, producerId: producer.getId())
    }
    
    func resumeLocalVideo() throws {
        print("resumeLocalVideo()")
        let producer: Producer = try self.getProducerByKind(kind: "video")
        Request.shared.sendResumeProducerRequest(socket: self.socket, roomId: self.roomId, producerId: producer.getId())
    }
    
    func closeLocalVideo() throws {
        print("closeLocalVideo()")
        let producer: Producer = try self.getProducerByKind(kind: "video")
//        producer.close()
        Request.shared.sendCloseProducerRequest(socket: self.socket, roomId: self.roomId, producerId: producer.getId())
        
        self.producers.removeValue(forKey: producer.getId())
    }
    
    func pauseLocalAudio() throws {
        print("pauseLocalAudio()")
        let producer: Producer = try self.getProducerByKind(kind: "audio")
        Request.shared.sendPauseProducerRequest(socket: self.socket, roomId: self.roomId, producerId: producer.getId())
    }
    
    func resumeLocalAudio() throws {
        print("resumeLocalAudio()")
        let producer: Producer = try self.getProducerByKind(kind: "audio")
        Request.shared.sendResumeProducerRequest(socket: self.socket, roomId: self.roomId, producerId: producer.getId())
    }
    
    func closeLocalAudio() throws {
        print("closeLocalAudio()")
        let producer: Producer = try self.getProducerByKind(kind: "audio")
//        if !producer.isClosed() {
//            producer.close()
//        }
        
        Request.shared.sendCloseProducerRequest(socket: self.socket, roomId: self.roomId, producerId: producer.getId())
        
        self.producers.removeValue(forKey: producer.getId())
        
    }
    
    func consumeTrack(consumerInfo: JSON,requestId : String) {
        if (self.recvTransport == nil) {
            // User has not yet created a transport for receiving so temporarily store it
            // and play it when the recv transport is created
            self.consumersInfo.append(consumerInfo)
            return
        }
        
        let kind: String = consumerInfo["kind"].stringValue
        
        // if already consuming type of track remove it, TODO support multiple remotes?
        for consumer in self.consumers.values {
            if consumer.getKind() == kind {
                print("consumeTrack() removing consumer kind=" + kind)
                self.consumers.removeValue(forKey: consumer.getId())
            }
        }
        
        let id: String = consumerInfo["id"].stringValue
        let producerId: String = consumerInfo["producerId"].stringValue
        let rtpParameters: JSON = consumerInfo["rtpParameters"]
        print("consumeTrack() rtpParameters " + rtpParameters.description)
        
        self.consumerHandler = ConsumerHandler.init()
        self.consumerHandler!.delegate = self.consumerHandler

        let kindConsumer: Consumer = self.recvTransport!.consume(self.consumerHandler!.delegate!, id: id, producerId: producerId, kind: kind, rtpParameters: rtpParameters.description)
        self.consumers[kindConsumer.getId()] = kindConsumer
            
        print("consumeTrack() consuming id =" + kindConsumer.getId())
        
        
            
        self.roomListener?.onNewConsumer(consumer: kindConsumer)
        
        Request.shared.sendAccept(socket: self.socket, requestId: requestId)
    }
    
    func pauseRemoteVideo() throws {
        let consumer: Consumer = try self.getConsumerByKind(kind: "video")
        Request.shared.sendPauseConsumerRequest(socket: self.socket, roomId: self.roomId, consumerId: consumer.getId())
    }
    
    func resumeRemoteVideo() throws {
        let consumer: Consumer = try self.getConsumerByKind(kind: "video")
        Request.shared.sendResumeConsumerRequest(socket: self.socket, roomId: self.roomId, consumerId: consumer.getId())
    }
    
    func pauseRemoteAudio() throws {
        let consumer: Consumer = try self.getConsumerByKind(kind: "audio")
        Request.shared.sendPauseConsumerRequest(socket: self.socket, roomId: self.roomId, consumerId: consumer.getId())
    }
    
    func resumeRemoteAudio() throws {
        let consumer: Consumer = try self.getConsumerByKind(kind: "audio")
        Request.shared.sendResumeConsumerRequest(socket: self.socket, roomId: self.roomId, consumerId: consumer.getId())
    }
    
    private func createWebRtcTransport(direction: String) {
        let response: JSON = Request.shared.sendCreateWebRtcTransportRequest(socket: self.socket, roomId: self.roomId, direction: direction)
//        let data = response["data"]
        print("createWebRtcTransport() response = " + response.description)
        
        let webRtcTransportData: JSON = response["data"]
        
        let id: String = webRtcTransportData["id"].stringValue
        let iceParameters: JSON = webRtcTransportData["iceParameters"]
        let iceCandidatesArray: JSON = webRtcTransportData["iceCandidates"]
        let dtlsParameters: JSON = webRtcTransportData["dtlsParameters"]
        
        switch direction {
        case "send":
            self.sendTransportHandler = SendTransportHandler.init(parent: self)
            self.sendTransportHandler!.delegate = self.sendTransportHandler!
            self.sendTransport = self.device.createSendTransport(self.sendTransportHandler!.delegate!, id: id, iceParameters: iceParameters.description, iceCandidates: iceCandidatesArray.description, dtlsParameters: dtlsParameters.description)
            break
        case "recv":
            self.recvTransportHandler = RecvTransportHandler.init(parent: self)
            self.recvTransportHandler!.delegate = self.recvTransportHandler!
            self.recvTransport = self.device.createRecvTransport(self.recvTransportHandler!.delegate!, id: id, iceParameters: iceParameters.description, iceCandidates: iceCandidatesArray.description, dtlsParameters: dtlsParameters.description)
            
            // Play consumers that have been stored
//            for consumerInfo in self.consumersInfo {
//                self.consumeTrack(consumerInfo: consumerInfo, requestId: <#String#>)
//            }
            break
        default:
            print("createWebRtcTransport() invalid direction " + direction)
        }
    }
    
    private func createProducer(track: RTCMediaStreamTrack, codecOptions: String?, encodings: Array<RTCRtpEncodingParameters>?) {
        self.producerHandler = ProducerHandler.init()
        self.producerHandler!.delegate = self.producerHandler!
        
        let kindProducer: Producer = self.sendTransport!.produce(self.producerHandler!.delegate!, track: track, encodings: encodings, codecOptions: codecOptions)
        self.producers[kindProducer.getId()] = kindProducer
        
        print("createProducer() created id =" + kindProducer.getId() + " kind =" + kindProducer.getKind())
    }
    
    private func handleLocalTransportConnectEvent(transport: Transport, dtlsParameters: String) {
        print("handleLocalTransportConnectEvent() id =" + transport.getId())
        Request.shared.sendConnectWebRtcTransportRequest(socket: self.socket, roomId: self.roomId, transportId: transport.getId(), dtlsParameters: dtlsParameters)
    }
    
    private func handleLocalTransportProduceEvent(transport: Transport, kind: String, rtpParameters: String, appData: String) -> String {
        print("handleLocalTransportProduceEvent() id =" + transport.getId() + " kind = " + kind)
        
        let transportProduceResponse: JSON = Request.shared.sendProduceWebRtcTransportRequest(socket: self.socket, roomId: self.roomId, transportId: transport.getId(), kind: kind, rtpParameters: rtpParameters)
        
        let transportProduceResponseData: JSON = transportProduceResponse["data"]
        
        return transportProduceResponseData["id"].stringValue
    }
    
    private func getProducerByKind(kind: String) throws -> Producer {
        for producer in self.producers.values {
            if producer.getKind() == kind {
                return producer
            }
        }
        
        throw RoomError.PRODUCER_NOT_FOUND
    }
    
    private func getConsumerByKind(kind: String) throws -> Consumer {
        for consumer in self.consumers.values {
            if consumer.getKind() == kind {
                return consumer
            }
        }
        
        throw RoomError.CONSUMER_NOT_FOUND
    }
    
    // Class to handle send transport listener events
    private class SendTransportHandler : NSObject, SendTransportListener {
        fileprivate weak var delegate: SendTransportListener?
        private var parent: RoomClient
        
        init(parent: RoomClient) {
            self.parent = parent
        }
        
        func onConnect(_ transport: Transport!, dtlsParameters: String!) {
            print("SendTransport::onConnect dtlsParameters = " + dtlsParameters)
            self.parent.handleLocalTransportConnectEvent(transport: transport, dtlsParameters: dtlsParameters)
        }
        
        func onConnectionStateChange(_ transport: Transport!, connectionState: String!) {
            print("SendTransport::onConnectionStateChange connectionState = " + connectionState)
        }
        
        func onProduce(_ transport: Transport!, kind: String!, rtpParameters: String!, appData: String!, callback: ((String?) -> Void)!) {
            let producerId = self.parent.handleLocalTransportProduceEvent(transport: transport, kind: kind, rtpParameters: rtpParameters, appData: appData)
            
            callback(producerId)
        }
    }
    
    // Class to handle recv transport listener events
    private class RecvTransportHandler : NSObject, RecvTransportListener {
        fileprivate weak var delegate: RecvTransportListener?
        private var parent: RoomClient
        
        init(parent: RoomClient) {
            self.parent = parent
        }
        
        func onConnect(_ transport: Transport!, dtlsParameters: String!) {
            print("RecvTransport::onConnect")
            self.parent.handleLocalTransportConnectEvent(transport: transport, dtlsParameters: dtlsParameters)
        }
        
        func onConnectionStateChange(_ transport: Transport!, connectionState: String!) {
            print("RecvTransport::onConnectionStateChange newState = " + connectionState)
        }
    }
    
    // Class to handle producer listener events
    private class ProducerHandler : NSObject, ProducerListener {
        fileprivate weak var delegate: ProducerListener?
        
        func onTransportClose(_ producer: Producer!) {
            print("Producer::onTransportClose")
        }
    }
    
    // Class to handle consumer listener events
    private class ConsumerHandler : NSObject, ConsumerListener {
        fileprivate weak var delegate: ConsumerListener?
        
        func onTransportClose(_ consumer: Consumer!) {
            print("Consumer::onTransportClose")
        }
    }
}

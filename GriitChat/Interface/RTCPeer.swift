//
//  RTCPeer.swift
//  GriitChat
//
//  Created by leo on 06/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

class RTCPeer: NSObject {}/*, NBMWebRTCPeerDelegate {
    
    var webRTCPeer: NBMWebRTCPeer?;
    var connectionId: String?;
    var fromUserId: String?;
    var client: WebRTCClient;
    
    var nICECandidateSocketSendCount: Int;
    
    func initPeer(client: WebRTCClient) {
        let mediaConfig = NBMMediaConfiguration.default();
        webRTCPeer = NBMWebRTCPeer.init(delegate: self, configuration: mediaConfig);
        self.client = client;
        nICECandidateSocketSendCount = 0;
    }
    
    func generateOffer(connectionId: String) {
        self.connectionId = connectionId;
    }
    
    func processAnswer(sdpAnswer: String) {
        webRTCPeer?.processAnswer(sdpAnswer, connectionId: connectionId);
    }
    
    func addICECandidate(candidate: RTCIceCandidate) {
        webRTCPeer?.add(candidate, connectionId: connectionId);
    }
    
    func stringForICEConnectionState(state: RTCIceConnectionState) -> String {
        switch (state) {
        case .new:
            return "New";
        case .checking:
            return "Checking";
        case .connected:
            return "Connected";
        case .completed:
            return "Completed";
        case .failed:
            return "Failed";
        case .disconnected:
            return "Disconnected";
        case .closed:
            return "Closed";
        default:
            return "Other state";
        }
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateOffer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        var message: [String: String] = ["id" : "incomingCallResponse",
                                        "from" : webRTCPeer.fromUserId,
                                        "callResponse" : "accept",
                                        "sdpOffer" : sdpOffer.description];
        debugPrint("onLocalSdpOfferGenerated");
//        [self.client sendMessage:[message getJsonString:false]];
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateAnswer sdpAnswer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        var message: [String: String] = ["id" : "incomingCallResponse",
                                         "from" : webRTCPeer.fromUserId,
                                         "callResponse" : "accept",
                                         "sdpOffer" : sdpAnswer.description];
        debugPrint("onLocalSdpAnswerGenerated");
//        [self.client sendMessage:[message getJsonString:false]];
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, hasICECandidate candidate: RTCIceCandidate!, for connection: NBMPeerConnection!) {
        let payload = ["sdpMLineIndex" : candidate.sdpMLineIndex,
                    "sdpMid" : candidate.sdpMid,
                    "candidate" : candidate.sdp] as [String : Any?];
        let message = ["id" : "onIceCandidate",
                       "candidate" : payload] as [String : Any];
        debugPrint("Send content: ", message);
//        [self.client sendMessage:[message getJsonString:false]];
    }
    
    func webrtcPeer(_ peer: NBMWebRTCPeer!, iceStatusChanged state: RTCIceConnectionState, of connection: NBMPeerConnection!) {
        debugPrint("ICE status changed: ", self.stringForICEConnectionState(state: state));
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        debugPrint("Added Stream");
//        [self.client didAddRemoteStream:remoteStream];
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didRemove remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        debugPrint("Removed Stream");
//        [self.client didRemoveRemoteStream];
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd dataChannel: RTCDataChannel!, of connection: NBMPeerConnection!) {
        
    }
}*/

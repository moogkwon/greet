//
//  File.swift
//  Onetoone
//
//  Created by leo on 07/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

protocol KMSPeerDelegate {
    func onAddLocalStream(localView: UIView);
    func onAddRemoteStream(remoteView: UIView);
    func onRemoveRemoteStream();
    func onGenerateOffer(offer: String);
    func onGenerateAnswer(offer: String);
    func onIceCandidate(candidate: [String: Any]);
}


class KMSPeer: NSObject, NBMWebRTCPeerDelegate {
    
    var mediaConfig: NBMMediaConfiguration?;
    var webRTCPeer: NBMWebRTCPeer? = nil;
    var delegate: KMSPeerDelegate;
    var renderDelegate: NBMRendererDelegate;
    
    var connectionId: String?;
    
    var localRenderer: NBMRenderer?;
    var localStream: RTCMediaStream?;
    
    var remoteRenderer: NBMRenderer?;
    var remoteStream: RTCMediaStream?;
    
//    var localAudioTrack: RTCAudioTrack?;
//    var remoteAudioTrack: RTCAudioTrack?;
    
    
    required init(connectionId: String, delegate: KMSPeerDelegate, renderDelegate: NBMRendererDelegate) {
        self.connectionId = connectionId;
        self.delegate = delegate;
        self.renderDelegate = renderDelegate;
        super.init();
    }
    
    deinit {
        releasePeer();
    }
    
    func releasePeer() {
        if (webRTCPeer != nil) {
            webRTCPeer?.closeConnection(withConnectionId: connectionId);
            webRTCPeer = nil;
    
            localRenderer = nil;
            localStream = nil;
    
            remoteRenderer = nil;
            remoteStream = nil;
            
            connectionId = nil;
        }
    }
    
    func createPeer() {
        mediaConfig = NBMMediaConfiguration.default();
        webRTCPeer = NBMWebRTCPeer(delegate: self, configuration: mediaConfig);
        
        webRTCPeer?.startLocalMedia();
        //Generate Offer
        webRTCPeer?.generateOffer(connectionId, withDataChannels: true);
        
        localStream = (webRTCPeer?.localStream)!;
        
        if (self.localStream!.videoTracks.count != 0) {
            var renderer: NBMRenderer? = nil;
            let videoTrack: RTCVideoTrack = self.localStream!.videoTracks.first!;
            
            let rendererType: NBMRendererType = (webRTCPeer?.mediaConfiguration.rendererType)!;
            
            if (rendererType == .openGLES) {
                renderer = NBMEAGLRenderer(delegate: self.renderDelegate);
            }
            renderer?.videoTrack = videoTrack;
            self.localRenderer = renderer;
            delegate.onAddLocalStream(localView: (self.localRenderer?.rendererView)!);
        }
        
        /*if (self.localStream?.audioTracks.count != 0) {
            self.localStream?.audioTracks.first?.isEnabled = true;
            self.localAudioTrack = self.localStream?.audioTracks.first;
        }*/
    }
    
    func addIceCandidate(candidate: RTCIceCandidate) {
        webRTCPeer?.add(candidate, connectionId: connectionId);
    }
    
    
    ////////////////////////////////////////////////////////////////////
    ////////                                                    ////////
    ////////                NBMWebRTCPeerDelegate               ////////
    ////////                                                    ////////
    ////////////////////////////////////////////////////////////////////
    /**
     *  Called when the peer successfully generated an new offer for a connection.
     *
     *  @param peer       The peer sending the message.
     *  @param sdpOffer   The newly generated RTCSessionDescription offer.
     *  @param connection The connection for which the offer was generated.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateOffer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        delegate.onGenerateOffer(offer: sdpOffer.description);
    }
    
    /**
     *  Called when the peer successfully generated a new answer for a connection.
     *
     *  @param peer       The peer sending the message.
     *  @param sdpAnswer  The newly generated RTCSessionDescription offer.
     *  @param connection The connection for which the aswer was generated.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateAnswer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        delegate.onGenerateAnswer(offer: sdpOffer.description);
    }
    
    /**
     *  Called when a new ICE is locally gathered for a connection.
     *
     *  @param peer       The peer sending the message.
     *  @param candidate  The locally gathered ICE.
     *  @param connection The connection for which the ICE was gathered.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, hasICECandidate candidate: RTCIceCandidate!, for connection: NBMPeerConnection!) {
        
        self.delegate.onIceCandidate(candidate: [
            "sdpMLineIndex": candidate.sdpMLineIndex,
            "sdpMid": candidate.sdpMid,
            "candidate": candidate.sdp
            ]);
    }
    
    /**
     *  Called any time a connection's state changes.
     *
     *  @param peer       The peer sending the message.
     *  @param state      The new notified state.
     *  @param connection The connection whose state has changed.
     */
    func webrtcPeer(_ peer: NBMWebRTCPeer!, iceStatusChanged state: RTCIceConnectionState, of connection: NBMPeerConnection!) {
        
    }
    
    /**
     *  Called when media is received on a new stream from remote peer.
     *
     *  @param peer         The peer sending the message.
     *  @param remoteStream A RTCMediaStream instance.
     *  @param connection   The connection related to the stream.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        self.remoteStream = remoteStream;
        var renderer: NBMRenderer;
        
        if (self.remoteStream?.videoTracks.count != 0) {
            let videoTrack: RTCVideoTrack = (self.remoteStream?.videoTracks.first)!;
            let rendererType: NBMRendererType = (webRTCPeer?.mediaConfiguration.rendererType)!;
            
            if (rendererType == .openGLES) {
                renderer = NBMEAGLRenderer(delegate: renderDelegate);
                renderer.videoTrack = videoTrack;
                self.remoteRenderer = renderer;
                self.delegate.onAddRemoteStream(remoteView: (self.remoteRenderer?.rendererView)!);
            } else {
                debugPrint("remote stream has not exact render type.");
            }
        }
        
        JBSoundRouter.routeSound(route: JBSoundRoute.Speaker)
        
        /*if (self.remoteStream?.audioTracks.count != 0) {
            self.remoteAudioTrack = self.remoteStream?.audioTracks.first;
            self.remoteAudioTrack?.isEnabled = true;
        }*/
    }
    
    /**
     *  Called when a remote peer close a stream.
     *
     *  @param peer         The peer sending the message.
     *  @param remoteStream A RTCMediaStream instance.
     *  @param connection   The connection related to the stream.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didRemove remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        self.remoteStream = nil;
        self.remoteRenderer = nil;
        self.delegate.onRemoveRemoteStream();
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd dataChannel: RTCDataChannel!, of connection: NBMPeerConnection!) {
    }
}

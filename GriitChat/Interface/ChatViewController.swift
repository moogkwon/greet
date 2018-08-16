//
//  ChatViewController.swift
//  GriitChat
//
//  Created by leo on 05/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, /*TransMngChatDelegate, */NBMWebRTCPeerDelegate, NBMRendererDelegate {
    
    var transMng: TransMng?;
    var phoneNumber: String = "";
    
    enum UserType {
        case Caller;
        case Callee;
    };
    var userType: UserType?;
    
    var mediaConfig: NBMMediaConfiguration?;
    var webRTCPeer: NBMWebRTCPeer?;
    var connectionId: String?;
    
    var localRenderer: NBMRenderer?;
    var localStream: RTCMediaStream?;
    
    var remoteRenderer: NBMRenderer?;
    var remoteStream: RTCMediaStream?;
    
    var localVideoView: UIView?;
    var remoteVideoView: UIView?;
    
    
    @IBOutlet weak var viewLocalContainer: CameraContainerView!
    
    @IBOutlet weak var viewRemoteContainer: CameraContainerView!
    
    @IBOutlet weak var lblMyPhone: UILabel!
    @IBOutlet weak var lblOtherPhone: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        lblMyPhone.text = transMng?.phoneNumber;
        lblOtherPhone.text = phoneNumber;
//        self.connectionId = (transMng?.phoneNumber)! + "__" + phoneNumber;
        
        if (self.userType == .Caller) {
//            self.transMng?.createPeer(callee: phoneNumber);
        }
        
        createPeer();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPeer() {
        /*
         Default media constraints:
         
         Audio codec: Opus audio codec (higher quality)
         Audio bandiwidth limit: none
         Video codec: Software (VP8)
         Video renderer: OpenGLES 2.0
         Video bandwidth limit: none
         Video format: 640 x 480 @ 30fps
         */
        
        mediaConfig = NBMMediaConfiguration.default();
        webRTCPeer = NBMWebRTCPeer(delegate: self as NBMWebRTCPeerDelegate, configuration: mediaConfig);
        
        webRTCPeer?.startLocalMedia();
        webRTCPeer?.generateOffer(connectionId);
        
        localStream = (webRTCPeer?.localStream)!;
        
        var renderer: NBMRenderer? = nil;
        if (self.localStream!.videoTracks.count != 0) {
            let videoTrack: RTCVideoTrack = self.localStream!.videoTracks.first!;
            
            let rendererType: NBMRendererType = (webRTCPeer?.mediaConfiguration.rendererType)!;
            
            if (rendererType == .openGLES) {
                renderer = NBMEAGLRenderer(delegate: self);
            }
            renderer?.videoTrack = videoTrack;
            self.localRenderer = renderer;
            self.localVideoView = self.localRenderer?.rendererView;
            self.viewLocalContainer?.addSubview(self.localVideoView!);
        }
    }
    
    override func viewDidLayoutSubviews() {
        if (self.localVideoView != nil) {
            self.localVideoView?.frame = (self.viewLocalContainer?.bounds)!;
        }
        /*if (self.remoteVideoView) {
            self.remoteVideoView.frame = self.viewRemoteContainer.bounds;
        }*/
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
    }
    
    /**
     *  Called when the peer successfully generated a new answer for a connection.
     *
     *  @param peer       The peer sending the message.
     *  @param sdpAnswer  The newly generated RTCSessionDescription offer.
     *  @param connection The connection for which the aswer was generated.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateAnswer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
    }
    
    /**
     *  Called when a new ICE is locally gathered for a connection.
     *
     *  @param peer       The peer sending the message.
     *  @param candidate  The locally gathered ICE.
     *  @param connection The connection for which the ICE was gathered.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, hasICECandidate candidate: RTCIceCandidate!, for connection: NBMPeerConnection!) {
        
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
    }
    
    /**
     *  Called when a remote peer close a stream.
     *
     *  @param peer         The peer sending the message.
     *  @param remoteStream A RTCMediaStream instance.
     *  @param connection   The connection related to the stream.
     */
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didRemove remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd dataChannel: RTCDataChannel!, of connection: NBMPeerConnection!) {
        
    }
    
    
    
    
    
    ////////////////////////////////////////////////////////////////////
    ////////                                                    ////////
    ////////              Renderer Delegate                     ////////
    ////////                                                    ////////
    ////////////////////////////////////////////////////////////////////
    
    func renderer(_ renderer: NBMRenderer!, streamDimensionsDidChange dimensions: CGSize) {
        
    }
    
    func rendererDidReceiveVideoData(_ renderer: NBMRenderer!) {
        
    }
    
}

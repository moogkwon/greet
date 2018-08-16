//
//  WebRTCClient.swift
//  GriitChat
//
//  Created by leo on 06/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation


protocol RTCDelegate {
    func onCallReceived(from: String);
    func onStartCommunication(viewView: UIView);
    func onStopCommunication();
    func onAddLocalStream(videoView: UIView);
    func onAddRemoteStream(videoView: UIView);
    func onRemoveRemoteStream();
}

class WebRTCClient: NSObject {} /*, NBMRendererDelegate {
    
    - (void)initClient:(NSURL *)wsURI;
    - (void)registerUser:(NSString *)claimId UserId:(NSString *)userId Name:(NSString *)name;
    - (void)rejectCall:(NSString *)reason;
    - (void)acceptCall;
    - (void)sendMessage:(NSString *)message;
    - (void)didAddRemoteStream: (RTCMediaStream*)remoteStream;
    - (void)didRemoveRemoteStream;
}*/

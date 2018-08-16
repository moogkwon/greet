//
//  ChatCoreViewController.swift
//  GriitChat
//
//  Created by leo on 19/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
/*
enum FriendState {
    case NoFriend;
    case Received;
    case Sent;
    case BeFriend;
}*/
class ChatCoreViewController: CalleeViewController, KMSPeerDelegate, TransMngChatDelegate, NBMRendererDelegate {
    
    var fromId: String = "";
    var toId: String = "";
    
    var kmsPeer: KMSPeer?;
    
    enum UserType {
        case Caller;
        case Callee;
    };
    var userType: UserType?;
    
    var localVideoView: UIView?;
    var remoteVideoView: UIView?;
    
    var afterChatCompletion: ((_ result: Bool) -> Void)? = nil;
    
    var friendState: FriendState = .NoFriend;
    var recordState: FriendState = .NoFriend;
    
    required init?(coder aDecoder: NSCoder) {
        kmsPeer = nil;
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userType == UserType.Caller) {
            kmsPeer = KMSPeer(connectionId: self.fromId, delegate: self, renderDelegate: self);
            kmsPeer?.createPeer();
        } else if (userType == UserType.Callee) {
            self.kmsPeer = KMSPeer(connectionId: self.toId, delegate: self, renderDelegate: self);
            self.kmsPeer?.createPeer();
        }
        Extern.transMng.chatDelegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopChatting() {
        Extern.transMng.sendMessage(msg: [
            "id": "stop"
            ]);
    }
    
    func onSetLocalVideoView(view: UIView) {
        fatalError("Must Override onSetLocalVideoView func.");
    }
    
    func onSetRemoteVideoView(view: UIView) {
        fatalError("Must Override onSetLocalVideoView func.");
    }
    //////////
    //
    //        KMSPeerDelegate
    //
    //////////
    func onAddLocalStream(localView: UIView) {
        if (self.localVideoView != nil) {
            self.localVideoView?.removeFromSuperview();
        }
        self.localVideoView = localView;
        self.onSetLocalVideoView(view: self.localVideoView!);
    }
    
    func onAddRemoteStream(remoteView: UIView) {
        if (self.remoteVideoView != nil) {
            self.remoteVideoView?.removeFromSuperview();
        }
        self.remoteVideoView = remoteView;
        self.onSetRemoteVideoView(view: self.remoteVideoView!);
    }
    
    func onRemoveRemoteStream() {
        if (self.remoteVideoView != nil) {
            self.remoteVideoView?.removeFromSuperview();
        }
        self.remoteVideoView = nil;
    }
    
    func onGenerateOffer(offer: String) {
        var id = "call";
        if (userType == .Callee) {
            id = "incomingCallResponse";
        } else {
            id = "call";
            Extern.transMng.userStatus = .Call;
        }
        Extern.transMng.sendMessage(msg: [
            "id": id,
            "from": fromId,
            "to": toId,
            "sdpOffer": offer,
            "callResponse": "accept",
            ]);
    }
    
    func onGenerateAnswer(offer: String) {
        Extern.transMng.sendMessage(msg: [
            "id": "incomingCallResponse",
            "callResponse" : "accept",
            "from": fromId,
            "to": toId,
            "sdpOffer": offer
            ]);
    }
    
    func onIceCandidate(candidate: [String: Any]) {
        Extern.transMng.userStatus = .Chatting;
        Extern.transMng.sendMessage(msg: [
            "id": "onIceCandidate",
            "candidate": candidate
            ]);
    }
    
    //////////
    //
    //        NBMRendererDelegate
    //
    //////////
    func renderer(_ renderer: NBMRenderer!, streamDimensionsDidChange dimensions: CGSize) {
        
    }
    
    func rendererDidReceiveVideoData(_ renderer: NBMRenderer!) {
        
    }
    
    
    //////////
    //
    //        TransMngChatDelegate
    //
    //////////
    
    func onCallResponse(message: Dictionary<String, Any>) {
        if (message ["response"] as! String != "accepted") {
            showMessage(title: "Call Response", content: "Call not accepted by peer. Closing call.", completion: {
                self.afterChatCompletion?(false);
            })
            self.navigationController?.popViewController(animated: true);
            return;
        }
        kmsPeer?.webRTCPeer?.processAnswer(message ["sdpAnswer"] as! String, connectionId: fromId);
    }
    
    func onStartCommunication(message: Dictionary<String, Any>) {
        kmsPeer?.webRTCPeer?.processAnswer(message ["sdpAnswer"] as! String, connectionId: kmsPeer?.connectionId);
    }
    
    func onStopCommunication(message: Dictionary<String, Any>) {
        
        kmsPeer?.remoteStream = nil;
        kmsPeer?.remoteRenderer = nil;
        self.onRemoveRemoteStream();
        
        kmsPeer?.localStream = nil;
        kmsPeer?.localRenderer = nil;
        if (self.localVideoView != nil) {
            self.localVideoView?.removeFromSuperview();
        }
        self.localVideoView = nil;
        self.navigationController?.popViewController(animated: true);
        showMessage(title: "Stop Communication", content: message ["message"] as! String) {
            self.afterChatCompletion?(false);
        }
    }
    
    func onIceCandidate(message: Dictionary<String, Any>) {
        var data: Dictionary<String, Any> = message ["candidate"] as! Dictionary<String, Any>;
        let sdpMid: String = data ["sdpMid"] as! String;
        let sdpMLineIndex: Int32 = data ["sdpMLineIndex"] as! Int32;
        let sdp: String = data ["candidate"] as! String;
        let candidate: RTCIceCandidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid);
        kmsPeer?.addIceCandidate(candidate: candidate);
    }
    
    func getOtherId() -> String {
        if (userType == UserType.Caller) {
            return self.toId;
        } else {
            return self.fromId;
        }
    }
    func becomeFriend() {
        switch (friendState) {
        case .NoFriend:
            friendState = .Sent;
            break;
        case .Received:
            friendState = .BeFriend;
            onBecomeFriend();
            break;
        default:
            return;
        };
        _ = Extern.transMng.sendMessage(msg: ["id": "becomeFriend",
                                          "friend": getOtherId()]);
    }
    
    func onBecomeFriend(friend: String) {
        if (friend != getOtherId()) {
            return;
        }
        switch (friendState) {
        case .NoFriend:
            friendState = .Received;
            break;
        case .Sent:
            friendState = .BeFriend;
            onBecomeFriend();
            break;
        default:
            return;
        }
    }
    
    func onBecomeFriend() {
        fatalError("This function have to be override.");
    }
    
    func becomeRecordable() {
        switch (recordState) {
        case .NoFriend:
            recordState = .Sent;
            break;
        case .Received:
            recordState = .BeFriend;
            onBecomeRecordable();
            break;
        default:
            return;
        };
        _ = Extern.transMng.sendMessage(msg: ["id": "becomeRecordable",
                                              "friend": getOtherId()]);
    }
    
    func onBecomeRecordable(friend: String) {
        if (friend != getOtherId()) {
            return;
        }
        switch (recordState) {
        case .NoFriend:
            recordState = .Received;
            break;
        case .Sent:
            recordState = .BeFriend;
            onBecomeRecordable();
            break;
        default:
            return;
        }
    }
    
    func onBecomeRecordable() {
        fatalError("This function have to be override.");
    }
}

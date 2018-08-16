 //
//  ChatCoreViewer.swift
//  GriitChat
//
//  Created by GoldHorse on 7/25/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

enum FriendState {
    case NoFriend;
    case Received;
    case Sent;
    case BeFriend;
}
class ChatCoreViewer: ViewPage, KMSPeerDelegate, TransMngChatDelegate, NBMRendererDelegate {
    
    var fromId: String = "";
    var toId: String = "";
    
    var kmsPeer: KMSPeer?;
    
    enum UserType {
        case Caller;
        case Callee;
    };
    
    var userType: UserType?;
    var userInfo: Dictionary<String, Any>? = nil;           //Oposite User Info
    
    var viewLocal: UIView? = nil;
    var viewRemote: UIView? = nil;
    
    var friendState: FriendState = .NoFriend;
    var recordState: FriendState = .NoFriend;
    
    var isReceivedIncomingCall: Bool = false;       //This shows you received call with tap of incoming call list.
    
    var localDimention: CGSize? = nil;
    var remoteDimention: CGSize? = nil;
    
    var isReceiveRemoteVideo = false;
    
    override init(frame: CGRect) {
        kmsPeer = nil;
        super.init(frame: frame);
    }
    required init?(coder aDecoder: NSCoder) {
        kmsPeer = nil;
        super.init(coder: aDecoder);
    }
    
    override func initState() {
        super.initState();
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
        
        let userType = self.userType;
        let myPhone = Extern.transMng.userInfo! ["phoneNumber"] as! String;
        let otherPhone = self.userInfo! ["phoneNumber"] as! String;
        
        if (userType == .Caller) {
            fromId = myPhone;
            toId = otherPhone;
        } else {
            fromId = otherPhone;
            toId = myPhone;
        }
        
        friendState = .NoFriend;
        recordState = .NoFriend;
        
        startChatting();
        
        isReceiveRemoteVideo = false;
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        
        super.onDeactive();
        stopChatting();
        Extern.transMng.resetState();
        
        isReceiveRemoteVideo = false;
        
        userType = nil;
        userInfo?.removeAll();
        userInfo = nil;
    }
    
    func startChatting() {
        if (userType == UserType.Caller) {
            kmsPeer = KMSPeer(connectionId: self.fromId, delegate: self, renderDelegate: self);
            kmsPeer?.createPeer();
        } else if (userType == UserType.Callee) {
            self.kmsPeer = KMSPeer(connectionId: self.toId, delegate: self, renderDelegate: self);
            self.kmsPeer?.createPeer();
        }
        Extern.transMng.chatDelegate = self;
    }
    
    func stopChatting() {
        _ = Extern.transMng.sendMessage(msg: [
            "id": "stop"
            ]);
        releaseCommunication();
    }
    
    func releaseCommunication() {
        kmsPeer?.remoteStream = nil;
        kmsPeer?.remoteRenderer = nil;
        self.onRemoveRemoteStream();
        
        kmsPeer?.localStream = nil;
        kmsPeer?.localRenderer = nil;
        
        if (self.viewLocal != nil) {
            self.viewLocal?.removeFromSuperview();
        }
        self.viewLocal = nil;
        
        if (self.viewRemote != nil) {
            self.viewRemote?.removeFromSuperview();
        }
        self.viewLocal = nil;
        
        kmsPeer?.releasePeer();
        kmsPeer = nil;
    }
    
    func onSetLocalVideoView(view: UIView) {
        fatalError("Must Override onSetLocalVideoView func.");
    }
    
    func onSetRemoteVideoView(view: UIView) {
        fatalError("Must Override onSetLocalVideoView func.");
    }
    
    func onChangeDimension() {
        fatalError("Must Override onSetLocalVideoView func.");
    }
    //////////
    //
    //        KMSPeerDelegate
    //
    //////////
    func onAddLocalStream(localView: UIView) {
        if (self.viewLocal != nil) {
            self.viewLocal?.removeFromSuperview();
        }
        
        localView.layer.transform = CATransform3DMakeScale(-1, 1, -1);
        self.viewLocal = localView;
        self.onSetLocalVideoView(view: self.viewLocal!);
    }
    
    func onAddRemoteStream(remoteView: UIView) {
        if (self.viewRemote != nil) {
            self.viewRemote?.removeFromSuperview();
        }
        self.viewRemote = remoteView;
        self.onSetRemoteVideoView(view: self.viewRemote!);
    }
    
    func onRemoveRemoteStream() {
        if (self.viewRemote != nil) {
            self.viewRemote?.removeFromSuperview();
        }
        self.viewRemote = nil;
        
        isReceiveRemoteVideo = false;
    }
    
    func onGenerateOffer(offer: String) {
        var id = "call";
        if (userType == .Callee) {
            id = "incomingCallResponse";
        } else {
            id = "call";
            Extern.transMng.userStatus = .Call;
        }
        _ = Extern.transMng.sendMessage(msg: [
            "id": id,
            "from": fromId,
            "to": toId,
            "sdpOffer": offer,
            "callResponse": "accept",
            ]);
    }
    
    func onGenerateAnswer(offer: String) {
        _ = Extern.transMng.sendMessage(msg: [
            "id": "incomingCallResponse",
            "callResponse" : "accept",
            "from": fromId,
            "to": toId,
            "sdpOffer": offer
            ]);
    }
    
    func onIceCandidate(candidate: [String: Any]) {
        Extern.transMng.userStatus = .Chatting;
        _ = Extern.transMng.sendMessage(msg: [
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
        debugPrint("streamDimensionsDidChange : ", dimensions);
        
        //leo123123
        if (renderer.rendererView == viewLocal) {
            localDimention = dimensions;
        } else if (renderer.rendererView == viewRemote) {
            isReceiveRemoteVideo = true;
            remoteDimention = dimensions;
        }
        
        onChangeDimension();
    }
    
    func rendererDidReceiveVideoData(_ renderer: NBMRenderer!) {
        debugPrint("rendererDidReceiveVideoData");
        
        if (renderer.rendererView == viewRemote) {
            isReceiveRemoteVideo = true;
            
            onReceiveRemoteVideoData();
        }
    }
    
    func onReceiveRemoteVideoData() {
    }
    
    
    //////////
    //
    //        TransMngChatDelegate
    //
    //////////
    
    func onCallResponse(message: Dictionary<String, Any>) {
        if (message ["response"] as! String != "accepted") {
            Extern.mainVC?.showMessage(title: "Call Response", content: "Call not accepted by peer. Closing call.", completion: {
                self.afterChatCompletion(false);
            })
//            self.navigationController?.popViewController(animated: true);
            return;
        }
        kmsPeer?.webRTCPeer?.processAnswer(message ["sdpAnswer"] as! String, connectionId: fromId);
    }
    
    func onStartCommunication(message: Dictionary<String, Any>) {
        kmsPeer?.webRTCPeer?.processAnswer(message ["sdpAnswer"] as! String, connectionId: kmsPeer?.connectionId);
    }
    
    func onStopCommunication(message: Dictionary<String, Any>) {
        releaseCommunication()
//        Extern.mainVC?.showMessage(title: "Stop Communication", content: message ["message"] as! String) {
            self.afterChatCompletion(false);
//        }
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
        case .BeFriend:
            _ = Extern.transMng.sendMessage(msg: ["id": "becomeFriend",
                                                  "friend": getOtherId()]);
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
    
    func afterChatCompletion(_ result: Bool) {
        fatalError("This function have to be override");
    }
}

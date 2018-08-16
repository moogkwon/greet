//
//  EngineChatViewController.swift
//  GriitChat
//
//  Created by leo on 07/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class EngineChatViewController: UIViewController, KMSPeerDelegate, TransMngChatDelegate, NBMRendererDelegate {
    func onBecomeRecordable(friend: String) {
        
    }
    
    func onBecomeFriend(friend: String) {
        
    }
    
    
//    let SVR_URL: String = "wss://192.168.42.1:8443/one2one";
    
    var fromId: String = "";
    var toId: String = "";
    
    var transMng: TransMng?;
    
    var kmsPeer: KMSPeer?;
    
    enum UserType {
        case Caller;
        case Callee;
    };
    var userType: UserType?;
    
    var localVideoView: UIView?;
    var remoteVideoView: UIView?;
    
//    var soundRouter: AudioOutputManager;
    
    
    @IBOutlet weak var viewLocalContainer: CameraContainerView!
    
    @IBOutlet weak var viewRemoteContainer: CameraContainerView!
    
    required init?(coder aDecoder: NSCoder) {
//        soundRouter = AudioOutputManager(audioSession: AVAudioSession.sharedInstance());
        kmsPeer = nil;
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*var outputPort: AudioOutputPort = self.soundRouter.audioSessionAudioOutputType();
        switch (outputPort) {
        case AudioOutputPort.builtInSpeaker:
            outputPort = AudioOutputPort.builtInReceiver;
        case AudioOutputPort.builtInReceiver:
            outputPort = AudioOutputPort.builtInSpeaker;
            break;
        default:
            break;
        }
        
        self.soundRouter.setOutputType(outputPort, error: nil);
        
        do {
           try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker);
        } catch {
        }*/
        if (userType == UserType.Caller) {
            kmsPeer = KMSPeer(connectionId: self.fromId, delegate: self, renderDelegate: self);
            kmsPeer?.createPeer();
        } else if (userType == UserType.Callee) {
            self.kmsPeer = KMSPeer(connectionId: self.toId, delegate: self, renderDelegate: self);
            self.kmsPeer?.createPeer();
        }
        self.transMng?.chatDelegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        transMng?.sendMessage(msg: [
            "id": "stop"
            ]);
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
        self.viewLocalContainer?.addSubview(self.localVideoView!);
    }
    
    func onAddRemoteStream(remoteView: UIView) {
        if (self.remoteVideoView != nil) {
            self.remoteVideoView?.removeFromSuperview();
        }
        self.remoteVideoView = remoteView;
        self.viewRemoteContainer.addSubview(self.remoteVideoView!);
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
            transMng?.userStatus = .Call;
        }
        transMng?.sendMessage(msg: [
            "id": id,
            "from": fromId,
            "to": toId,
            "sdpOffer": offer,
            "callResponse": "accept",
        ]);
    }
    
    func onGenerateAnswer(offer: String) {
        transMng?.sendMessage(msg: [
            "id": "incomingCallResponse",
            "callResponse" : "accept",
            "from": fromId,
            "to": toId,
            "sdpOffer": offer
            ]);
    }
    
    func onIceCandidate(candidate: [String: Any]) {
        transMng?.userStatus = .Chatting;
        transMng?.sendMessage(msg: [
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
/*    func onConnect() {
//        showMessage(msg: "Socket Connected");
    }
    func onRegistered() {
        showMessage(msg: "User Registered.");
        edtRegAddr.isEnabled = false;
        btnRegister.isEnabled = false;
    }*/
    
    func onCallResponse(message: Dictionary<String, Any>) {
        if (message ["response"] as! String != "accepted") {
            showMessage(msg: "Call not accepted by peer. Closing call");
            self.navigationController?.popViewController(animated: true);
            return;
        }
        kmsPeer?.webRTCPeer?.processAnswer(message ["sdpAnswer"] as! String, connectionId: fromId);
    }
    
    /*func onIncomingCall(message: Dictionary<String, Any>) {
        var from: String = message ["from"] as! String;
        var msg = "Do you want to accept call from <" + from + ">?";
        var alert: UIAlertController = UIAlertController(title: "Call", message: msg, preferredStyle: .alert);
        
        let defaultAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction) in
            self.fromId = message ["from"] as! String;
            self.toId = self.edtRegAddr.text!;
            self.userType = .Callee;
            self.kmsPeer = KMSPeer(connectionId: self.edtRegAddr.text!, delegate: self, renderDelegate: self);
            self.kmsPeer?.createPeer();
        }
        
        var cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction) in
            self.rejectCall(msg: "User rejected");
        }
        alert.addAction(defaultAction);
        alert.addAction(cancelAction);
        self.present(alert, animated: true, completion: nil);
    }
    
    func rejectCall(msg: String) {
        transMng?.sendMessage(msg: [
            "id": "incomingCallResponse",
            "from": edtRegAddr.text,
            "callResponse": "reject",
            "message": msg]);
//        stop(true);
    }*/
    
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
        showMessage(msg: message ["message"] as! String);
    }
    
    func onIceCandidate(message: Dictionary<String, Any>) {
        var data: Dictionary<String, Any> = message ["candidate"] as! Dictionary<String, Any>;
        let sdpMid: String = data ["sdpMid"] as! String;
        let sdpMLineIndex: Int32 = data ["sdpMLineIndex"] as! Int32;
        let sdp: String = data ["candidate"] as! String;
        let candidate: RTCIceCandidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid);
        kmsPeer?.addIceCandidate(candidate: candidate);
    }
    
    func showMessage(msg: String) {
        let alert = UIAlertController(title: "socket", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
    }
}

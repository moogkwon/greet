//
//  Socket.swift
//  Onetoone
//
//  Created by leo on 07/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

protocol SocketDelegate {
    func onConnect();
    func onRegistered();
    func onCallResponse(message: Dictionary<String, Any>);
    func onIncomingCall(message: Dictionary<String, Any>);
    func onStartCommunication(message: Dictionary<String, Any>);
    func onStopCommunication(message: Dictionary<String, Any>);
    func onIceCandidate(message: Dictionary<String, Any>);
}

class Socket: NSObject, SRWebSocketDelegate {
    
    var SOCKET: SRWebSocket;
    var isConnected: Bool;
    var delegate: SocketDelegate;
    
    required init(svrUrl: URL, delegate: SocketDelegate) {
        self.SOCKET = SRWebSocket(urlRequest: URLRequest(url: svrUrl));
        isConnected = false;
        self.delegate = delegate;
        
        super.init();
        SOCKET.delegate = self;
        SOCKET.open();
    }
    
    func sendMessage(msg: [String: Any]) -> Bool {
        if (!isConnected) {
            return false;
        }
        do {
            debugPrint("Sent: \n");
            let jsonData = try JSONSerialization.data(withJSONObject: msg, options: .prettyPrinted);
            SOCKET.send(jsonData);
            
            debugPrint(msg);
            debugPrint(" ");
            
        } catch let error as NSError {
            print(error);
        }
        return true;
    }
    
    func onRecvMsg(message: Dictionary<String, Any>) {
        debugPrint("Received: \n");
//        debugPrint(message);
        debugPrint(" ");
        switch(message ["id"] as! String) {
        case "registerResponse":
            self.delegate.onRegistered();
            break;
        case "callResponse":
            self.delegate.onCallResponse(message: message);
            break;
        case "incomingCall":
            self.delegate.onIncomingCall(message: message);
            break;
        case "startCommunication":
            self.delegate.onStartCommunication(message: message);
            break;
        case "stopCommunication":
            self.delegate.onStopCommunication(message: message);
            break;
        case "iceCandidate":
            self.delegate.onIceCandidate(message: message);
            break;
        default:
            debugPrint("Unknown Message");
            break;
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //                      SRWebSocketDelegate
   
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        isConnected = true;
        delegate.onConnect();
        debugPrint("Socket Opened.");
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let strMsg : String = message as! String;
        let data: Data! = strMsg.data(using: String.Encoding.utf8) as Data!;
        
        do {
            if let jsonMsg = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> {
                self.onRecvMsg(message: jsonMsg);
            } else {
                debugPrint("bad json");
                debugPrint("Message", message);
            }
            //        let anyObj: Any = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions());
        } catch let error as NSError {
            print(error)
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        isConnected = false;
        debugPrint("Socket failed. ", error);
    }
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        isConnected = false;
        debugPrint("Socket Closed. ", reason);
    }
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        debugPrint(pongPayload);
    }
}

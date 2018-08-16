//
//  File.swift
//  GriitChat
//
//  Created by leo on 03/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

protocol TransCenterDelegate {
    func onConnect(result: Bool);
    func onRecvMsg(message: Dictionary<String, Any>);
//    func onRecvBase64(data: Data);
}

class TransCenter : NSObject, SRWebSocketDelegate {
    let VERSION: NSInteger = 100;
    let PCK_SIGN: String = "GRIIT";
    
    var SVR_URL: URL;
    var KMS_URL: URL;
    
    var SOCKET: SRWebSocket;
    var delegate: TransCenterDelegate?;
    
    var isConnected: Bool = false;
    
    var lastPacket: Data? = nil;
    
    required init(svrUrl: URL, kmsUrl: URL) {
        self.SVR_URL = svrUrl;
        self.KMS_URL = kmsUrl;
        self.SOCKET = SRWebSocket(urlRequest: URLRequest(url: self.SVR_URL));
        self.delegate = nil;
        super.init();
        self.SOCKET.delegate = self;
    }
    
    deinit {
        self.close();
    }
    
    func connect() {
        if (self.isConnected) {
            self.SOCKET.close();
            self.SOCKET = SRWebSocket(urlRequest: URLRequest(url: self.SVR_URL));
            self.SOCKET.delegate = self;
        }
        debugPrint("Before Socket open", Extern.getMemoryUsage());
        self.SOCKET.open();
        debugPrint("After Socket open", Extern.getMemoryUsage());
    }
    
    func close() {
        self.SOCKET.close();
    }
    
    func sendMsg(message: Dictionary<String, Any>) -> Bool {
        if (!isConnected) {
            return false;
        }
        var tmpMsg = message;
        tmpMsg ["VERSION"] = self.VERSION;
        tmpMsg ["PCK_SIGN"] = self.PCK_SIGN;
        
        do {
            var jsonData = try JSONSerialization.data(withJSONObject: tmpMsg, options: .prettyPrinted);
            self.SOCKET.send(jsonData);
            
            if (message ["id"] as! String != "setSessionId") {
                lastPacket?.removeAll();
                lastPacket = jsonData;
            }
            
            lastPacket?.removeAll();
            lastPacket = jsonData;
            
            jsonData.removeAll();
            tmpMsg.removeAll();
            return true;
        } catch let error as NSError {
            debugPrint(error);
            return false;
        }
    }
    
    func sendMsg(msg: [String: Any]) -> Bool {
        if (!isConnected) {
            return false;
        }
        var tmpMsg = msg;
        tmpMsg ["VERSION"] = self.VERSION;
        tmpMsg ["PCK_SIGN"] = self.PCK_SIGN;
        do {
            debugPrint("Sent: \n");
            var jsonData = try JSONSerialization.data(withJSONObject: tmpMsg, options: .prettyPrinted);
            self.SOCKET.send(jsonData);
            
            if (msg ["id"] as! String != "setSessionId") {
                lastPacket?.removeAll();
                lastPacket = jsonData;
            }
            
            tmpMsg.removeAll();
            jsonData.removeAll();
            return true;
            
        } catch let error as NSError {
            debugPrint(error);
            return false;
        }
    }
    
    func sendString(str: String) -> Bool {
        if (!isConnected) {
            return false;
        }
        
        lastPacket?.removeAll();
        lastPacket = str.data(using: .utf8);
        
        self.SOCKET.send(str);
        return true;
    }
    
    func sendLastPacket() {
        if (lastPacket != nil) {
            debugPrint(String.init(data: lastPacket!, encoding: .utf8));
            self.SOCKET.send(lastPacket);
            
            lastPacket?.removeAll();
            lastPacket = nil;
        }
    }
    
    func onRecvMsg(message: Dictionary<String, Any>) {
        if (message ["VERSION"] as! NSInteger != self.VERSION) {
            return;
        }
        
        
        if (message ["PCK_SIGN"] as! String != self.PCK_SIGN) {
            return;
        }
        
        if (message ["id"] as! String != "setSessionId") {
            lastPacket?.removeAll();
            lastPacket = nil;
        }
        
        self.delegate?.onRecvMsg(message: message);
    }
    
    
    
    // SRWebSocketDelegate
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        debugPrint("Socket Connected", Extern.getMemoryUsage());
        self.SOCKET = webSocket;
        self.isConnected = true;
        self.delegate?.onConnect(result: true);
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        debugPrint("Socket Closed", "Code : ", code, "Reason: ", reason);
        self.isConnected = false;
        self.SOCKET.close();
        self.SOCKET = SRWebSocket(urlRequest: URLRequest(url: self.SVR_URL));
        self.SOCKET.delegate = self;
        
        self.delegate?.onConnect(result: false);
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        var strMsg : String! = message as! String;
        
        //Check video base64 data...
        /*var indexStartOfText: String.Index! = strMsg.index(strMsg.startIndex, offsetBy: 1)
        if (String(strMsg[..<indexStartOfText]) != "{") {
            var decodedData: Data! = Data(base64Encoded: strMsg.data(using: .utf8)!)!
            
            indexStartOfText = nil;
            self.delegate?.onRecvBase64(data: decodedData);
            
            decodedData.removeAll();
            strMsg.removeAll();
            
            decodedData = nil;
            strMsg = nil;
            debugPrint("Receive binary file end. :  ", Extern.getMemoryUsage());
            return;
        }*/
        /////////////////////////////
        
        
        var data: Data! = strMsg.data(using: String.Encoding.utf8) as Data!;
        
        do {
            if var jsonMsg: Dictionary<String, Any>? = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> {
                self.onRecvMsg(message: jsonMsg!);
                jsonMsg?.removeAll();
                jsonMsg = nil;
            } else {
                debugPrint("bad json");
                debugPrint("Message", message);
            }
//        let anyObj: Any = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions());
        } catch let error as NSError {
            print(error)
        }
        data.removeAll();
        data = nil;
        
        strMsg.removeAll();
        strMsg = nil;
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        self.isConnected = false;
        self.delegate?.onConnect(result: false);
        self.SOCKET.close();
        self.SOCKET = SRWebSocket(urlRequest: URLRequest(url: self.SVR_URL));
        self.SOCKET.delegate = self;
        
        debugPrint(error.localizedDescription);
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        debugPrint("Received Pong");
    }
    // ---// SRWebSocketDelegate
}

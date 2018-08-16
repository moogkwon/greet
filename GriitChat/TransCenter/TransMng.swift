//
//  File.swift
//  GriitChat
//
//  Created by leo on 03/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

@objc protocol TransMngLoginDelegate {
    @objc optional func onConnect(result: Bool);
    @objc optional func onRegister(result: Bool, message: String?);
    @objc optional func onLogin(result: Int, message: String?);
    @objc optional func onLogout(message: String?);
    @objc optional func onSetLocation(result: Bool, message: String?);
    
    @objc optional func onGenerateCodeWithPhoneNumberResponse(message: Dictionary<String, Any>);
}

protocol TransMngUploadVideoDelegate {
    /* Video uploaded result */
    func onUploadVideo(result: Bool, message: Dictionary<String, Any>?);
}

@objc protocol TransMngUserInfoDelegate {
    @objc optional func onUserInfoReceived(result: Int, data: Dictionary<String, Any>?, message: String?);
    
    /* Be used for video binary file or video profile error */
//    func onRecvBinary(data: Data);
//    func onRecvVideoProfileResult(result: Bool, message: String?);
}

protocol TransMngInCallDelegate {
//    func onIncomingCalling(data: Dictionary<String, Any>);
//    func onCreatePeer(caller: String);
    func onChangeIncomingList();
    func onIncomingCall(message: Dictionary<String, Any>);
//    func stopCalling(message: Dictionary<String, Any>);
}

@objc protocol TransMngCallingDelegate {
    //Calling.....
    //Receive remain Sec...
    func onCallingResponse(data: Dictionary<String, Any>);
    
    @objc optional func onGetUserInfoWithPhoneNumber(result: Int, data: Dictionary<String, Any>);
}

protocol TransMngRandomDelegate {
    func onStartRandomResponse(result: Int, data: Dictionary<String, Any>);
    func onReadyRandomCallee(result: Int);
}

protocol TransMngChatDelegate {
    func onCallResponse(message: Dictionary<String, Any>);
    func onStartCommunication(message: Dictionary<String, Any>);
    func onStopCommunication(message: Dictionary<String, Any>);
    func onIceCandidate(message: Dictionary<String, Any>);
    
    func onBecomeFriend(friend: String);
    func onBecomeRecordable(friend: String);
}

protocol TransMngCheckOnlineUsersDelegate {
    func onCheckOnlineUsersResponse(data: [String: Int]);
}

struct INCALLING {
    var phoneNumber: String;
    var remainSec: Int;
    var photoUrl: String;
}

class TransMng : NSObject, TransCenterDelegate {
    var SVR_URL: URL;
    var KMS_URL: URL;
    
    enum UserStatus {
        case Primary;
        case Connected;
        case Logined;
        case Calling;           //Caller
        
        case ReadyCall;         //Caller
        case WaitingCall;       //Callee
        
        case Call;              //Caller
        case IncomingCall;      //Callee
        case Chatting;
    };
    var userStatus: UserStatus;
    
    let ID_REGISTER = "register";
    let ID_REGISTER_RESPONSE = "registerResponse";
    
    let ID_LOGIN = "login";
    let ID_LOGIN_RESPONSE = "loginResponse";
    
    let ID_LOGOUT = "logout";
    let ID_LOGOUT_RESPONSE = "logoutResponse";
    
    let ID_GET_USER_INFO = "getUserInfo";
    let ID_GET_USER_INFO_RESPONSE = "getUserInfoResponse";
    
    //CALLING
    static let COUNT_RINGTONE = 8;
    let ID_CALLING = "calling";
    let ID_CALLING_RESPONSE = "callingResponse";
    
    let ID_INCOMING_CALLING = "incomingCalling";
    let ID_INCOMING_CALLING_RESPONSE = "incomingCallingResponse";
    
    let ID_STOP_CALLING = "stopCalling";
    
    enum GetUserMode {
        case Selective;
        case Random;
    }
    let ID_SELECTIVE_MODE: NSInteger = 0;
    let ID_RANDOM_MODE: NSInteger = 1;
    
    var tryCount: Int = 0;
    
    var transCenter: TransCenter;
    var loginDelegate: TransMngLoginDelegate?;
    var uploadVideoDelegate: TransMngUploadVideoDelegate?
    var userInfoDelegate: TransMngUserInfoDelegate?;
    var incomingCallDelegate: TransMngInCallDelegate?;
    var callingDelegate: TransMngCallingDelegate?;
    var randomDelegate: TransMngRandomDelegate?;
    var chatDelegate: TransMngChatDelegate?;
    var onlineUsersDelegate: TransMngCheckOnlineUsersDelegate?;
    
//    var phoneNumber: String?;
    var userInfo: Dictionary<String, Any>?;     //Owner user info
    
    var incomingList: [String: INCALLING] = [String: INCALLING]();
    
    var sessionId: Int = 0;
    
    required init(svrUrl: String, kmsUrl: String) {
        self.SVR_URL = URL(string: svrUrl)!;
        self.KMS_URL = URL(string: kmsUrl)!;
        self.transCenter = TransCenter(svrUrl: SVR_URL, kmsUrl: KMS_URL);
        self.userInfo = nil;
        self.userStatus = UserStatus.Primary;
        
        super.init();
        self.transCenter.delegate = self;
    }
    
    deinit {
        self.transCenter.close();
    }
    
    func isConnected() -> Bool! {
        return self.userStatus != UserStatus.Primary;
    }
    
    func isLogined() -> Bool! {
        return self.userStatus != UserStatus.Primary
                && self.userStatus != UserStatus.Connected;
    }
    
    
    ////////////////////////////////////////////////////////////////////
    ////////                                                    ////////
    ////////            Send Request to TransCenter             ////////
    ////////                                                    ////////
    ////////////////////////////////////////////////////////////////////
    func connect() {
        if (!self.transCenter.isConnected) {
            self.transCenter.connect();
        } else {
            loginDelegate?.onConnect?(result: true);
        }
    }
    
    func register(regData: Dictionary<String, Any>) -> Bool {
        if (!self.transCenter.isConnected) {
            return false;
        }
        var msg: Dictionary<String, Any> = Dictionary<String, Any>();
        
        msg["id"] = ID_REGISTER;
        msg["data"] = regData;
        _ = self.transCenter.sendMsg(message: msg);
        
        msg.removeAll();
        return true;
    }
    
    func uploadVideo(videoData: String) -> Bool {
        if (!self.transCenter.isConnected) {
            return false;
        }
        _ = self.transCenter.sendString(str: videoData);
        return true;
    }
    
    func login(phoneNumber: String, photoUrl: URL?) -> Bool {
        if (!self.transCenter.isConnected) {
            return false;
        }
        var msg: Dictionary<String, Any> = Dictionary<String, Any>();
        
        msg["id"] = ID_LOGIN;
        msg["phoneNumber"] = phoneNumber;
        if (photoUrl != nil) {
            msg["photoUrl"] = photoUrl?.absoluteString;
        } else {
            msg ["photoUrl"] = "";
        }
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
        return true;
    }
    
    func logout() {
        if (!self.transCenter.isConnected) {
            return;
        }
        var msg: Dictionary<String, Any> = Dictionary<String, Any>();
        
        msg["id"] = ID_LOGOUT;
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
        
        userStatus = .Connected;
//        transCenter.close();
//        transCenter.isConnected = false;
    }
    
    func getUserInfos(filter: Int) {
        if (self.userInfo == nil) {
            return;
        }
        var msg: Dictionary<String, Any> = Dictionary<String, Any>();
        
        msg["id"] = ID_GET_USER_INFO;
        msg["filter"] = filter;
        
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
    }
    
    func getVideoProfile(id: Int) {
        _ = self.transCenter.sendMsg(msg: ["id": "getUserVideoProfile",
                                       "user_id": id]);
    }
    
    func reportUser(id: Int, report: String) {
        _ = self.transCenter.sendMsg(msg: ["id": "reportUser",
                                       "user_id": id,
                                       "report": report]);
    }
    
    func reportUser(phoneNumber: String, report: String) {
        _ = self.transCenter.sendMsg(msg: ["id": "reportUserWithPhoneNumber",
                                       "phoneNumber": phoneNumber,
                                       "report": report]);
    }
    
    func call(phoneNumber: String) -> Bool {
        if (self.isLogined() == false) {
            return false;
        }
        
        userStatus = .Calling;
        var msg: Dictionary<String, Any> = Dictionary<String, Any>();
        msg["id"] = ID_CALLING;
        msg["callee"] = phoneNumber;
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
        return true;
    }
    
    //Caller <---<---<---<---<--- Callee
    func sendRingtone(result: Int, caller: String, remainSec: Int) {
        var msg = [String : Any]();
        msg ["id"] = ID_INCOMING_CALLING_RESPONSE;
        msg ["result"] = result;
        msg ["caller"] = caller;
        msg ["remainSec"] = remainSec;
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
    }
    
    //Caller  --->--->  Callee
    func stopCalling(phoneNumber: String) {
        var msg = [String : Any]();
        msg ["id"] = ID_STOP_CALLING;
        msg ["phoneNumber"] = phoneNumber;
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
    }
    
    func resetState() {
        var msg = [String : Any]();
        msg ["id"] = "resetState";
        _ = self.transCenter.sendMsg(message: msg);
        msg.removeAll();
        userStatus = .Logined;
        
        Extern.chat_userType = nil;
        Extern.chat_videoPath = nil;
        Extern.chat_userInfo = nil;
        
        self.randomDelegate = nil;
        self.uploadVideoDelegate = nil;
        self.chatDelegate = nil;
        self.callingDelegate = nil;
        self.userInfoDelegate = nil;
    }
    
    func startRandom(filter: Int) {
        var msg = [String : Any]();
        msg ["id"] = "startRandom";
        msg ["filter"] = filter;
        
        self.transCenter.sendMsg(message: msg);
        msg.removeAll();
    }
    
    
    ////////////////////////////////////////////////////////////////////
    ////////                                                    ////////
    ////////              Process Responses Message             ////////
    ////////                                                    ////////
    ////////////////////////////////////////////////////////////////////
    
    func onSetSessionId(_ newSesId: Int) {
        var oldSessionId = sessionId;
        if (sessionId == 0 || userStatus == .Primary) {
            sessionId = newSesId;
        } else {
            //Send SessionId.
            if (self.sessionId != 0) {
                _ = self.sendMessage(msg: ["id": "setSessionId",
                                           "sessionId": sessionId]);
            }
        }
        
        if (self.loginDelegate?.onConnect != nil) {
            self.loginDelegate?.onConnect!(result: true);
            
            if (oldSessionId != 0) {
                self.transCenter.sendLastPacket();
            }
        }
    }
    
    func onSetSessionIdResponse(result: Int) {
        //Failed.
        if (result == 0) {
            self.userStatus = UserStatus.Primary;
            if (self.loginDelegate?.onConnect != nil) {
                self.loginDelegate?.onConnect!(result: false);
            }
            self.sessionId = 0;
            self.tryCount = 0;
            self.userStatus = .Connected;
        }
    }
    
    func onRegisterResponse(message: Dictionary<String, Any>) {
        let result: NSInteger = message ["result"] as! NSInteger;
        let bResult: Bool = result == 1;
        
        self.loginDelegate?.onRegister!(result: bResult, message: message ["message"] as? String);
    }
    
    func onLoginResponse(message: Dictionary<String, Any>) {
        let result: NSInteger = message ["result"] as! NSInteger;
        if (result == 1) {
            //Success
            self.userStatus = UserStatus.Logined;
            self.userInfo = (message["data"] as! Dictionary<String, Any>);
            
            //Check video profile in login response.
            /*var videoProPath = UserDefaults.standard.string(forKey: UserKey.Profile_Shared_Key);
            if ((videoProPath == nil || !FileManager.default.fileExists(atPath: videoProPath!)) && self.userInfo! ["video"] != nil && self.userInfo! ["video"] as! String != "" ) {
                //Save Video Profile.
                
                var decodedData: Data! = Data(base64Encoded: (self.userInfo! ["video"] as! String).data(using: .utf8)!)!
                
                let tmpVideoPath = FileManager.makeTempPath("mov");
                FileManager.deleteFile(filePath: tmpVideoPath);
                do {
                    try decodedData.write(to: URL(fileURLWithPath: tmpVideoPath));
                    UserDefaults.standard.set(tmpVideoPath, forKey: UserKey.Profile_Shared_Key);
                } catch (let e) {
                    debugPrint("video profile save error. ", e.localizedDescription);
                }
                
                decodedData.removeAll();
                decodedData = nil;
                self.userInfo! ["video"] = nil;
            }*/
            
            if (!UserKey.isHasVideoProfile()) {
                //Go to Upload Video.
                self.loginDelegate?.onLogin!(result: 2, message: nil);
            } else {
                self.loginDelegate?.onLogin!(result: 1, message: nil);
            }
        } else {
            //Failure
            self.loginDelegate?.onLogin!(result: result, message: message ["message"] as? String);
        }
    }
    
    func onLogoutResponse(message: Dictionary<String, Any>) {
        self.userInfo = nil;
        self.userStatus = UserStatus.Connected;
        self.loginDelegate?.onLogout!(message: message ["message"] as? String);
        self.sessionId = 0;
    }
    
    func onGetUserResponse(message: Dictionary<String, Any>) {
        let result = message ["result"] as! Int;
        if (result < 0 && userInfoDelegate?.onUserInfoReceived != nil) {
            self.userInfoDelegate?.onUserInfoReceived!(result: result, data: nil, message: message ["message"] as! String);
        }
        else if (result > 0 && userInfoDelegate?.onUserInfoReceived != nil) {
            self.userInfoDelegate?.onUserInfoReceived!(result: result, data: message["data"] as! Dictionary<String, Any>, message: nil);
        }
    }
    
    func onIncomingCalling(message: Dictionary<String, Any>) {
        //{caller(phoneNumber)}
        let caller: String = (message ["caller"] as? String)!;
        
        if (incomingList.count >= Int(IncomingList.maxViewCount)) {
            //Max incoming count is 3.
            Extern.transMng.sendRingtone(result: -2, caller: caller, remainSec: 0);
            return;
        }
        
        let incallItem: INCALLING = INCALLING(phoneNumber: caller, remainSec: TransMng.COUNT_RINGTONE, photoUrl: message ["photoUrl"] as! String);
        
        incomingList [caller] = incallItem;
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TransMng.updateTimer)), userInfo: caller, repeats: true);
        
        sendRingtone(result: 0, caller: caller, remainSec: TransMng.COUNT_RINGTONE);
        
        self.incomingCallDelegate?.onChangeIncomingList();
    }
    
    func onStopCalling(message: Dictionary<String, Any>) {
        let phoneNumber: String = message ["phoneNumber"] as! String;
        
        if (incomingList [phoneNumber] == nil) {
            return;
        }
        incomingList.removeValue(forKey: phoneNumber);
        self.incomingCallDelegate?.onChangeIncomingList();
    }
    
    func onStartRandomResponse(message: Dictionary<String, Any>) {
        let result: Int = message ["result"] as! Int;
        let data: Dictionary<String, Any> = message ["data"] as! Dictionary<String, Any>;
        randomDelegate?.onStartRandomResponse(result: result, data: data);
    }
    
    func receiveCall(phoneNumber: String) {
        incomingList [phoneNumber]?.remainSec = 0;
        sendRingtone(result: 1, caller: phoneNumber, remainSec: 0);
        userStatus = .WaitingCall;
    }
    
    func checkOnlineUsers(_ phoneList: [String]) -> Bool {
        return sendMessage(msg: ["id": "checkOnlineUsers",
                          "phoneList": phoneList]);
    }
    
    @objc func updateTimer(timer: Timer) {
        let caller = timer.userInfo as! String;
        
        if (incomingList [caller] == nil) {
            timer.invalidate();
            return;
        }
        
        if (incomingList [caller]?.remainSec == 0) {
            //Ends up incoming call
            incomingList.removeValue(forKey: caller);
            self.incomingCallDelegate?.onChangeIncomingList();
            timer.invalidate();
            return;
        } else {
            //Send Ringtone to caller.
            let remainSec = (incomingList [caller]?.remainSec)! - 1;
            incomingList [caller]?.remainSec = remainSec;
            
            sendRingtone(result: 0, caller: caller, remainSec: remainSec);
            self.incomingCallDelegate?.onChangeIncomingList();
        }
    }
    
    func onCallingResponse(message: Dictionary<String, Any>) {
        self.callingDelegate?.onCallingResponse(data: message);
    }
    
    func sendMessage(msg: [String: Any]) -> Bool {
        return self.transCenter.sendMsg(msg: msg);
    }
    
    ////////////////////////////////////////////////////////////////////
    ////////                                                    ////////
    ////////                TransCenter Detegates               ////////
    ////////                                                    ////////
    ////////////////////////////////////////////////////////////////////
    
    //If network connection failed, it try to connect 10 times every 0.1s
    func onConnect(result: Bool) {
        if (result) {
            //Connected.
            tryCount = 0;
            if (self.userStatus == .Primary) {
                self.userStatus = UserStatus.Connected;
            }
        } else {
            //Failed
            if (tryCount >= 20) {
                self.userStatus = UserStatus.Primary;
                if (self.loginDelegate?.onConnect != nil) {
                    self.loginDelegate?.onConnect!(result: result);
                }
                self.sessionId = 0;
                self.tryCount = 0;
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if (!Extern.isPaused) {
                        self.tryCount += 1;
                    }
                    self.connect();
                    debugPrint("Connecting..... ( ", self.tryCount, " )");
                }
            }
        }
    }
    
    func onRecvMsg(message: Dictionary<String, Any>) {
        if (message ["id"] as! String == "getUserInfoResponse") {
            debugPrint("getUserInfoResponse");
        } else if (message ["id"] as! String == "startRandomResponse") {
            debugPrint("startRandomResponse");
        } else if (message ["id"] as! String == "loginResponse") {
            debugPrint("loginResponse");
        } else if (message ["id"] as! String == "incomingCalling") {
            debugPrint("incomingCalling");
        } else {
            debugPrint(message);
        }
        
        switch(message ["id"] as! String) {
        case "setSessionId":
            let strSesId = message ["sessionId"] as! String;
            self.onSetSessionId(Int(strSesId)!);
            break;
        case "setSessionIdResponse":
            self.onSetSessionIdResponse(result: message ["result"] as! Int);
            return;
        case "generateCodeWithPhoneNumberResponse":
            self.loginDelegate?.onGenerateCodeWithPhoneNumberResponse?(message: message);
            break;
            
        case ID_REGISTER_RESPONSE:
            self.onRegisterResponse(message: message);
            break;
        case "uploadVideoResponse":
            let result = message ["result"] as! Int;
            self.uploadVideoDelegate?.onUploadVideo(result: result == 1, message: message);
            break;
        case "setLocationResponse":
            let result = message ["result"] as! Int;
            self.loginDelegate?.onSetLocation!(result: result == 1, message: message ["message"] as? String);
            break;
        case ID_LOGIN_RESPONSE:
            self.onLoginResponse(message: message);
            break;
        case ID_LOGOUT_RESPONSE:
            self.onLogoutResponse(message: message);
            break;
        case ID_GET_USER_INFO_RESPONSE:
            self.onGetUserResponse(message: message);
            break;
        /*case "getUserVideoProfileResponse":
            let result = message ["result"] as! Int;
            self.userInfoDelegate?.onRecvVideoProfileResult(result: result == 1, message: message ["message"] as? String);
            break;*/
        case ID_INCOMING_CALLING:
            self.onIncomingCalling(message: message);
            break;
        case ID_CALLING_RESPONSE:
            if (userStatus == .Calling) {
                self.onCallingResponse(message: message);
                debugPrint("Calling Response.");
                debugPrint(message);
            }
            break;
        case ID_STOP_CALLING:
            self.onStopCalling(message: message);
            break;
        case "startRandomResponse":
            self.onStartRandomResponse(message: message);
            break;
        case "onReadyRandomCallee":
            let result = message ["result"] as! Int;
            self.randomDelegate?.onReadyRandomCallee(result: result);
            break;
        case "onBecomeFriend":
            self.chatDelegate?.onBecomeFriend(friend: message ["friend"] as! String);
            break;
        case "onBecomeRecordable":
            self.chatDelegate?.onBecomeRecordable(friend: message ["friend"] as! String);
            break;
            
        case "getUserInfoWithPhoneNumberResponse":
            self.callingDelegate?.onGetUserInfoWithPhoneNumber!(result: message ["result"] as! Int, data: message ["data"] as! Dictionary<String, Any>)
            break;
            
        case "checkOnlineUsersResponse":
            self.onlineUsersDelegate?.onCheckOnlineUsersResponse(data: message ["data"] as! [String: Int]);
            break;
        /////////////////////
        //
        //     Media Transform.
        //
        /////////////////////
        case "callResponse":
            if (userStatus == .Call || userStatus == .Chatting) {
                self.chatDelegate?.onCallResponse(message: message);
            }
            break;
        case "incomingCall":
            if (userStatus == .WaitingCall) {
                userStatus = .IncomingCall;
                self.incomingCallDelegate?.onIncomingCall(message: message ["fromUserInfo"] as! Dictionary<String, Any>);
            }
            break;
        case "startCommunication":
            self.chatDelegate?.onStartCommunication(message: message);
            break;
        case "stopCommunication":
            self.chatDelegate?.onStopCommunication(message: message);
            break;
        case "iceCandidate":
            self.chatDelegate?.onIceCandidate(message: message);
            break;
        default:
            break;
        }
    }
    /*
    func onRecvBase64(data: Data) {
        self.userInfoDelegate?.onRecvBinary(data: data);
    }*/
    //--//TransCenterDelegate
    
    //AppDelegate...
    func onPause() {
        sendMessage(msg: ["id": "onPause"]);
    }
    
    func onResume() {
        sendMessage(msg: ["id": "onResume"]);
    }
    
    func onTerminate() {
        sendMessage(msg: ["id": "onTerminate"]);
    }
}

//
//  JBSoundRouter.swift
//
//  Created by Josip Bernat on 1/26/15.
//  Copyright (c) 2015 Josip-Bernat. All rights reserved.
//
import Foundation
import AVFoundation

enum JBSoundRoute: Int {
    
    case NotDefined = 0
    case Speaker
    case Receiver
}

@objc class JBSoundRouter: NSObject {
    
    let JBSoundRouterDidChangeRouteNotification = "JBSoundRouterDidChangeRouteNotification"
    
    class func routeSound(route: JBSoundRoute) {
        
        let instance: JBSoundRouter = self.sharedInstance
        instance.currentRoute = route
    }
    
    class func currentSoundRoute() -> JBSoundRoute {
        
        let instance: JBSoundRouter = self.sharedInstance
        return instance.currentRoute
    }
    
    class func isHeadsetPluggedIn() -> Bool {
        
        let route: AVAudioSessionRouteDescription = AVAudioSession.sharedInstance().currentRoute
        for port in route.outputs {
            
            let portDescription: AVAudioSessionPortDescription = port as AVAudioSessionPortDescription
            if portDescription.portType == AVAudioSessionPortHeadphones || portDescription.portType == AVAudioSessionPortHeadsetMic {
                return true
            }
        }
        return false
    }
    
    //MARK: Shared Instance
    //MARK:
    
    private class var sharedInstance : JBSoundRouter {
        
        struct Static {
            static var onceToken : String = "GriitChat_Sound_Router"
            static var instance : JBSoundRouter? = nil
        }
        DispatchQueue.once(token: Static.onceToken) {
            Static.instance = JBSoundRouter()
        }
        return Static.instance!
    }
    
    //MARK: Initialization
    //MARK:
    
    override init() {
        
        super.init();
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVAudioSessionRouteChange, object: nil,
            queue: OperationQueue.main) { (note) -> Void in
                
                let notification: NSNotification = note as NSNotification
                var dict: Dictionary = notification.userInfo as Dictionary!
                self.JBLog(message: String(format: "AVAudioSessionRouteChangeNotification received. UserInfo: %@", dict))
                
                self.__handleSessionRouteChangeNotification(notification: note as NSNotification)
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVAudioSessionInterruption, object: nil,
            queue: OperationQueue.main) { (note) -> Void in
                
                let notification: NSNotification = note as NSNotification
                var dict: Dictionary = notification.userInfo as Dictionary!
                self.JBLog(message: String(format: "AVAudioSessionInterruptionNotification received. UserInfo: %@", dict))
        }
    }
    
    private func __handleSessionRouteChangeNotification(notification: NSNotification) {
        
        // Because userInfo is an optional we need to check it first.
        if let info = notification.userInfo {
            
            let numberReason: NSNumber = info[AVAudioSessionRouteChangeReasonKey] as! NSNumber
            if let reason = AVAudioSessionRouteChangeReason(rawValue: UInt(numberReason.intValue)) {
                
                switch (reason) {
                    
                case .unknown:
                    JBLog(message: "AVAudioSessionRouteChangeReason.Unknown!")
                    
                case .categoryChange:
                    // We don't want infinite loop here
                    break
                    
                case .newDeviceAvailable:
                    __updateSoundRoute(reason: reason)
                    JBLog(message: "AVAudioSessionRouteChangeReason.NewDeviceAvailable")
                    
                case .oldDeviceUnavailable:
                    __updateSoundRoute(reason: reason)
                    JBLog(message: "AVAudioSessionRouteChangeReason.OldDeviceUnavailable")
                    
                case .override:
                    __updateSoundRoute(reason: reason)
                    JBLog(message: "AVAudioSessionRouteChangeReason.Override")
                    
                case .routeConfigurationChange:
                    __updateSoundRoute(reason: reason)
                    JBLog(message: "AVAudioSessionRouteChangeReason.RouteConfigurationChange")
                    
                case .wakeFromSleep:
                    JBLog(message: "AVAudioSessionRouteChangeReason.WakeFromSleep")
                    
                default:
                    break
                }
            }
        }
    }
    
    //MARK: Setters
    //MARK:
    
    private var currentRoute: JBSoundRoute = JBSoundRoute.Speaker {
        
        didSet {
            
            self.__updateSoundRoute(reason: AVAudioSessionRouteChangeReason.unknown)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: JBSoundRouterDidChangeRouteNotification), object: nil)
        }
    }
    
    //MARK: Routing
    //MARK:
    
    private func __updateSoundRoute(reason: AVAudioSessionRouteChangeReason) {
        
        if reason == AVAudioSessionRouteChangeReason.newDeviceAvailable {
            
            if JBSoundRouter.isHeadsetPluggedIn() == true {
                self.currentRoute = JBSoundRoute.Receiver
                return
            }
        }
        else if reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable {
            
            if JBSoundRouter.isHeadsetPluggedIn() == false {
                self.currentRoute = JBSoundRoute.Speaker
                return
            }
        }
        
        var session: AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
        if let route: AVAudioSessionRouteDescription = session.currentRoute {
            
            if route.outputs != nil {
                
                let outputs: [AVAudioSessionPortDescription] = route.outputs
                for port in route.outputs {
                    
                    let portDescription: AVAudioSessionPortDescription = port as AVAudioSessionPortDescription
                    JBLog(message: portDescription.portType)
                    
                    if (self.currentRoute == JBSoundRoute.Receiver && portDescription.portType != AVAudioSessionPortBuiltInReceiver) {
                        
                        // Switch to Receiver
                        try session.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                    }
                    else if (self.currentRoute == JBSoundRoute.Speaker && portDescription.portType != AVAudioSessionPortBuiltInSpeaker) {
                        
                        // Switch to Speaker
                        try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                    }
                }
            }
        }
        
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try session.setActive(true)
            
        } catch let error {
            debugPrint(error.localizedDescription);
        }
    }
    
    //MARK: Logging
    //MARK:
    
    func JBLog(message: String, function: String = #function) {
        #if DEBUG
        debugPrint("\(function): \(message)")
        #endif
    }
}

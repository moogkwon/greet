//
//  CupManager.swift
//  GriitChat
//
//  Created by GoldHorse on 8/1/18.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import TrueTime

enum FilterMode: Int {
    case Everyone = 2;
    case Female = 0;
    case Male = 1;
}

protocol CupManagerDelegate {
    func onCupCountChanged(cupCount: Int);
    func onCupDurationChanged(duration: Double);
    func onCupStateChanged(isUse: Bool);
}

class CupManager: NSObject {
    
    static let TotalFunTime: Double = /*20.0 * */ 2.0 * 60.0;      //Seconds
    static let TimerUpdateInterval: Double = 1.0;                   //Seconds
    static let RandomCallingDuration: Int = 11;
    
    var trueTimeClient: TrueTimeClient? = nil;
    
    var updateTimer: Timer!
    
    var curDateTime: Date? = nil;
    
    var delegate: CupManagerDelegate? = nil;
    
    var _filterMode: FilterMode? = nil;
    var filterMode: FilterMode {
        set { _filterMode = newValue }
        get {
            if (_filterMode == nil) {
                _filterMode = .Everyone
            }
            if (!isUsingCup()) { return .Everyone; }
            return _filterMode!
        }
    }
    
    override init() {
        // At an opportune time (e.g. app start):
        super.init();
        
        trueTimeClient = TrueTimeClient.sharedInstance
        trueTimeClient?.start()
        
        updateTimer = Timer.scheduledTimer(timeInterval: CupManager.TimerUpdateInterval, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)

        if (UserDefaults.standard.value(forKey: UserKey.CupCount) == nil) {
            UserDefaults.standard.set(1, forKey: UserKey.CupCount);
        }
//        UserDefaults.standard.set(nil, forKey: UserKey.CupStartedTime);
    }
    
    deinit {
        updateTimer.invalidate();
        updateTimer = nil;
    }
    
    func isUsingCup() -> Bool {
        return getCupRemainDuration() != 0;
    }
    
    func getCupCount() -> Int {
        let count: Int? = UserDefaults.standard.integer(forKey: UserKey.CupCount);
        
        if (UserDefaults.standard.value(forKey: UserKey.CupCount) == nil) {
            UserDefaults.standard.set(1, forKey: UserKey.CupCount);
            return 1;
        }
        
        return count!;
    }
    
    //With Second.
    func getCupRemainDuration() -> Double {
        let startedTime: Double? = getCupStartedTime();
        if (startedTime == nil) { return 0; }
        
        let curDateTime = self.curDateTime == nil ? Date() : self.curDateTime;
        
        let duration = CupManager.TotalFunTime - ((curDateTime?.timeIntervalSince1970)! - startedTime!);
        if (duration <= 0) {
            UserDefaults.standard.set(nil, forKey: UserKey.CupStartedTime);
            delegate?.onCupStateChanged(isUse: false);
            return 0;
        }
        return duration;
    }
    
    //With Minutes.
    func getCupRemainDurationWithInt() -> Int {
        return Int(floor(getCupRemainDuration() / 60));
    }
    
    func getCupStartedTime() -> Double? {
        let value = UserDefaults.standard.value(forKey: UserKey.CupStartedTime);
        return value as? Double;
    }
    
    @objc func onTimer(timer: Timer) {
        if (trueTimeClient?.referenceTime?.now() != nil) {
            self.curDateTime = trueTimeClient?.referenceTime?.now();
        } else {
            self.curDateTime = Date();
        }
        
        trueTimeClient?.fetchIfNeeded { result in
            switch result {
            case let .success(referenceTime):
                self.curDateTime = referenceTime.now();
            case let .failure(error):
                print("Error! \(error)")
                self.curDateTime = Date();
            }
        }
        
        self.delegate?.onCupDurationChanged(duration: self.getCupRemainDuration());
    }
    
    func startUseCup() {
        if (isUsingCup()) { return }
        
        let cupCount = getCupCount();
        if (cupCount == 0) { return }
        
        UserDefaults.standard.set(cupCount - 1, forKey: UserKey.CupCount);
        self.delegate?.onCupCountChanged(cupCount: cupCount - 1);
        
        UserDefaults.standard.set(curDateTime?.timeIntervalSince1970, forKey: UserKey.CupStartedTime);
        self.delegate?.onCupStateChanged(isUse: true);
    }
    
    func plusCup(cupCount: Int) {
        let newCupCount = getCupCount() + cupCount;
        
        UserDefaults.standard.set(newCupCount, forKey: UserKey.CupCount);
        delegate?.onCupCountChanged(cupCount: newCupCount);
    }
}

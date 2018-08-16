//
//  MainViewController.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

enum MainViewPageState: String {
    case Selective_Loading = "SLoadingPage";
    case Selective_Profile = "SProfileViewer";
    case Selective_Chat    = "SChatPage";
    
    case Random_Init       = "RInitPage";
    case Random_Loading    = "RLoadingPage";
    case Random_Profile    = "RProfilePage";
    case Random_Chat       = "RChatPage";
    
    case Friend_Main       = "FMainPage";
    case Friend_Loading    = "FLoadingPage";
    case Friend_Chat       = "FChatPage";
    
    case Moment_Main       = "MMainPage";
//    case Moment_Loading    = "MLoadingPage";
    case Moment_Chat       = "MChatPage";
    case Moment_Player     = "MomentPlayer";
    
    case ChatLoadWithCam   = "ChatLoadWithCam";
    case ChatPage          = "CPage";
};

/*                                  Right              dblClick
    Selective   |======> [Loading]   --->    [Profile]   --->    Chat
                |                                |                 |
                |----------------<--Right--------x----<--Right-----x
                |
                |
                |
                |    Left           Right               Right               Auto
    Random      x---<----  [Init]    --->    [Loading]   --->    Profile    --->    Chat
                              |                   ^                 |                 |
                              x-------------------|----<-Left-------x                 |
                                                  |                                   |
                                                  x-----------------------<-Right-----x
 */
/*
protocol MainPageDelegate {
    func onDidSelectiveLoading(result: Bool, userInfo: Dictionary<String, Any>?, videoPath: String?, error: String?);
}*/

class MainViewController: CalleeViewController, ScrollPagerDelegate /*, MainPageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate*/ {
    
    @IBOutlet weak var camView: CameraView!
    @IBOutlet weak var mainPager: ScrollPager!
    
//    var sToolbarView: ToolbarView!
    
    @IBOutlet weak var sToolbarView: ToolbarView!
    
    @IBOutlet weak var toolbarBottomConst: NSLayoutConstraint!
    
    var mainState: MainViewPageState = .Selective_Loading;
    
    let scrDuration = 0.5;
    
    var _sLoadingPage: SelectiveLoadingPage? = nil;
    var sLoadingPage: SelectiveLoadingPage {
        set { _sLoadingPage = newValue }
        get {
            if (_sLoadingPage == nil) {
                _sLoadingPage = SelectiveLoadingPage(frame: self.view.frame);
                _sLoadingPage?.pageName = MainViewPageState.Selective_Loading.rawValue;
                _sLoadingPage?.parentVC = self;
            }
            return _sLoadingPage!;
        }
    }
    
    var _sProfilePage: SelectiveProfileViewer? = nil;
    var sProfilePage: SelectiveProfileViewer {
        set { _sProfilePage = newValue }
        get {
            if (_sProfilePage == nil) {
                _sProfilePage = SelectiveProfileViewer(frame: self.view.frame);
                _sProfilePage?.pageName = MainViewPageState.Selective_Profile.rawValue;
                _sProfilePage?.parentVC = self;
            }
            return _sProfilePage!;
        }
    }
    
    var _rInitPage: RandomInitPage? = nil;
    var rInitPage: RandomInitPage {
        set { _rInitPage = newValue }
        get {
            if (_rInitPage == nil) {
                _rInitPage = RandomInitPage(frame: self.view.frame);
                _rInitPage?.pageName = MainViewPageState.Random_Init.rawValue;
                _rInitPage?.parentVC = self;
            }
            return _rInitPage!;
        }
    }
    
    var _rLoadingPage: RandomLoadingPage? = nil;
    var rLoadingPage: RandomLoadingPage {
        set { _rLoadingPage = newValue }
        get {
            if (_rLoadingPage == nil) {
                _rLoadingPage = RandomLoadingPage(frame: self.view.frame);
                _rLoadingPage?.pageName = MainViewPageState.Random_Loading.rawValue;
                _rLoadingPage?.parentVC = self;
            }
            return _rLoadingPage!;
        }
    }
    
    var _rProfilePage: RandomProfilePage? = nil;
    var rProfilePage: RandomProfilePage {
        set { _rProfilePage = newValue }
        get {
            if (_rProfilePage == nil) {
                _rProfilePage = RandomProfilePage(frame: self.view.frame);
                _rProfilePage?.pageName = MainViewPageState.Random_Profile.rawValue;
                _rProfilePage?.parentVC = self;
            }
            return _rProfilePage!;
        }
    }
    
    var _chattingPage: MainChatViewer? = nil;
    var chattingPage: MainChatViewer {
        set { _chattingPage = newValue }
        get {
            if (_chattingPage == nil) {
                _chattingPage = MainChatViewer(frame: self.view.frame);
                _chattingPage?.pageName = MainViewPageState.ChatPage.rawValue;
                _chattingPage?.parentVC = self;
            }
            return _chattingPage!;
        }
    }
    
    var _friendMainPage: FriendMainPage? = nil;
    var friendMainPage: FriendMainPage {
        set { _friendMainPage = newValue }
        get {
            if (_friendMainPage == nil) {
                _friendMainPage = FriendMainPage(frame: self.view.frame);
                _friendMainPage?.pageName = MainViewPageState.Friend_Main.rawValue;
                _friendMainPage?.parentVC = self;
            }
            return _friendMainPage!;
        }
    }
    
    var _momentMainPage: MomentMainPage? = nil;
    var momentMainPage: MomentMainPage {
        set { _momentMainPage = newValue }
        get {
            if (_momentMainPage == nil) {
                _momentMainPage = MomentMainPage(frame: self.view.frame);
                _momentMainPage?.pageName = MainViewPageState.Moment_Main.rawValue;
                _momentMainPage?.parentVC = self;
            }
            return _momentMainPage!;
        }
    }
    
    var _momentPlayer: MomentPlayer? = nil;
    var momentPlayer: MomentPlayer {
        set { _momentPlayer = newValue }
        get {
            if (_momentPlayer == nil) {
                _momentPlayer = MomentPlayer(frame: self.view.frame);
                _momentPlayer?.pageName = MainViewPageState.Moment_Player.rawValue;
                _momentPlayer?.parentVC = self;
            }
            return _momentPlayer!;
        }
    }
    
    var _chatLoadWithCam: ChatLoadWithCam? = nil;
    var chatLoadWithCam: ChatLoadWithCam {
        set { _chatLoadWithCam = newValue }
        get {
            if (_chatLoadWithCam == nil) {
                _chatLoadWithCam = ChatLoadWithCam(frame: self.view.frame);
                _chatLoadWithCam?.pageName = MainViewPageState.ChatLoadWithCam.rawValue;
                _chatLoadWithCam?.parentVC = self;
            }
            return _chatLoadWithCam!;
        }
    }
    
    let navTree: [MainViewPageState: [Int: [MainViewPageState]]] = [
        .Selective_Loading  : [0: [],
                               1: []],
        .Selective_Profile  : [0: [],
                               1: [.Selective_Loading]],
        
        .Selective_Chat     : [0: [],
                               1: [.Selective_Loading]],
        
        .Random_Init        : [0: [.Selective_Loading],
                               1: [.Random_Loading]],
        
        .Random_Loading     : [0: [.Random_Init],
                               1: []],
        
        .Random_Profile     : [0: [.Random_Init],
                               1: [.Random_Loading]],
        
        .Random_Chat        : [0: [.Random_Init],
                               1: [.Random_Loading]],
        
        .Friend_Main        : [0: [], 1: []],
        .Friend_Loading     : [0: [.Friend_Main], 1: []],
        .Friend_Chat        : [0: [.Friend_Main], 1: []],
        
        .Moment_Main        : [0: [], 1: []],
//        .Moment_Loading     : [0: [], 1: []],
        .Moment_Chat        : [0: [.Moment_Main], 1: []],
        .Moment_Player      : [0: [.Moment_Main], 1: []]
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onInit();
    }
    
    override func onInit() {
        super.onInit();
        
        Extern.mainVC = self;
        mainPager.pageDelegate = self;
        
        sToolbarView.isTransparent = true;
        sToolbarView.parent = self;
        sToolbarView.backgroundColor = UIColor.clear;
        
        mainPager.removeAllPages();
        
        self.navigationController?.isNavigationBarHidden = true;
        
        camView.backgroundColor = UIColor.white;
        
        Extern.cupManager.delegate = self;
        createBtnCup();
        onCupStateChanged(isUse: Extern.cupManager.isUsingCup());
        
        sToolbarView.showController(controllerName: .Random);
        
        createIncomingList();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        sToolbarView.layoutSubviews();
        /*DispatchQueue.main.async {
            let curBarState = self.getToolbarState(state: self.mainState);
            if (curBarState) {
                self.sToolbarView.slideToolbar(ratio: 1, direction: .Up);
            } else {
                self.sToolbarView.slideToolbar(ratio: 1, direction: .Down);
            }
            
            if (self.mainState == .Friend_Main
                || self.mainState == .Moment_Main
                || self.mainState == .Moment_Player) {
                self.sBtnCup.isHidden = true;
            } else {
                self.sBtnCup.isHidden = false;
            }
        }*/
    }
    
    func getPageWithState(_ state: MainViewPageState) -> ViewPage {
        switch (state) {
        case .Selective_Loading:        return sLoadingPage;
            
        case .Selective_Profile:        return sProfilePage;
            
        case .Selective_Chat:
            chattingPage.pageName = MainViewPageState.Selective_Chat.rawValue;
            return chattingPage;
            
        case .Random_Init:              return rInitPage;
            
        case .Random_Loading:           return rLoadingPage;
            
        case .Random_Profile:           return rProfilePage;
            
        case .Random_Chat:
            chattingPage.pageName = MainViewPageState.Random_Chat.rawValue;
            return chattingPage;
        
        case .Friend_Main:              return friendMainPage;
            
        case .Friend_Loading:
            chatLoadWithCam.pageName = MainViewPageState.Friend_Loading.rawValue;
            return chatLoadWithCam;
            
        case .Friend_Chat:
            chattingPage.pageName = MainViewPageState.Friend_Chat.rawValue;
            return chattingPage;
            
        case .Moment_Main:              return momentMainPage;
            
        /*case .Moment_Loading:
            chatLoadWithCam.pageName = MainViewPageState.Moment_Loading.rawValue;
            return chatLoadWithCam;*/
            
        case .Moment_Chat:
            chattingPage.pageName = MainViewPageState.Moment_Chat.rawValue;
            return chattingPage;
            
        case .Moment_Player:            return momentPlayer;
            
        default:
            fatalError("Unknown Main State.");
        }
        fatalError("Unknown State");
        return sLoadingPage;
    }
    
    func gotoPage(_ state: MainViewPageState) {
        mainPager.removeExceptOnlyCurPage();
        
        let curStatePrefix = getStatePrefix(state: mainState);
        let newStatePrefix = getStatePrefix(state: state);
        
        var direction: Bool = true;        //false : to left   true: to right
        
        if (curStatePrefix == newStatePrefix) {
            let pagePrefixNav: [String: [MainViewPageState: Int]] =
                ["F":
                    [MainViewPageState.Friend_Main: 0,
                     MainViewPageState.Friend_Loading: 1,
                     MainViewPageState.Friend_Chat: 2],
                 "M":
                    [MainViewPageState.Moment_Main: 0,
                     MainViewPageState.Moment_Player: 1,
                     MainViewPageState.Moment_Chat: 2]];
            if (pagePrefixNav [curStatePrefix] != nil) {
                if (pagePrefixNav [curStatePrefix]! [mainState]! < pagePrefixNav [curStatePrefix]! [state]!) {
                    direction = true;
                } else {
                    direction = false;
                }
            }
        } else {
            let pagePrefixIndex = ["F": 0,
                                   "S": 1,
                                   "R": 2,
                                   "M": 3];
            if (pagePrefixIndex [curStatePrefix]! < pagePrefixIndex [newStatePrefix]!) { direction = true; }
            else { direction = false; }
        }
        
        if (direction) {
            //Scroll Right.
            _ = mainPager.addPage(page: getPageWithState(state));
            
            mainPager.scrollToIndex(index: 1, duration: scrDuration) {
                self.addRelationPages(state);
            }
        } else {
            //Scroll Left.
            mainPager.insertPage(page: getPageWithState(state), position: .Prev, scrollTo: .OrgPage, duration: 0, completion: nil)
            mainPager.scrollToIndex(index: 0, duration: scrDuration) {
                self.addRelationPages(state);
            }
        }
        
        mainState = state;
        
        if (state == .Friend_Main
            || state == .Moment_Main
            || state == .Moment_Player) {
            sBtnCup.isHidden = true;
        } else {
            sBtnCup.isHidden = false;
        }
    }
    
    func onShowPage(_ state: MainViewPageState) {
        mainPager.removeExceptOnlyCurPage();
        self.addRelationPages(state);
        
        if (state == .Friend_Main
            || state == .Moment_Main
            || state == .Moment_Player) {
            self.sBtnCup.isHidden = true;
        } else {
            self.sBtnCup.isHidden = false;
        }
    }
    
    
    //Called when this page shows
    func addRelationPages(_ state: MainViewPageState) {
        mainState = state;
        mainPager.removeExceptOnlyCurPage();
        
        let navItem : [Int: [MainViewPageState]] = navTree [state]!;

        //Prev
        let prevCnt = (navItem [0]?.count)!
        
        for i in 0 ..< prevCnt {
            mainPager.insertPage(page: getPageWithState(navItem [0]![i]), position: ScrollPager.Position.Prev, scrollTo: ScrollPager.ScrollPos.OrgPage);
        }
        
        //Next
        let nextCnt = (navItem [1]?.count)!
        for i in 0 ..< nextCnt {
            let page = getPageWithState(navItem [1]![i]);
            _ = mainPager.addPage(page: page);
        }
        
        let curBarState = getToolbarState(state: mainState);
        
        DispatchQueue.main.async {
            if (curBarState) {
                self.sToolbarView.slideToolbar(ratio: 1, direction: .Up);
            } else {
                self.sToolbarView.slideToolbar(ratio: 1, direction: .Down);
            }
        }
    }
    
    func enableActions(state: Bool) {
        sToolbarView.isUserInteractionEnabled = state;
    }
    
    func getToolbarState(state: MainViewPageState) -> Bool {
        switch (state) {
        case .Selective_Profile,
             .Selective_Loading,
             .Random_Init,
             .Friend_Main,
             .Moment_Main,
             .Moment_Player:
            return true;
        default:
            return false;
        }
    }
    
    func onChangeCurrentPage(index: Int) {
        
    }
    
    //  +   <<==    Current     ==>>   -
    func onScroll(currentPage: Int, offset: CGFloat) {
        if (offset == 0) { return; }
        //Get will show page.
        let index = offset > 0 ? 0 : 1;
        if (navTree [mainState]! [index]?.count == 0) { return }
        
        let curBarState = getToolbarState(state: mainState);
        let nextState: MainViewPageState = navTree [mainState]! [index]![0];
        let nextBarState = getToolbarState(state: nextState);
        
        //If state is same, return.
        if (curBarState == nextBarState) { return }
        
        //Different, show/hide toolbar as offset.
        let direction: ToolbarSlideDirection = nextBarState ? .Up : .Down;
        sToolbarView.slideToolbar(ratio: offset, direction: direction)
    }
    
    //scrDirection :    0: left
    //                  1: right
    func onScroll(scrDirection: Int) {
        let curPage = mainPager.getCurPage();
        
        let curPageState: MainViewPageState = MainViewPageState(rawValue: (curPage?.pageName)!)!;
        
        mainState = curPageState;
        
        onShowPage(mainState);
    }
    
    func onDidSelectiveLoading(result: Bool, userInfo: Dictionary<String, Any>?, error: String?) {
        if (result) {
            sProfilePage.userInfo = userInfo;
            
            gotoPage(.Selective_Profile);
        } else {
            //If video profile loading error, reload other user.
            self.mainPager.removeAllPages( );
            self.gotoPage(.Selective_Loading);/*
            showMessage(title: "Video Profile Loading", content: error!, completion: {
                self.mainPager.removeAllPages();
                self.gotoPage(.Selective_Loading);
            })*/
        }
    }
    
    func onDidRandomLoading(result: Bool, userInfo: Dictionary<String, Any>?, userType: ChatCoreViewer.UserType?, error: String?) {
        if (result) {
            chattingPage.userInfo = userInfo;
            chattingPage.userType = userType;
            
            chattingPage.isReceivedIncomingCall = false;
            
            if (userType == .Caller) {
                Extern.transMng.userStatus = .ReadyCall;
                gotoPage(.Random_Chat);
            } else {
                //Callee
                Extern.transMng.userStatus = .WaitingCall;
            }
        } else {
            showMessage(title: "Video Profile Loading", content: error!, completion: {
                self.rLoadingPage.initState();
                self.rLoadingPage.onActive();
            })
        }
    }
    
    func willStartChat(userInfo: Dictionary<String, Any>?, userType: ChatCoreViewer.UserType?, state: MainViewPageState) {
        
        if (chattingPage.userInfo == nil ||
            chattingPage.userInfo? ["phoneNumber"] as! String != userInfo? ["phoneNumber"] as! String) {
            chattingPage.userInfo = userInfo;
            chattingPage.userType = userType;
        }
        gotoPage(state);
        
        sToolbarView.slideToolbar(ratio: 1, direction: .Down)
    }
    
    func getStatePrefix(state: MainViewPageState) -> String {
        let newStrState = state.rawValue;
        let newIndex: String.Index = newStrState.index(newStrState.startIndex, offsetBy: 1)
        return String(newStrState[..<newIndex]);
    }
    
    //message: fromUserInfo - id, phoneNumber, photoUrl, location, ... (Data from Database)
    override func onIncomingCall(message: Dictionary<String, Any>) {
        if (Extern.transMng.userStatus == .Logined) { return }

        let statePrefix = getStatePrefix(state: mainState);
        let state: MainViewPageState = prefixToChatState(statePrefix: statePrefix);

        willStartChat(userInfo: message, userType: .Callee, state: state);
    }
    
    func prefixToChatState(statePrefix: String) -> MainViewPageState {
        switch (statePrefix) {
        case "S": return .Selective_Chat;
        case "R": return .Random_Chat;
        case "F": return .Friend_Chat;
        case "M": return .Moment_Chat;
        default:
            fatalError("Unknown incoming state");
            return mainState;
        }
    }
    
    override func onUploadVideo(result: Bool, message: Dictionary<String, Any>?) {
        super.onUploadVideo(result: result, message: message);
        
        if (result) {
            momentMainPage.settingPage?.createProfileViewer();
            dismiss(animated: true) {
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        getPageWithState(mainState).layoutSubviews();
        self.navigationController?.navigationBar.isHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    func onPause() {
        let pageName: String = mainState.rawValue;
        let index: String.Index = pageName.index(pageName.startIndex, offsetBy: 1)
        let statePrefix = String(pageName[..<index]);
        
        let nextState: MainViewPageState;
        
        switch (statePrefix) {
        case "S":
            nextState = .Selective_Loading;
            break;
        case "R":
            nextState = .Random_Init;
            break;
        case "F":
            nextState = .Friend_Main;
            break;
        case "M":
            nextState = .Moment_Main;
            break;
        default:
            fatalError("Unknown incoming state");
        }
        
        gotoPage(nextState);
    }
}

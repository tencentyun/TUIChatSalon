//
//  TRTCChatSalonEnteryControl.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/3.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import TXAppBasic

public protocol TRTCChatSalonEnteryControlDelegate: NSObject {
    func chatSalonCreateRoom(roomId: String, success: @escaping () -> Void, failed: @escaping (Int32, String) -> Void)
    func chartSalonDestroyRoom(roomId: String, success: @escaping () -> Void, failed: @escaping (Int32, String) -> Void)
}


/// ViewModel可视为MVC架构中的Controller层
/// 负责语音聊天室控制器和ViewModel依赖注入，以及公用参数的传递
/// ViewModel、ViewController
/// 注意：该类负责生成所有UI层的ViewController、ViewModel。慎重持有ui层的成员变量，否则很容易发生循环引用。持有成员变量时要慎重！！！！
public class TRTCChatSalonEnteryControl: NSObject {
    // 只读参数，初始化时在外部调用。
    // SDKAPPID和USERID也可以为全局参数，根据自己的需求灵活调整
    // 注入改参数的目的为，解耦ChatSalonUI层与Login模块的耦合
    private(set) var mSDKAppID: Int32 = 0
    public private(set) var chatSalonUserInfo: TXChatSalonUserInfo? = nil
    public weak var delegate: TRTCChatSalonEnteryControlDelegate? = nil
    
    /// 初始化方法
    /// - Parameters:
    ///   - sdkAppId: 注入当前SDKAPPID
    ///   - userID: 注入userID
    @objc public convenience init(sdkAppId:Int32, chatSalonUserInfo: TXChatSalonUserInfo) {
        self.init()
        self.mSDKAppID = sdkAppId
        self.chatSalonUserInfo = chatSalonUserInfo
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    /*
     TRTCVoice为可销毁单例。
     在Demo中，可以通过shardInstance（OC）shared（swift）获取或生成单例对象
     销毁单例对象后，需要再次调用sharedInstance接口重新生成实例。
     该方法在ChatSalonListRoomViewModel、CreateChatSalonViewModel、ChatSalonViewModel中调用。
     由于是可销毁单例，将对象生成防止在这里的目的为统一管理单例生成路径，方便维护
     */
    private var chatSalon: TRTCChatSalon?
    /// 获取ChatSalon
    /// - Returns: 返回ChatSalon单例
    public func getChatSalon() -> TRTCChatSalon {
        if let room = chatSalon {
            return room
        }
        chatSalon = TRTCChatSalon.shared()
        return chatSalon ?? TRTCChatSalon.shared()
    }
    /*
     在无需使用VoicRoom的场景，可以将单例对象销毁。
     例如：退出登录时。
     在本Demo中没有调用到改销毁方法。
    */
    /// 销毁chatSalon单例
    public func clearChatSalon() {
        TRTCChatSalon.destroyShared()
        chatSalon = nil
    }
    
    /// 语聊房入口控制器
    /// - Returns: 返回语聊房的主入口
//    @objc public func makeEntranceViewController() -> UIViewController {
//       return makeChatSalonListViewController()
//    }
    
    
    /// 创建语聊房页面
    /// - Returns: 创建语聊房VC
    public func makeCreateChatSalonViewController() -> UIViewController {
         return TRTCCreateChatSalonViewController.init(dependencyContainer: self)
    }
    
    
    /// 房间列表页面
    /// - Returns: 语聊房列表VC
//    func makeChatSalonListViewController() -> UIViewController {
//        return TRTCChatSalonListViewController.init(dependencyContainer: self)
//    }
    
    /// 语聊房
    /// - Parameters:
    ///   - roomInfo: 要进入或者创建的房间参数
    ///   - role: 角色：观众 主播
    /// - Returns: 返回语聊房控制器
    public func makeChatSalonViewController(roomInfo: ChatSalonInfo, role: ChatSalonViewType, toneQuality:ChatSalonToneQuality = .music) -> UIViewController {
        return TRTCChatSalonViewController.init(viewModelFactory: self, roomInfo: roomInfo, role: role, toneQuality: toneQuality)
    }
    
}

extension TRTCChatSalonEnteryControl: TRTCChatSalonViewModelFactory {
    
    /// 创建语聊房视图逻辑层（MVC中的C，MVVM中的ViewModel）
    /// - Returns: 创建语聊房页面的ViewModel
    public func makeCreateChatSalonViewModel() -> TRTCCreateChatSalonViewModel {
        return TRTCCreateChatSalonViewModel.init(container: self)
    }
    
    /// 语聊房视图逻辑层（MVC中的C，MVVM中的ViewModel）
    /// - Parameters:
    ///   - roomInfo: 语聊房信息
    ///   - roomType: 角色
    /// - Returns: 语聊房页面的ViewModel
    func makeChatSalonViewModel(roomInfo: ChatSalonInfo, roomType: ChatSalonViewType) -> TRTCChatSalonViewModel {
        return TRTCChatSalonViewModel.init(container: self, roomInfo: roomInfo, roomType: roomType)
    }
    
    /// 语聊房列表视图逻辑层（MVC中的C，MVVM中的ViewModel）
    /// - Returns: 语聊房列表的Viewmodel
//    func makeChatSalonListViewModel() -> TRTCChatSalonListViewModel {
//        return TRTCChatSalonListViewModel.init(container: self)
//    }
}

extension TRTCChatSalonEnteryControl {
    func destroyRoom(roomId:String, success:@escaping () -> Void, failed:@escaping (Int32, String) -> Void) {
        if let delegate = delegate {
            delegate.chartSalonDestroyRoom(roomId: roomId, success: success, failed: failed)
        }
    }
    
    func createRoom(roomId:String, success:@escaping () -> Void, failed:@escaping (Int32, String) -> Void) {
        if let delegate = delegate {
            delegate.chatSalonCreateRoom(roomId: roomId, success: success, failed: failed)
        }
    }
}

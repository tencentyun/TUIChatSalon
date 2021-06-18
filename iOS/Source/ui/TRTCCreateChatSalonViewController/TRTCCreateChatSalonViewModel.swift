//
//  TRTCCreateChatSalonViewModel.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import TXAppBasic
import ImSDK_Plus

enum ChatSalonRole {
    case anchor // 主播
    case audience // 观众
}

public enum ChatSalonToneQuality: Int {
    case speech = 1
    case defaultQuality
    case music
}

public protocol TRTCCreateChatSalonViewResponder: NSObject {
    func push(viewController: UIViewController)
}

public class TRTCCreateChatSalonViewModel {
    private let dependencyContainer: TRTCChatSalonEnteryControl
    
    public weak var viewResponder: TRTCCreateChatSalonViewResponder?
    
    var chatSalon: TRTCChatSalon {
        return dependencyContainer.getChatSalon()
    }
    
    var roomName: String = ""
    var userName: String = ""
    var needRequest: Bool = true
    var toneQuality: ChatSalonToneQuality = .music
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责ChatSalon模块的依赖管理
    init(container: TRTCChatSalonEnteryControl) {
        self.dependencyContainer = container
        let name = dependencyContainer.chatSalonUserInfo?.userName ?? ""
        roomName = "\(name)"+String.salonRoomNameSuffix
        userName = name
    }
    
    deinit {
        print("deinit \(type(of: self))")
    }
    
    func createRoom() {
        if let userID = dependencyContainer.chatSalonUserInfo?.userID,
           let avatar = dependencyContainer.chatSalonUserInfo?.avatarURL {
            let roomId = getRoomId()
            let roomInfo = ChatSalonInfo.init(roomID: roomId, ownerId: userID, memberCount: 7)
            roomInfo.ownerName = userName
            roomInfo.coverUrl = avatar
            roomInfo.roomName = roomName
            roomInfo.needRequest = needRequest
            let vc = dependencyContainer.makeChatSalonViewController(roomInfo:roomInfo, role: .anchor, toneQuality: toneQuality)
            viewResponder?.push(viewController: vc)
        } else {
            debugPrint("chatSalonUserInfo is nil")
        }
    }
    
    func getRoomId() -> Int {
        let userID = dependencyContainer.chatSalonUserInfo?.userID ?? ""
        let result = "\(userID)_voice_room".hash & 0x7FFFFFFF
        TRTCLog.out("hashValue:room id:\(result), userID: \(userID)")
        return result
    }
}

fileprivate extension String {
    static let salonRoomNameSuffix = ChatSalonLocalize("Demo.TRTC.Salon.xxsroom")
}

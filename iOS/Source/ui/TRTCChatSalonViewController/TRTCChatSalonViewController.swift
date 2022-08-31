//
//  TRTCChatSalonViewController.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//
import UIKit
import TXAppBasic
import TUICore

protocol TRTCChatSalonViewModelFactory {
   func makeChatSalonViewModel(roomInfo: ChatSalonInfo, roomType: ChatSalonViewType) -> TRTCChatSalonViewModel
}

/// TRTC voice room 聊天室
public class TRTCChatSalonViewController: UIViewController {
    // MARK: - properties:
    let viewModelFactory: TRTCChatSalonViewModelFactory
    let roomInfo: ChatSalonInfo
    let role: ChatSalonViewType
    var viewModel: TRTCChatSalonViewModel?
    let toneQuality: ChatSalonToneQuality
    // MARK: - Methods:
    init(viewModelFactory: TRTCChatSalonViewModelFactory, roomInfo: ChatSalonInfo, role: ChatSalonViewType, toneQuality:
     ChatSalonToneQuality = .music) {
        self.viewModelFactory = viewModelFactory
        self.roomInfo = roomInfo
        self.role = role
        self.toneQuality = toneQuality
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(roomInfo.roomName)\(roomInfo.roomID)"
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage.init(named: "navigationbar_back", in: chatSalonBundle(), compatibleWith: nil), for: .normal)
        backBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        backBtn.sizeToFit()
        let backItem = UIBarButtonItem(customView: backBtn)
        backItem.tintColor = .black
        self.navigationItem.leftBarButtonItem = backItem
        guard let model = viewModel else { return }
        if model.roomType == .audience {
            model.enterRoom()
        } else {
            model.createRoom(toneQuality: toneQuality.rawValue)
        }
#if RTCube_APPSTORE
        if let appUtils = NSClassFromString("AppUtils") {
            let selector = NSSelectorFromString("showAlertUserTips(:)")
            if appUtils.responds(to: selector) {
                appUtils.perform(selector, with: self, afterDelay: 0.25)
            }
        }
        if viewModel?.isOwner == false {
            let reportIcon = UIImage.init(named: "chatsalon_report", in: chatSalonBundle(), compatibleWith: nil)
            let reportItem = UIBarButtonItem(image: reportIcon?.withRenderingMode(.alwaysTemplate),
                                             style: .done,
                                             target: self,
                                             action: #selector(reportAction))
            reportItem.tintColor = .black
            navigationItem.rightBarButtonItem = reportItem
        }
#endif
        TUILogin.add(self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.refreshView()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public override func loadView() {
        // Reload view in this function
        let viewModel = viewModelFactory.makeChatSalonViewModel(roomInfo: roomInfo, roomType: role)
        let rootView = TRTCChatSalonRootView.init(viewModel: viewModel)
        rootView.rootViewController = self
        viewModel.viewResponder = rootView
        self.viewModel = viewModel
        view = rootView
    }
    
    deinit {
        TUILogin.remove(self)
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    /// 取消
    @objc func cancel() {
        presentAlert(title: "", message: (viewModel?.isOwner ?? false) ? .anchorAlertTitle : .audienceAlertTitle) { [weak self] in
            guard let `self` = self else { return }
            self.viewModel?.exitRoom() // 主播销毁房间
        }
    }
    
    @objc
    private func reportAction() {
        let selector = NSSelectorFromString("showReportAlertWithRoomId:ownerId:")
        if self.responds(to: selector) {
            guard let roomInfo = viewModel?.roomInfo else { return }
            self.perform(selector, with: roomInfo.roomID.description, with: roomInfo.ownerId)
        }
    }
}

// MARK: - TUILoginListener
extension TRTCChatSalonViewController: TUILoginListener {
    
    public func onConnecting() {
        
    }
    
    public func onConnectSuccess() {
        
    }
    
    public func onConnectFailed(_ code: Int32, err: String!) {
        
    }
    
    public func onKickedOffline() {
        viewModel?.exitRoom()
    }
    
    public func onUserSigExpired() {
        
    }
    
}

extension TRTCChatSalonViewController {
    func presentAlert(title: String, message: String, sureAction:@escaping () -> Void) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let alertOKAction = UIAlertAction.init(title: String.alertConfirm, style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
            sureAction()
        }
        let alertCancelAction = UIAlertAction.init(title: String.alertCancel, style: .cancel) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(alertCancelAction)
        alertVC.addAction(alertOKAction)
        present(alertVC, animated: true, completion: nil)
    }
}

private extension String {
    static let controllerTitle = chatSalonLocalize("Demo.TRTC.Salon.roomid")
    static let anchorAlertTitle = chatSalonLocalize("Demo.TRTC.Salon.wanttoendroom")
    static let audienceAlertTitle = chatSalonLocalize("Demo.TRTC.Salon.surewanttoleaveroom")
    static let alertConfirm = chatSalonLocalize("Demo.TRTC.Salon.audienceconfirm")
    static let alertCancel = chatSalonLocalize("Demo.TRTC.Salon.waitabit")
}



//
//  TRTCChatSalonRootView.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit
import Kingfisher

// 设置字号和透明度的
enum TRTCChatSalonSeatState {
    case cellSeatEmpty
    case cellSeatFull
    case masterSeatEmpty
    case masterSeatFull
}

// 需要设置合理的高度和宽度获得正常的显示效果(高度越高，name和avatar之间的间距越大)
class TRTCChatSalonSeatView: UIView {
    private var isViewReady: Bool = false
    private var isGetBounds: Bool = false
    private var state: TRTCChatSalonSeatState {
        didSet {
            stateChange()
        }
    }
    
    init(frame: CGRect = .zero, state: TRTCChatSalonSeatState) {
        self.state = state
        super.init(frame: frame)
        bindInteraction()
        stateChange()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "voiceroom_placeholder_avatar", in: ChatSalonBundle(), compatibleWith: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    let speakView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.init(0x0FA968).cgColor
        view.layer.cornerRadius = 25
        return view
    }()
    
    let muteImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "chatsalon_mic_mute", in: ChatSalonBundle(), compatibleWith: nil)
        imageView.isHidden = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: - 视图生命周期函数
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
    }

    func setupStyle() {
        backgroundColor = .clear
    }
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(avatarImageView)
        addSubview(muteImageView)
        addSubview(nameLabel)
        avatarImageView.addSubview(speakView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        avatarImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(snp.width)
        }
        muteImageView.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(avatarImageView)
            make.height.width.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        speakView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
    }
    
    func setSeatInfo(model: ChatSalonSeatInfoModel, showMute: Bool = false) {
        if model.isClosed {
            // close 状态
            avatarImageView.image = UIImage.init(named: "voiceroom_seat_lock", in: ChatSalonBundle(), compatibleWith: nil)
            return
        }
        let isMute = model.seatInfo?.mute ?? false
        if showMute {
            muteImageView.isHidden = false
        } else {
            muteImageView.isHidden = !isMute
        }
        if model.isUsed {
            // 有人
            if let userSeatInfo = model.seatUser {
                let placeholder = UIImage.init(named: "voiceroom_placeholder_avatar", in: ChatSalonBundle(), compatibleWith: nil)
                if let url = URL.init(string: userSeatInfo.userAvatar) {
                    avatarImageView.kf.setImage(with: .network(url), placeholder: placeholder)
                } else {
                    avatarImageView.image = placeholder
                }
                var masterIcon: UIImage? = nil
                if model.isOwner {
                    masterIcon = UIImage.init(named: "chatsalon_master", in: ChatSalonBundle(), compatibleWith: nil)
                }
                nameLabel.set(image:masterIcon, with: userSeatInfo.userName)
            }
        } else {
            // 无人
            avatarImageView.image = UIImage.init(named: "voiceroom_placeholder_avatar", in: ChatSalonBundle(), compatibleWith: nil)
        }
        
        // 绿色边框
        if (model.isTalking) {
            speakView.isHidden = false
        } else {
            speakView.isHidden = true
        }
    }
}

extension TRTCChatSalonSeatView {
    
    private func stateChange() {
        switch state {
        case .cellSeatEmpty:
            toEmptyStates(isMaster: false)
        case .masterSeatEmpty:
            toEmptyStates(isMaster: true)
        case .cellSeatFull:
            toFullStates(isMaster: false)
        case .masterSeatFull:
            toFullStates(isMaster: true)
        }
    }
    
    private func toEmptyStates(isMaster: Bool) {
        let fontSize: CGFloat = 14.0
        nameLabel.font = UIFont.systemFont(ofSize: fontSize)
        nameLabel.textColor = .black
    }
    
    private func toFullStates(isMaster: Bool) {
        let fontSize: CGFloat = 14.0
        nameLabel.font = UIFont.systemFont(ofSize: fontSize)
        nameLabel.textColor = .black
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
}

fileprivate extension UILabel {
    func set(image: UIImage?, with text: String) {
        let mutableAttributedString = NSMutableAttributedString()
        if let image = image {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -3, width: 14, height: 14)
            let attachmentStr = NSAttributedString(attachment: attachment)
            
            mutableAttributedString.append(attachmentStr)
            mutableAttributedString.append(NSAttributedString(string: " "))
        }

        let textString = NSAttributedString(string: text)
        mutableAttributedString.append(textString)

        self.attributedText = mutableAttributedString
    }
}


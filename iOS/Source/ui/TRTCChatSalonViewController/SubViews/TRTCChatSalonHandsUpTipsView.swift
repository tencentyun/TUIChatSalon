//
//  TRTCChatSalonHandsUpTipsView.swift
//  TXLiteAVDemo
//
//  Created by jiruizhang on 2021/3/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import TXAppBasic

class TRTCChatSalonHandsUpTipsView: UIView {
    static let kHeight: CGFloat = 40
    
    private var isViewReady: Bool = false
    
    let handsImgView: UIImageView = {
        let imgView = UIImageView(image: UIImage.init(named: "chatsalon_handsup_success", in: chatSalonBundle(), compatibleWith: nil))
        imgView.contentMode = .scaleAspectFit
        
        return imgView
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = String.successMsg
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
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
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(handsImgView)
        addSubview(contentLabel)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        
        handsImgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(14)
            make.centerY.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(handsImgView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-8)
            make.centerY.equalTo(handsImgView)
        }
        
    }
}

fileprivate extension UIColor {
    static let backgroundBlue = UIColor.init(0x0062E3)
}

fileprivate extension String {
    static var successMsg: String {
        chatSalonLocalize("Demo.TRTC.Salon.raisedhandandwaitmanageraccept")
    }
}

//
//  AppDelegate.swift
//  TRTCChatSalonApp
//
//  Created by adams on 2021/5/19.
//

import UIKit
import TUIChatSalon
import ImSDK_Plus

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let LICENCEURL = ""
    let LICENCEKEY = ""

    func setLicence() {
        TXLiveBase.setLicenceURL(LICENCEURL, key: LICENCEKEY)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setLicence()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func showMainViewController() {
        let chatSalon = TRTCChatSalon.shared()
        guard let userId = ProfileManager.shared.curUserModel?.userId,
              let avatar = ProfileManager.shared.curUserModel?.avatar,
              let name = ProfileManager.shared.curUserModel?.name else {
            debugPrint("not login")
            return
        }
        chatSalon.login(sdkAppID: Int32(SDKAPPID), userID: userId, userSig: ProfileManager.shared.curUserSig()) { (code, message) in
            print("chatSalon login code = \(code)  message = \(message)")
        }
        
        chatSalon.setSelfProfile(userName: name, avatarURL: avatar) { (code, message) in
            print("chatSalon setSelfProfile code = \(code)  message = \(message)")
        }
        
        let chatSalonUserInfo = TXChatSalonUserInfo.init()
        chatSalonUserInfo.avatarURL = avatar
        chatSalonUserInfo.userID = userId
        chatSalonUserInfo.userName = name
        
        let container = TRTCChatSalonEnteryControl.init(sdkAppId: Int32(SDKAPPID), chatSalonUserInfo: chatSalonUserInfo)
        let chatSalonVC = ChatSalonMainViewController.init(dependencyContainer: container)
        chatSalonVC.hidesBottomBarWhenPushed = true
        let rootVC = UINavigationController.init(rootViewController: chatSalonVC)
        if let keyWindow = SceneDelegate.getCurrentWindow() {
            keyWindow.rootViewController = rootVC
            keyWindow.makeKeyAndVisible()
        }
    }
    
    func showLoginViewController() {
        let loginVC = TRTCLoginViewController.init()
        let nav = UINavigationController(rootViewController: loginVC)
        if let keyWindow = SceneDelegate.getCurrentWindow() {
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        }
        else {
            debugPrint("window error")
        }
    }


}


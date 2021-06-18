//
//  VoiceRoomLocalized.swift
//  TRTCAPP_AppStore
//
//  Created by adams on 2021/6/4.
//

import Foundation

//MARK: ChatSalon
let ChatSalonLocalizeTableName = "ChatSalonLocalized"
func TRTCChatSalonLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: ChatSalonLocalizeTableName)
}

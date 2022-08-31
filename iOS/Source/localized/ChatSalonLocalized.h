//
//  ChatSalonLocalized.h
//  Pods
//
//  Created by abyyxwang on 2021/5/6.
//  Copyright © 2022 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark - Base
extern NSBundle *chatSalonBundle(void);
extern NSString *tcsLocalizeFromTable(NSString *key, NSString *table);
extern NSString *tcsLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table);

#pragma mark - Replace String
extern NSString *localizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *localizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);
extern NSString *localizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString
 *yyy_replace, NSString *zzz_replace);
extern NSString *localizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString
 *yyy_replace, NSString *zzz_replace, NSString *mmm_replace);
extern NSString *localizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString
 *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace);

#pragma mark - TRTC
extern NSString *const chatSalon_Localize_TableName;
extern NSString *chatSalonLocalize(NSString *key);

NS_ASSUME_NONNULL_END

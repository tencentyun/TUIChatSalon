//
//  TXChatSalonIMJsonHandle.h
//  TRTCChatSalonOCDemo
//
//  Created by abyyxwang on 2020/7/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatSalonBaseDef.h"

NS_ASSUME_NONNULL_BEGIN

static NSString* gVOICE_ROOM_KEY_ATTR_VERSION = @"version";
static NSString* gVOICE_ROOM_VALUE_ATTR_VERSION = @"1.0";
static NSString* gVOICE_ROOM_KEY_ROOM_INFO = @"roomInfo";
static NSString* gVOICE_ROOM_KEY_SEAT = @"seat";

static NSString* gVOICE_ROOM_KEY_CMD_VERSION = @"version";
static NSString* gVOICE_ROOM_VALUE_CMD_VERSION = @"1.0";
static NSString* gVOICE_ROOM_KEY_CMD_ACTION = @"action";
static NSString* gVOICE_ROOM_KEY_USER_ID = @"userId";

static NSString* gVOICE_ROOM_KEY_INVITATION_VERSION = @"version";
static NSString* gVOICE_ROOM_VALUE_INVITATION_VERSION = @"1.0";
static NSString* gVOICE_ROOM_KEY_INVITATION_CMD = @"command";
static NSString* gVOICE_ROOM_KEY_INVITAITON_CONTENT = @"content";

static NSString* gCHAT_SALON_KEY_CMD_VERSION = @"version";
static NSString* gCHAT_SALON_KEY_CMD_BUSINESSID = @"businessID";
static NSString* gCHAT_SALON_KEY_CMD_PLATFORM = @"platform";
static NSString* gCHAT_SALON_KEY_CMD_EXTINFO = @"extInfo";
static NSString* gCHAT_SALON_KEY_CMD_DATA = @"data";
static NSString* gCHAT_SALON_KEY_CMD_ROOMID = @"room_id";
static NSString* gCHAT_SALON_KEY_CMD_CMD = @"cmd";
static NSString* gCHAT_SALON_KEY_CMD_USERID = @"user_id";

static NSInteger gCHAT_SALON_VALUE_CMD_BASIC_VERSION = 1;
static NSInteger gCHAT_SALON_VALUE_CMD_VERSION = 1;
static NSString* gCHAT_SALON_VALUE_CMD_BUSINESSID = @"ChatSalon";
static NSString* gCHAT_SALON_VALUE_CMD_PLATFORM = @"iOS";
static NSString* gCHAT_SALON_VALUE_CMD_PICK = @"pickUser";
static NSString* gCHAT_SALON_VALUE_CMD_TAKE = @"takeSeat";
static NSString* gCHAT_SALON_VALUE_CMD_KICK = @"kickUser";

typedef NS_ENUM(NSUInteger, TXChatSalonCustomCodeType) {
    kChatSalonCodeUnknown = 0,
    kChatSalonCodeDestroy = 200,
    kChatSalonCodeCustomMsg = 301,
    kChatSalonCodeKickSeatMsg = 302,
    kChatSalonCodePickSeatMsg = 303,
};

@interface TXChatSalonIMJsonHandle : NSObject

+ (NSDictionary<NSString *,NSString *> *)getInitRoomDicWithRoomInfo:(TXChatSalonRoomInfo
 *)roominfo seatInfoList:(NSDictionary<NSString *,TXChatSalonSeatInfo *> *)seatInfoList;

+ (NSDictionary<NSString *, NSString *> *)getSeatInfoListJsonStrWithSeatInfoList:(NSArray<TXChatSalonSeatInfo *> *)seatInfoList;

+ (NSDictionary<NSString *, NSString *> *)getSeatInfoJsonStrWithUserID:(NSString *)userID info:(TXChatSalonSeatInfo *)info;

+ (TXChatSalonRoomInfo * _Nullable)getRoomInfoFromAttr:(NSDictionary<NSString *, NSString *> *)attr;

+ (NSDictionary<NSString *, TXChatSalonSeatInfo *> * _Nullable)getSeatListFromAttr:(NSDictionary<NSString *,NSString *> *)attr;

+ (NSString *)getInvitationMsgWithRoomId:(NSString *)roomId cmd:(NSString *)cmd content:(NSString *)content;

+ (TXChatSalonInviteData * _Nullable)parseInvitationMsgWithJson:(NSString *)json;

+ (NSString *)getRoomdestroyMsg;

+ (NSString *)getCusMsgJsonStrWithCmd:(NSString *)cmd msg:(NSString *)msg;

+ (NSDictionary<NSString *, NSString *> *)parseCusMsgWithJsonDic:(NSDictionary *)jsonDic;

+ (NSString *)getKickMsgJsonStrWithUserID:(NSString *)userID;
+ (NSString *)getPickMsgJsonStrWithUserID:(NSString *)userID;
@end

NS_ASSUME_NONNULL_END

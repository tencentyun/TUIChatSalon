package com.tencent.liteav.trtcchatsalon.model.impl.room.impl;

import android.text.TextUtils;
import android.util.Pair;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfo;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.CODE_ROOM_CUSTOM_MSG;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.CODE_ROOM_DESTROY;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_ATTR_VERSION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_CMD_ACTION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_CMD_VERSION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_ROOM_INFO;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.VALUE_ATTR_VERSION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.VALUE_CMD_VERSION;

public class IMProtocol {
    private static final String TAG = IMProtocol.class.getName();


    public static class Define {
        public static final String KEY_ATTR_VERSION   = "version";
        public static final String VALUE_ATTR_VERSION = "1.0";
        public static final String KEY_ROOM_INFO      = "roomInfo";

        public static final String KEY_CMD_VERSION   = "version";
        public static final String VALUE_CMD_VERSION = "1.0";
        public static final String KEY_CMD_ACTION    = "action";

        public static final int CODE_UNKNOWN      = 0;
        public static final int CODE_ROOM_DESTROY = 200;

        public static final int CODE_ROOM_CUSTOM_MSG = 301;
    }

    public static class SignallingDefine {
        public static String  KEY_VERSION     = "version";
        public static String  KEY_BUSINESS_ID = "businessID";
        public static String  KEY_DATA        = "data";
        public static String  KEY_ROOM_ID     = "room_id";
        public static String  KEY_CMD         = "cmd";
        public static String  KEY_USER_ID     = "user_id";

        public static final int    VALUE_VERSION       = 1;
        public static final String VALUE_BUSINESS_ID   = "ChatSalon"; //语音沙龙场景
        public static final String VALUE_PLATFORM      = "Android";   //当前平台
        public static final String VALUE_CMD_KICK_USER = "kickUser";  //踢人下麦
        public static final String VALUE_CMD_PICK_USER = "pickUser";  //抱人上麦
    }

    public static HashMap<String, String> getInitRoomMap(TXRoomInfo TXRoomInfo) {
        Gson                    gson    = new Gson();
        HashMap<String, String> jsonMap = new HashMap<>();
        jsonMap.put(KEY_ATTR_VERSION, VALUE_ATTR_VERSION);
        jsonMap.put(KEY_ROOM_INFO, gson.toJson(TXRoomInfo));
        return jsonMap;
    }

    public static TXRoomInfo getRoomInfoFromAttr(Map<String, String> map) {
        TXRoomInfo TXRoomInfo;
        Gson       gson = new Gson();
        String     json = map.get(KEY_ROOM_INFO);
        if (TextUtils.isEmpty(json)) {
            return null;
        }
        try {
            TXRoomInfo = gson.fromJson(json, TXRoomInfo.class);
        } catch (Exception e) {
            TRTCLogger.e(TAG, "parse room info json error! " + json);
            TXRoomInfo = null;
        }
        return TXRoomInfo;
    }

    public static SignallingData convert2SignallingData(String json) {
        SignallingData signallingData = new SignallingData();
        Map<String, Object> extraMap;
        try {
            extraMap = new Gson().fromJson(json, Map.class);
            if (extraMap == null) {
                TRTCLogger.e(TAG, " extraMap is null, ignore");
                return signallingData;
            }
            if (extraMap.containsKey(SignallingDefine.KEY_VERSION)) {
                Object version = extraMap.get(SignallingDefine.KEY_VERSION);
                if (version instanceof Double) {
                    signallingData.setVersion(((Double) version).intValue());
                } else {
                    TRTCLogger.e(TAG, "version is not int, value is :" + version);
                }
            }

            if (extraMap.containsKey(SignallingDefine.KEY_BUSINESS_ID)) {
                Object businessId = extraMap.get(SignallingDefine.KEY_BUSINESS_ID);
                if (businessId instanceof String) {
                    signallingData.setBusinessID((String) businessId);
                } else {
                    TRTCLogger.e(TAG, "businessId is not string, value is :" + businessId);
                }
            }

            if (extraMap.containsKey(SignallingDefine.KEY_DATA)) {
                Object dataMapObj = extraMap.get(SignallingDefine.KEY_DATA);
                if (dataMapObj != null && dataMapObj instanceof Map) {
                    Map<String, Object> dataMap = (Map<String, Object>) dataMapObj;
                    SignallingData.DataInfo dataInfo = convert2DataInfo(dataMap);
                    signallingData.setData(dataInfo);
                } else {
                    TRTCLogger.e(TAG, "dataMapObj is not map, value is :" + dataMapObj);
                }
            }
        } catch (JsonSyntaxException e) {
            TRTCLogger.e(TAG, "convert2SignallingData json parse error");
        }
        return signallingData;
    }

    private static SignallingData.DataInfo convert2DataInfo(Map<String, Object> dataMap) {
        SignallingData.DataInfo dataInfo = new SignallingData.DataInfo();
        try {
            if (dataMap.containsKey(SignallingDefine.KEY_CMD)) {
                Object cmd = dataMap.get(SignallingDefine.KEY_CMD);
                if (cmd instanceof String) {
                    dataInfo.setCmd((String)cmd);
                } else {
                    TRTCLogger.e(TAG, "cmd is not string, value is :" + cmd);
                }
            }
            if (dataMap.containsKey(SignallingDefine.KEY_ROOM_ID)) {
                Object roomId = dataMap.get(SignallingDefine.KEY_ROOM_ID);
                if (roomId instanceof Double) {
                    dataInfo.setRoomID(((Double) roomId).intValue());
                } else {
                    TRTCLogger.e(TAG, "roomId is not Double, value is :" + roomId);
                }
            }
            if (dataMap.containsKey(SignallingDefine.KEY_USER_ID)) {
                Object userId = dataMap.get(SignallingDefine.KEY_USER_ID);
                if (userId instanceof String) {
                    dataInfo.setUserId((String) userId);
                } else {
                    TRTCLogger.e(TAG, "userId is not string, value is :" + userId);
                }
            }
        } catch (JsonSyntaxException e) {
            TRTCLogger.e(TAG, "onReceiveNewInvitation JsonSyntaxException:" + e);
        }
        return dataInfo;
    }

    public static String getRoomDestroyMsg() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_CMD_VERSION, VALUE_CMD_VERSION);
            jsonObject.put(KEY_CMD_ACTION, CODE_ROOM_DESTROY);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getCusMsgJsonStr(String cmd, String msg) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_ATTR_VERSION, VALUE_ATTR_VERSION);
            jsonObject.put(KEY_CMD_ACTION, CODE_ROOM_CUSTOM_MSG);
            jsonObject.put("command", cmd);
            jsonObject.put("message", msg);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static Pair<String, String> parseCusMsg(JSONObject jsonObject) {
        String cmd     = jsonObject.optString("command");
        String message = jsonObject.optString("message");
        return new Pair<>(cmd, message);
    }
}
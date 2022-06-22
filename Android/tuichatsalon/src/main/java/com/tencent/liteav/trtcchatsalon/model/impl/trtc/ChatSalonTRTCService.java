package com.tencent.liteav.trtcchatsalon.model.impl.trtc;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXCallback;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class ChatSalonTRTCService extends TRTCCloudListener {
    private static final String TAG                     = "ChatSalonTRTCService";
    private static final long   PLAY_TIME_OUT           = 5000;
    private static final int    KTC_COMPONENT_CHATSALON = 7;

    private static ChatSalonTRTCService sInstance;

    private TRTCCloud                    mTRTCCloud;
    private TXBeautyManager              mTXBeautyManager;
    private boolean                      mIsInRoom;
    private ChatSalonTRTCServiceDelegate mDelegate;
    private String                       mUserId;
    private TRTCCloudDef.TRTCParams      mTRTCParams;
    private Handler                      mMainHandler;
    private TXCallback                   mEnterRoomCallback;
    private TXCallback                   mExitRoomCallback;
    private OnSwitchRoleListener         mOnSwitchRoleListener;

    public static synchronized ChatSalonTRTCService getInstance() {
        if (sInstance == null) {
            sInstance = new ChatSalonTRTCService();
        }
        return sInstance;
    }

    public void init(Context context) {
        mTRTCCloud = TRTCCloud.sharedInstance(context);
        TRTCLogger.i(TAG, "init context:" + context);
        mTXBeautyManager = mTRTCCloud.getBeautyManager();
        mMainHandler = new Handler(Looper.getMainLooper());
    }

    public void setDelegate(ChatSalonTRTCServiceDelegate delegate) {
        TRTCLogger.i(TAG, "init delegate:" + delegate);
        mDelegate = delegate;
    }

    public void enterRoom(int sdkAppId, int roomId, String userId, String userSign, int role, TXCallback callback) {
        if (sdkAppId == 0 || roomId == 0 || TextUtils.isEmpty(userId) || TextUtils.isEmpty(userSign)) {
            // 参数非法，可能执行了退房，或者登出
            TRTCLogger.e(TAG, "enter trtc room fail. params invalid. room id:" + roomId +
                    " user id:" + userId + " sign is empty:" + TextUtils.isEmpty(userSign));
            if (callback != null) {
                callback.onCallback(-1, "enter trtc room fail. params invalid. room id:" +
                        roomId + " user id:" + userId + " sign is empty:" + TextUtils.isEmpty(userSign));
            }
            return;
        }
        mUserId = userId;
        mEnterRoomCallback = callback;
        TRTCLogger.i(TAG, "enter room, app id:" + sdkAppId + " room id:" + roomId + " user id:" +
                userId + " sign:" + TextUtils.isEmpty(userId));
        mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = sdkAppId;
        mTRTCParams.userId = userId;
        mTRTCParams.userSig = userSign;
        mTRTCParams.role = role;
        mTRTCParams.roomId = roomId;
        internalEnterRoom();
    }

    private void setFramework() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("api", "setFramework");
            JSONObject params = new JSONObject();
            params.put("framework", 1);
            params.put("component", KTC_COMPONENT_CHATSALON);
            jsonObject.put("params", params);
            mTRTCCloud.callExperimentalAPI(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void internalEnterRoom() {
        // 进房前设置一下监听，不然可能会被其他信息打断
        if (mTRTCParams == null) {
            return;
        }
        setFramework();
        mTRTCCloud.setListener(this);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM);
        // enable volume callback
        enableAudioEvaluation(true);
    }

    public void exitRoom(TXCallback callback) {
        TRTCLogger.i(TAG, "exit room.");
        mUserId = null;
        mTRTCParams = null;
        mEnterRoomCallback = null;
        mExitRoomCallback = callback;
        mMainHandler.removeCallbacksAndMessages(null);
        mTRTCCloud.exitRoom();
    }

    public void muteLocalAudio(boolean mute) {
        TRTCLogger.i(TAG, "mute local audio, mute:" + mute);
        mTRTCCloud.muteLocalAudio(mute);
    }

    public void muteRemoteAudio(String userId, boolean mute) {
        TRTCLogger.i(TAG, "mute remote audio, user id:" + userId + " mute:" + mute);
        mTRTCCloud.muteRemoteAudio(userId, mute);
    }

    public void muteAllRemoteAudio(boolean mute) {
        TRTCLogger.i(TAG, "mute all remote audio, mute:" + mute);
        mTRTCCloud.muteAllRemoteAudio(mute);
    }

    public boolean isEnterRoom() {
        return mIsInRoom;
    }

    @Override
    public void onEnterRoom(long l) {
        TRTCLogger.i(TAG, "on enter room, result:" + l);
        if (mEnterRoomCallback != null) {
            if (l > 0) {
                mIsInRoom = true;
                mEnterRoomCallback.onCallback(0, "enter room success.");
            } else {
                mIsInRoom = false;
                mEnterRoomCallback.onCallback((int) l, "enter room fail");
            }
        }
    }

    @Override
    public void onExitRoom(int i) {
        TRTCLogger.i(TAG, "on exit room.");
        if (mExitRoomCallback != null) {
            mIsInRoom = false;
            mExitRoomCallback.onCallback(0, "exit room success.");
            mExitRoomCallback = null;
        }
    }

    @Override
    public void onRemoteUserEnterRoom(String userId) {
        TRTCLogger.i(TAG, "on user enter, user id:" + userId);
        if (mDelegate != null) {
            mDelegate.onTRTCAnchorEnter(userId);
        }
    }

    @Override
    public void onRemoteUserLeaveRoom(String userId, int i) {
        TRTCLogger.i(TAG, "on user exit, user id:" + userId);
        if (mDelegate != null) {
            mDelegate.onTRTCAnchorExit(userId);
        }
    }

    @Override
    public void onUserAudioAvailable(String userId, boolean available) {
        TRTCLogger.i(TAG, "on user audio available, user id:" + userId + " available:" + available);
        if (mDelegate != null) {
            mDelegate.onTRTCAudioAvailable(userId, available);
        }
    }

    @Override
    public void onError(int errorCode, String errorMsg, Bundle bundle) {
        TRTCLogger.i(TAG, "onError: " + errorCode);
        if (mDelegate != null) {
            mDelegate.onError(errorCode, errorMsg);
        }
    }


    @Override
    public void onNetworkQuality(final TRTCCloudDef.TRTCQuality trtcQuality, final ArrayList<TRTCCloudDef.TRTCQuality> arrayList) {
        if (mDelegate != null) {
            mDelegate.onNetworkQuality(trtcQuality, arrayList);
        }
    }

    @Override
    public void onUserVoiceVolume(final ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
        if (mDelegate != null && userVolumes.size() != 0) {
            mDelegate.onUserVoiceVolume(userVolumes, totalVolume);
        }
    }

    @Override
    public void onSetMixTranscodingConfig(int i, String s) {
        super.onSetMixTranscodingConfig(i, s);
        TRTCLogger.i(TAG, "on set mix transcoding, code:" + i + " msg:" + s);
    }

    public TXBeautyManager getTXBeautyManager() {
        return mTXBeautyManager;
    }

    public void setAudioQuality(int quality) {
        mTRTCCloud.setAudioQuality(quality);
    }

    public void startMicrophone() {
        mTRTCCloud.startLocalAudio();
    }

    public void switchToAnchor(OnSwitchRoleListener listener) {
        mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
        mTRTCCloud.startLocalAudio();
        mOnSwitchRoleListener = listener;
    }

    public void switchToAudience(OnSwitchRoleListener listener) {
        mTRTCCloud.stopLocalAudio();
        mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
        mOnSwitchRoleListener = listener;
    }

    public void stopMicrophone() {
        mTRTCCloud.stopLocalAudio();
    }

    public void setSpeaker(boolean useSpeaker) {
        mTRTCCloud.setAudioRoute(useSpeaker ? TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER : TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
    }

    public void setAudioCaptureVolume(int volume) {
        mTRTCCloud.setAudioCaptureVolume(volume);
    }

    public void setAudioPlayoutVolume(int volume) {
        mTRTCCloud.setAudioPlayoutVolume(volume);
    }

    public void startFileDumping(TRTCCloudDef.TRTCAudioRecordingParams trtcAudioRecordingParams) {
        mTRTCCloud.startAudioRecording(trtcAudioRecordingParams);
    }

    public void stopFileDumping() {
        mTRTCCloud.stopAudioRecording();
    }

    public void enableAudioEvaluation(boolean enable) {
        mTRTCCloud.enableAudioVolumeEvaluation(enable ? 300 : 0);
    }

    public TXAudioEffectManager getAudioEffectManager() {
        return mTRTCCloud.getAudioEffectManager();
    }

    @Override
    public void onSwitchRole(int code, String message) {
        super.onSwitchRole(code, message);
        TRTCLogger.i(TAG, "on switch role, code:" + code + " msg:" + message);
        if (mOnSwitchRoleListener != null) {
            mOnSwitchRoleListener.onTRTCSwitchRole(code, message);
        }
    }

    public interface OnSwitchRoleListener {
        void onTRTCSwitchRole(int code, String message);
    }
}
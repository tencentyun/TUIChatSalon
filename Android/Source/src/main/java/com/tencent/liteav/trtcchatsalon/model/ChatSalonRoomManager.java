package com.tencent.liteav.trtcchatsalon.model;

public class ChatSalonRoomManager {

    private static ChatSalonRoomManager sInstance;
    private RoomCallback mRoomCallback;

    public static ChatSalonRoomManager getInstance() {
        if (sInstance == null) {
            synchronized (ChatSalonRoomManager.class) {
                if (sInstance == null) {
                    sInstance = new ChatSalonRoomManager();
                }
            }
        }
        return sInstance;
    }


    public void addCallback(RoomCallback callback) {
        mRoomCallback = callback;
    }

    public void removeCallback() {
        mRoomCallback = null;
    }

    public void createRoom(int roomId, ActionCallback callback) {
        if (mRoomCallback != null) {
            mRoomCallback.onRoomCreate(roomId, callback);
        }
    }

    public void destroyRoom(int roomId, ActionCallback callback) {
        if (mRoomCallback != null) {
            mRoomCallback.onRoomDestroy(roomId, callback);
        }
    }

    public interface RoomCallback {
        void onRoomCreate(int roomId, ActionCallback callback);
        void onRoomDestroy(int roomId, ActionCallback callback);
    }

    public interface ActionCallback {
        void onSuccess();
        void onError(int errorCode, String message);
    }
}

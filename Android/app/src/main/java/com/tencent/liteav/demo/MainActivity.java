package com.tencent.liteav.demo;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.liteav.basic.IntentUtils;
import com.tencent.liteav.basic.UserModel;
import com.tencent.liteav.basic.UserModelManager;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.trtcchatsalon.model.ChatSalonRoomManager;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalon;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcchatsalon.ui.list.ChatSalonCreateActivity;
import com.tencent.liteav.trtcchatsalon.ui.room.ChatSalonAudienceActivity;
import com.tencent.trtc.TRTCCloudDef;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";

    private Toolbar        mToolbar;
    private EditText       mEditRoomId;
    private TextView       mTextEnterRoom;
    private TRTCChatSalon  mTRTCChatSalon;
    private RelativeLayout mButtonCreateRoom;

    private TextWatcher mEditTextWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            if (!TextUtils.isEmpty(mEditRoomId.getText().toString())) {
                mTextEnterRoom.setEnabled(true);
            } else {
                mTextEnterRoom.setEnabled(false);
            }
        }

        @Override
        public void afterTextChanged(Editable s) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initStatusBar();
        setContentView(R.layout.activity_main);
        initView();
        initData();
    }

    private void initView() {
        findViewById(R.id.btn_link).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/647/53537"));
                IntentUtils.safeStartActivity(MainActivity.this, intent);
            }
        });

        mToolbar = findViewById(R.id.toolbar);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mEditRoomId = findViewById(R.id.et_room_id);
        mEditRoomId.addTextChangedListener(mEditTextWatcher);

        mTextEnterRoom = findViewById(R.id.tv_enter);
        mTextEnterRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                enterRoom(mEditRoomId.getText().toString());
            }
        });

        mButtonCreateRoom = findViewById(R.id.rl_create_room);
        mButtonCreateRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createRoom();
            }
        });
    }

    private void initData() {
        final UserModel userModel = UserModelManager.getInstance().getUserModel();
        mTRTCChatSalon = TRTCChatSalon.sharedInstance(this);
        mTRTCChatSalon.login(GenerateTestUserSig.SDKAPPID, userModel.userId, userModel.userSig,
                new TRTCChatSalonCallback.ActionCallback() {
                    @Override
                    public void onCallback(int code, String msg) {
                        Log.d(TAG, "code: " + code + " msg:" + msg);
                        mTRTCChatSalon.setSelfProfile(userModel.userName, userModel.userAvatar,
                                new TRTCChatSalonCallback.ActionCallback() {
                                    @Override
                                    public void onCallback(int code, String msg) {
                                        if (code == 0) {
                                            Log.d(TAG, "setSelfProfile success");
                                        }
                                    }
                                });
                    }
                });
    }

    private void createRoom() {
        Intent intent = new Intent(MainActivity.this, ChatSalonCreateActivity.class);
        startActivity(intent);
    }

    private void enterRoom(final String roomIdStr) {
        ChatSalonRoomManager.getInstance().getGroupInfo(roomIdStr, new ChatSalonRoomManager.GetGroupInfoCallback() {
            @Override
            public void onSuccess(V2TIMGroupInfoResult result) {
                if (isRoomExist(result)) {
                    realEnterRoom(roomIdStr);
                } else {
                    ToastUtils.showLong(R.string.room_not_exist);
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(msg);
            }
        });
    }

    private void realEnterRoom(String roomIdStr) {
        UserModel userModel = UserModelManager.getInstance().getUserModel();
        String userId = userModel.userId;
        int roomId;
        try {
            roomId = Integer.parseInt(roomIdStr);
        } catch (Exception e) {
            roomId = 10000;
        }
        ChatSalonAudienceActivity.enterRoom(this, roomId, userId, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
    }

    private boolean isRoomExist(V2TIMGroupInfoResult result) {
        if (result == null) {
            Log.e(TAG, "room not exist result is null");
            return false;
        }
        return result.getResultCode() == 0;
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        }
    }
}
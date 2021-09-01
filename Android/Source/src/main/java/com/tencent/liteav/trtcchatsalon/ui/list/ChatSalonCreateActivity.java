package com.tencent.liteav.trtcchatsalon.ui.list;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.basic.UserModelManager;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.ui.utils.StatusBarUtils;
import com.tencent.liteav.trtcchatsalon.ui.room.ChatSalonAnchorActivity;
import com.tencent.trtc.TRTCCloudDef;

/**
 * 创建语聊房页面
 */
public class ChatSalonCreateActivity extends AppCompatActivity {
    private Toolbar      mToolbar;
    private EditText     mRoomNameEt;
    private TextView     mEnterTv;
    private int          MAX_LEN = 30;

    private TextWatcher mEditTextWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            if (!TextUtils.isEmpty(mRoomNameEt.getText().toString())) {
                mEnterTv.setEnabled(true);
            } else {
                mEnterTv.setEnabled(false);
            }
        }

        @Override
        public void afterTextChanged(Editable s) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trtcchatsalon_activity_create_voice_room);
        StatusBarUtils.initStatusBar(this);
        initView();
        initData();
    }

    private void initData() {
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mRoomNameEt.addTextChangedListener(mEditTextWatcher);
        mEnterTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createRoom();
            }
        });
        initThemeAndNickname();
    }

    private void initThemeAndNickname() {
        String userId   = UserModelManager.getInstance().getUserModel().userId;
        String userName = UserModelManager.getInstance().getUserModel().userName;
        String showUserName = !TextUtils.isEmpty(userName) ? userName : userId;
        mRoomNameEt.setText(getString(R.string.trtcchatsalon_create_theme, showUserName));
    }

    private void createRoom() {
        String roomName    = mRoomNameEt.getText().toString();
        String userId      = UserModelManager.getInstance().getUserModel().userId;
        String userAvatar  = UserModelManager.getInstance().getUserModel().userAvatar;
        String coverAvatar = UserModelManager.getInstance().getUserModel().userAvatar;
        String userName = UserModelManager.getInstance().getUserModel().userName;
        if (roomName.getBytes().length > MAX_LEN) {
            ToastUtils.showLong(getText(R.string.trtcchatsalon_warning_room_name_too_long));
            return;
        }
        ChatSalonAnchorActivity.createRoom(this, roomName, userId, userName, userAvatar, coverAvatar, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT, true);
        finish();
    }

    private void initView() {
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mRoomNameEt = (EditText) findViewById(R.id.et_room_name);
        mEnterTv = (TextView) findViewById(R.id.tv_enter);
    }
}

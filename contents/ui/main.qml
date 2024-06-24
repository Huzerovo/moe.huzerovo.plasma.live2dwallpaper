import QtQuick
import QtMultimedia
import org.kde.plasma.plasmoid
import org.kde.notification

import "code/Utils.js" as Utils

WallpaperItem {
    id: root

    property string cfg_filePath: root.configuration.filePath
    onCfg_filePathChanged: {
        if (player) {
            player.source = cfg_filePath;
            player.play()
        }
    }

    property int cfg_fillMode: root.configuration.fillMode
    onCfg_fillModeChanged: {
        if (player) {
            player.fillMode = cfg_fillMode;
        }
    }

    property bool cfg_muteVideo: root.configuration.muteVideo
    onCfg_muteVideoChanged: {
        if (player) {
            player.muted = cfg_muteVideo;
        }
    }

    property int cfg_waitingTime: root.configuration.waitingTime
    property int cfg_maxRetryTimes: root.configuration.maxRetryTimes

    property string plugin_name: i18n("Live2d Wallpaper")
    property int retry_count: 0
    property Video player: null

    function errorHandler(error, errorString) {
        myNotification.notify(i18n("Wallpaper player crashed"));
        Utils.msg_error("\n!!! ERROR !!!");
        Utils.msg_error("Error code: " + error);
        Utils.msg_error("Error string: " + errorString);
        Utils.msg_error("Player object info:");
        Utils.objdump(root.player);
        Utils.msg_error("Wallpaper plugin configuration:");
        Utils.objdump(root.configuration);

        // enable recovery timer
        if (!recoveryTimer.running) {
            recoveryTimer.running = true;
            Utils.msg_error("Recovery timer enabled");
        }

        Utils.msg_error("!!! EEROR END !!!\n");
    }

    function loadVideo() {
        let wallpaperComponent = Qt.createComponent("Wallpaper.qml");
        if (wallpaperComponent.status === Component.Ready) {
            // instance
            root.player = wallpaperComponent.createObject(container);

            // configuration
            root.player.source = cfg_filePath;
            root.player.fillMode = cfg_fillMode;
            root.player.muted = cfg_muteVideo;

            // handler
            root.player.errorOccurred.connect(errorHandler);
            root.player.playing.connect(root.activated);

            root.player.play();
        } else {
            Utils.msg_error("Failed to create video player component: "
                + root.wallpaperComponent.errorString());
            Utils.objdump(root.wallpaperComponent)
        }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "black"
    }

    Timer {
        id: recoveryTimer
        interval: cfg_waitingTime * 1000
        repeat: true
        running: true
        triggeredOnStart: false

        onTriggered: {
            retry_count++;
            
            if (cfg_maxRetryTimes !== 0 && retry_count > cfg_maxRetryTimes) {
                Utils.msg_error("The maximum retries times is reached");
                recoveryTimer.running = false;
                return;
            }

            let count_string;
            if (cfg_maxRetryTimes !== 0) {
                count_string = "(" + retry_count +'/' + cfg_maxRetryTimes + ")"
            } else {
                count_string = "(" + retry_count +"/infinite)"
            }

            Utils.msg_warn("Try to recover..." + count_string)

            if (root.player) {
                root.player.destroy()
                loadVideo()
                Utils.msg_warn("Player reloaded")
            } else {
                Utils.msg_error("Can not get the player");
            }
        }
    }

    // just for debuging
    Timer {
        interval: 5 * 1000
        repeat: false
        running: false
        onTriggered: {
            if (player) {
                player.errorOccurred(0, "Test");
            }
        }
    }

    signal activated()

    onActivated: {
        Utils.msg_info("Wallpaper activated");
        retry_count = 0;
        recoveryTimer.running = false;
        Utils.msg_info("Recovery timer disabled");
    }

    // see also
    // https://api.kde.org/frameworks/knotifications/html/classKNotification.html
    Notification {
        id: myNotification
        title: i18n(root.plugin_name)
        flags: Notification.CloseOnTimeout
        componentName: "plasma_workspace"
        // you can get eventId by `gerp "Event" NOTIFYRC_FILE`
        // where the NOTIFYRC_FILE is chosen from the result of `find` command
        eventId: "warning"
        // you can find the definication at
        // https://api.kde.org/frameworks/knotifications/html/knotification_8h_source.html#l00222
        urgency: Notification.HighUrgency

        function notify(msg){
            myNotification.text = msg
            myNotification.sendEvent()
        }
    }

    Component.onCompleted: {
        Utils.set_plugin_name(root.plugin_name);

        if (cfg_filePath === "") {
            myNotification.notify(i18n("Need to set a wallpaper"));
        } else {
            loadVideo();
        }
    }

    Component.onDestruction: {
        if (root.player) {
            root.player.destroy();
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Dialogs as QQD
import QtMultimedia

import org.kde.plasma.components 3.0 as PC3

import org.kde.kirigami as Kirigami

import "code/Utils.js" as Utils

Kirigami.FormLayout {
    id: configRoot
    property alias cfg_filePath: filePath.text
    property alias cfg_muteVideo: muteVideo.checked
    property alias cfg_videoVolume: videoVolume.value
    property alias cfg_waitingTime: waitingTime.value
    property alias cfg_maxRetryTimes: maxRetryTimes.value
    property alias cfg_fillMode: fillMode.currentIndex
    property alias cfg_enableNotify: enableNotify.checked

    // file path
    RowLayout {
        Kirigami.FormData.label: i18n("Video wallpaper file:")

        QQC.TextField {
            id: filePath
            placeholderText: i18n("No file selected.")
        }

        QQC.Button {
            icon.name: "folder-videos-symbolic"
            text: i18n("Browse")

            onClicked: fileDialogLoader.active = true

            Loader {
                id: fileDialogLoader
                active: false

                sourceComponent: QQD.FileDialog {
                    id: fileDialog
                    nameFilters: [
                        // 我不知道这是不是特性
                        // 但是在我的KDE Plasma 6.0.5，Qt 6.7.1中
                        // 选择文件的窗口里，文件过滤的规则不会显示出来
                        // 用这种奇奇怪怪的方式让它显示
                        i18n("Video files (%1) (%1)", ".mp4"),
                        i18n("All files (%1) (%1)", "*")
                    ]
                    
                    onAccepted: {
                        fileDialogLoader.active = false;
                        cfg_filePath = selectedFile;
                    }

                    onRejected: {
                        fileDialogLoader.active = false;
                    }
                    
                    Component.onCompleted: open()
                }
            }
        }
    }

    // resize wallpaper video
    RowLayout {
        Kirigami.FormData.label: i18n("Positioning:")

        QQC.ComboBox {
            id: fillMode
            textRole: "label"
            
            model: [
                {
                    "label": i18n("Stretch"),
                    "fill_mode": VideoOutput.Stretch
                },
                {
                    "label": i18n("PreserveAspectFit"),
                    "fill_mode": VideoOutput.PreserveAspectFit
                },
                {
                    "label": i18n("PreserveAspectCrop"),
                    "fill_mode": VideoOutput.PreserveAspectCrop
                }
            ]

            onActivated: {
                cfg_fillMode = model[currentIndex]["fill_mode"];
            }

            Component.onCompleted: function () {
                for (var i = 0; i < model.length; i++) {
                    if (model[i]["fill_mode"] == cfg_fillMode) {
                        fillMode.currentIndex = i;
                        break;
                    }
                }
            }
        }
    }

    // mute video
    RowLayout {
        Kirigami.FormData.label: i18n("Mute video:")

        QQC.CheckBox {
            id: muteVideo
            checked: cfg_muteVideo
        }
    }

    // video volume
    RowLayout {
        enabled: !muteVideo.checked
        Kirigami.FormData.label: i18n("Volume:")
        PC3.Slider{
            id: videoVolume
            Layout.fillWidth: true
            from: 0
            to: 100
            value: cfg_videoVolume
            stepSize: 1
        }

        PC3.Label {
            function formatText(value) {
                return i18n("%1%", value)
            }
            text: formatText(videoVolume.value)
        }
    }

    // waiting time
    RowLayout {
        Kirigami.FormData.label: i18n("Waiting time(second):")

        QQC.SpinBox {
            id: waitingTime
            from: 0
            value: cfg_waitingTime
            stepSize: 1
        }
    }

    // times for retrying
    RowLayout {
        Kirigami.FormData.label: i18n("Max retries times:")

        QQC.SpinBox {
            id: maxRetryTimes
            from: 0
            value: cfg_maxRetryTimes
            stepSize: 1
        }
    }

    // enable notify
    RowLayout {
        Kirigami.FormData.label: i18n("Enable notify:")

        QQC.CheckBox {
            id: enableNotify
            checked: cfg_enableNotify
            text: i18n("Enable send notification to workspace")
        }
    }
}

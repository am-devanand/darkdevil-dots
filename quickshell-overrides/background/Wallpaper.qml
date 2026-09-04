pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    property string source: Wallpapers.current
    property CachingImage current
    property bool completed
    property bool isWiping: false
    property real wipeProgress: 0.0
    property Item wipeOldItem

    onSourceChanged: {
        if (!source) {
            current = null;
            return;
        }

        const old = current;
        current = imgComp.createObject(root, { path: source });

        if (old) {
            if (isWiping && wipeOldItem) {
                wipeOldItem.layer.enabled = false;
                wipeOldItem.destroy();
            }

            old.z = 2;
            isWiping = true;
            wipeProgress = 0.0;
            wipeOldItem = old;
            wipeAnim.start();
        }
    }

    Component.onCompleted: {
        if (source)
            Qt.callLater(() => {
                current = imgComp.createObject(root, { path: source });
                completed = true;
            });
    }

    SequentialAnimation {
        id: wipeAnim

        NumberAnimation {
            target: root
            property: "wipeProgress"
            from: 0.0
            to: 1.0
            duration: 2500
            easing.type: Easing.Linear
        }

        ScriptAction {
            script: {
                if (root.wipeOldItem) {
                    root.wipeOldItem.layer.enabled = false;
                    root.wipeOldItem.destroy();
                    root.wipeOldItem = null;
                }
                root.isWiping = false;
            }
        }
    }

    Loader {
        asynchronous: true
        anchors.fill: parent

        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Tokens.spacing.largeIncreased

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.builders.extraLarge.scale(5).build()
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.builders.large.size(28 * 2).weight(Font.Bold).build()
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Tokens.padding.extraLargeIncreased
                        implicitHeight: selectWallText.implicitHeight + Tokens.padding.small

                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary
                            onClicked: dialog.open()
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font: Tokens.font.body.large
                        }
                    }
                }
            }
        }
    }

    Component {
        id: imgComp

        CachingImage {
            id: img

            anchors.fill: parent

            layer.enabled: root.isWiping && root.wipeOldItem === img
            layer.effect: ShaderEffect {
                property real progress: root.wipeProgress

                fragmentShader: "
                    varying highp vec2 qt_TexCoord0;
                    uniform sampler2D source;
                    uniform lowp float qt_Opacity;
                    uniform lowp float progress;

                    void main() {
                        highp vec2 uv = qt_TexCoord0;
                        lowp vec4 color = texture2D(source, uv);
                        highp float diag = ((1.0 - uv.x) + uv.y) / 1.414;
                        lowp float mask = smoothstep(progress - 0.08, progress + 0.08, diag);
                        gl_FragColor = color * qt_Opacity * mask;
                    }
                "
            }
        }
    }
}

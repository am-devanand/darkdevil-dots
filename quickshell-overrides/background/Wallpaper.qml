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

    onSourceChanged: {
        if (!source) {
            current = null;
            return;
        }
        const isTransition = current !== null;
        const obj = imgComp.createObject(this, {
            path: source
        });
        obj.animateIn = isTransition;
        current = obj;
    }

    Component.onCompleted: {
        if (source)
            Qt.callLater(() => {
                current = imgComp.createObject(this, {
                    path: source
                });
                completed = true;
            });
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

            property bool animateIn: false

            anchors.fill: parent

            // Always on: the effect object must exist before any handler touches
            // waveFx (a disabled layer lazily destroys it). At progress 1 the
            // shader is a pure passthrough, so static wallpapers cost one quad.
            layer.enabled: true
            layer.effect: ShaderEffect {
                id: waveFx

                property real progress: 1

                fragmentShader: Qt.resolvedUrl("./wavetransition.frag.qsb")
            }

            onStatusChanged: {
                if (status === Image.Ready) {
                    if (img.animateIn) {
                        waveFx.progress = 0;
                        waveAnim.start();
                    } else {
                        waveFx.progress = 1;
                    }
                }
            }

            NumberAnimation {
                id: waveAnim

                target: waveFx
                property: "progress"
                from: 0
                to: 1
                duration: 1400
                easing.type: Easing.InOutCubic
            }

            Timer {
                running: root.current !== img && root.current?.status === Image.Ready
                interval: waveAnim.duration
                onTriggered: img.destroy()
            }
        }
    }
}

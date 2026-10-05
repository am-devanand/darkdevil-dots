pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property Props props
    required property ScreenState screenState
    readonly property int notifCount: Notifs.list.reduce((acc, n) => n.closed ? acc : acc + 1, 0)

    anchors.fill: parent
    anchors.margins: Tokens.padding.medium

    Component.onCompleted: Notifs.list.forEach(n => n.popup = false)

    Item {
        id: title

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.extraSmall

        implicitHeight: Math.max(titleText.implicitHeight, clearPill.implicitHeight)

        StyledText {
            id: titleText

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: clearPill.left
            anchors.rightMargin: Tokens.spacing.small

            text: qsTr("Notification Center")
            color: Colours.palette.m3onSurface
            font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            elide: Text.ElideRight
        }

        StyledRect {
            id: clearPill

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            implicitWidth: clearIcon.implicitWidth + Tokens.padding.medium * 2
            implicitHeight: clearIcon.implicitHeight + Tokens.padding.extraSmall * 2

            radius: Tokens.rounding.full
            color: Colours.palette.m3errorContainer
            opacity: root.notifCount > 0 ? 1 : 0.4

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }

            MaterialIcon {
                id: clearIcon

                anchors.centerIn: parent
                text: "delete"
                color: Colours.palette.m3onErrorContainer
                fontStyle: Tokens.font.icon.small
            }

            StateLayer {
                radius: parent.radius
                color: Colours.palette.m3onErrorContainer
                disabled: root.notifCount === 0
                onClicked: clearTimer.start()
            }
        }
    }

    ClippingRectangle {
        id: clipRect

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Tokens.spacing.medium

        radius: Tokens.rounding.medium
        color: "transparent"

        Loader {
            asynchronous: true
            anchors.centerIn: parent
            active: opacity > 0
            opacity: root.notifCount > 0 ? 0 : 1

            sourceComponent: ColumnLayout {
                spacing: Tokens.spacing.extraLarge

                Image {
                    asynchronous: true
                    source: Paths.absolutePath(Config.paths.noNotifsPic)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: clipRect.width * 0.8 * ((QsWindow.window as QsWindow)?.devicePixelRatio ?? 1)

                    layer.enabled: true
                    layer.effect: Colouriser {
                        colorizationColor: Colours.palette.m3outlineVariant
                        brightness: 1
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("All up to date!")
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.headline.builders.small.width(90).build()
                }
            }

            Behavior on opacity {
                Anim {
                    type: Anim.StandardExtraLarge
                }
            }
        }

        StyledFlickable {
            id: view

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: notifList.implicitHeight

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: view
            }

            NotifDockList {
                id: notifList

                props: root.props
                screenState: root.screenState
                container: view
            }
        }
    }

    Timer {
        id: clearTimer

        repeat: true
        triggeredOnStart: true
        interval: Math.max(15, Math.min(80, 69.8 - 12.3 * Math.log(Notifs.notClosed.length)))
        onTriggered: {
            const first = Notifs.notClosed[0];
            if (!first) {
                stop();
                return;
            }

            const appName = first.appName;
            let cleared = 0;
            for (const n of Notifs.notClosed.filter(n => n.appName === appName)) {
                n.close();
                cleared++;
                if (cleared > 30) {
                    interval = 5;
                    return;
                }
            }
        }
    }

}

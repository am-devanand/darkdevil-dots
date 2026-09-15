pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Caelestia
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    required property ScreenState screenState

    readonly property real screenW: (QsWindow.window as QsWindow)?.screen.width ?? 1920
    readonly property real screenH: (QsWindow.window as QsWindow)?.screen.height ?? 1080

    implicitWidth: screenW
    implicitHeight: screenH

    // Blurred wallpaper background (wleave look, user's own wallpaper)
    Item {
        anchors.fill: parent

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 32
            blurMultiplier: 1
        }

        Image {
            anchors.fill: parent
            source: Wallpapers.current
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    // Dark tint over blur
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha("#000000", 0.45)
    }

    // Click-away to close (wleave behaviour)
    MouseArea {
        anchors.fill: parent
        onClicked: root.screenState.session = false
    }

    Column {
        anchors.centerIn: parent
        spacing: Tokens.spacing.largeIncreased * 2

        Logo {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72
            height: 72
        }

        Row {
            id: row

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Tokens.spacing.largeIncreased * 5

        SessionIcon {
            id: shutdown

            icon: Config.session.icons.shutdown
            label: "Shutdown"
            key: "S"
            command: Config.session.commands.shutdown

            KeyNavigation.right: reboot
        }

        SessionIcon {
            id: reboot

            icon: Config.session.icons.reboot
            label: "Reboot"
            key: "R"
            command: Config.session.commands.reboot

            KeyNavigation.left: shutdown
            KeyNavigation.right: logout
        }

        SessionIcon {
            id: logout

            icon: Config.session.icons.logout
            label: "Logout"
            key: "X"
            command: Config.session.commands.logout

            KeyNavigation.left: reboot
            KeyNavigation.right: hibernate

            Component.onCompleted: forceActiveFocus()

            Connections {
                function onLauncherChanged(): void {
                    if (!root.screenState.launcher)
                        logout.forceActiveFocus();
                }

                target: root.screenState
            }
        }

        SessionIcon {
            id: hibernate

            icon: "bedtime"
            label: "Hibernate"
            key: "H"
            command: Config.session.commands.hibernate

            KeyNavigation.left: logout
            KeyNavigation.right: lock
        }

        SessionIcon {
            id: lock

            icon: "lock"
            label: "Lock"
            key: "L"
            command: ["loginctl", "lock-session"]

            KeyNavigation.left: hibernate
        }
        }
    }

    component SessionIcon: ButtonBase {
        id: btn

        required property string icon
        required property string label
        required property string key
        required property list<string> command

        function exec(): void {
            if (!SessionManager.exec(command))
                Quickshell.execDetached(command);
        }

        function handleShortcut(event): bool {
            if (event.key === Qt.Key_S) {
                shutdown.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_R) {
                reboot.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_X) {
                logout.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_H) {
                hibernate.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_L) {
                lock.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Escape) {
                root.screenState.session = false;
                event.accepted = true;
                return true;
            }
            return false;
        }

        implicitWidth: 170
        implicitHeight: 200
        type: ButtonBase.Tonal

        // Drive card highlight from keyboard focus / mouse hover
        checked: activeFocus || hovered

        // No idle card, system-color card only on hover/focus (wleave look)
        inactiveColour: "transparent"
        activeColour: Colours.palette.m3primary
        inactiveOnColour: "#ffffff"
        activeOnColour: Colours.palette.m3onPrimary
        radius: Tokens.rounding.extraLarge
        font: Tokens.font.body.small

        // Pop-up scale on selection (like reference)
        scale: (btn.activeFocus || btn.hovered) ? 1.12 : 1
        transformOrigin: Item.Center
        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutBack
            }
        }

        // Single click executes (wleave behaviour)
        onClicked: btn.exec()

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.small
            spacing: Tokens.spacing.small

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 130

                MaterialIcon {
                    anchors.centerIn: parent
                    text: btn.icon
                    color: btn.onColour
                    fill: (btn.activeFocus || btn.hovered) ? 1 : 0
                    fontStyle: Tokens.font.icon.builders.extraLarge.scale(2.0).build()
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: btn.label
                font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                color: btn.onColour
            }
        }

        Keys.onEnterPressed: exec()
        Keys.onReturnPressed: exec()
        Keys.onEscapePressed: root.screenState.session = false
        Keys.onSpacePressed: root.screenState.session = false
        Keys.onPressed: event => {
            if (handleShortcut(event))
                return;
            // Arrow keys always work (not gated behind vim mode)
            if (event.key === Qt.Key_Left && KeyNavigation.left) {
                KeyNavigation.left.focus = true;
                event.accepted = true;
                return;
            } else if (event.key === Qt.Key_Right && KeyNavigation.right) {
                KeyNavigation.right.focus = true;
                event.accepted = true;
                return;
            }
            if (!Config.session.vimKeybinds)
                return;

            if (event.key === Qt.Key_H && KeyNavigation.left) {
                KeyNavigation.left.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_L && KeyNavigation.right) {
                KeyNavigation.right.focus = true;
                event.accepted = true;
            }
        }
    }
}

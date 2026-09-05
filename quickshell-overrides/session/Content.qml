pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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

    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight

    StyledRect {
        id: bg

        anchors.centerIn: parent
        implicitWidth: col.implicitWidth + Tokens.padding.large * 2
        implicitHeight: col.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.extraLarge
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.94)

        Column {
            id: col

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            SessionRow {
                id: reboot

                icon: Config.session.icons.reboot
                label: "Reboot"
                key: "R"
                command: Config.session.commands.reboot

                KeyNavigation.down: logout

                Connections {
                    function onLauncherChanged(): void {
                        if (!root.screenState.launcher)
                            logout.forceActiveFocus();
                    }

                    target: root.screenState
                }
            }

            SessionRow {
                id: logout

                icon: Config.session.icons.logout
                label: "Log Out"
                key: "X"
                command: Config.session.commands.logout

                KeyNavigation.up: reboot
                KeyNavigation.down: poweroff

                Component.onCompleted: forceActiveFocus()
            }

            SessionRow {
                id: poweroff

                icon: Config.session.icons.shutdown
                label: "Power Off"
                key: "P"
                isDanger: true
                command: Config.session.commands.shutdown

                KeyNavigation.up: logout
                KeyNavigation.down: lock
            }

            SessionRow {
                id: lock

                icon: "lock"
                label: "Lock"
                key: "L"
                command: ["loginctl", "lock-session"]

                KeyNavigation.up: poweroff
                KeyNavigation.down: suspend
            }

            SessionRow {
                id: suspend

                icon: "bedtime"
                label: "Suspend"
                key: "S"
                command: ["systemctl", "suspend"]

                KeyNavigation.up: lock
                KeyNavigation.down: restartdms
            }

            SessionRow {
                id: restartdms

                icon: "refresh"
                label: "Restart DMS"
                key: "D"
                command: ["sh", "-c", "qs -c caelestia kill; sleep 0.2; caelestia shell -d"]

                KeyNavigation.up: suspend
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Hold to confirm (500 ms)"
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }

    component SessionRow: ButtonBase {
        id: row

        required property string icon
        required property string label
        required property string key
        required property list<string> command
        property bool isDanger: false
        property int holdMs: 500
        property real holdProgress: 0

        function exec(): void {
            if (!SessionManager.exec(command))
                Quickshell.execDetached(command);
        }

        function handleShortcut(event) : bool {
            if (event.key === Qt.Key_R) {
                reboot.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_X) {
                logout.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_P) {
                poweroff.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_L) {
                lock.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_S) {
                suspend.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_D) {
                restartdms.exec();
                event.accepted = true;
                return true;
            }
            return false;
        }

        implicitWidth: 380
        implicitHeight: 56
        type: ButtonBase.Tonal

        inactiveColour: isDanger ? Qt.alpha(Colours.palette.m3error, activeFocus ? 1 : 0.14) : activeFocus ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer
        activeColour: isDanger ? Colours.palette.m3error : Colours.palette.m3secondaryContainer
        inactiveOnColour: isDanger ? (activeFocus ? Colours.palette.m3onPrimary : Colours.palette.m3error) : activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
        activeOnColour: isDanger ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
        radius: activeFocus ? Tokens.rounding.extraLarge : Tokens.rounding.large
        font: Tokens.font.body.small

        // Hold-to-confirm gates pointer clicks. Keyboard stays instant.
        onClicked: {
            // Single clicks do nothing; hold timer fires exec.
        }
        onPressedChanged: {
            if (row.pressed) {
                row.holdProgress = 0;
                fillAnim.restart();
                holdTimer.restart();
            } else {
                if (holdTimer.running) {
                    holdTimer.stop();
                    fillAnim.stop();
                    row.holdProgress = 0;
                }
            }
        }

        Timer {
            id: holdTimer

            interval: row.holdMs
            onTriggered: row.exec()
        }

        NumberAnimation {
            id: fillAnim

            target: row
            property: "holdProgress"
            from: 0
            to: 1
            duration: row.holdMs
        }

        border.width: activeFocus ? 2 : 0
        border.color: isDanger && activeFocus ? Colours.palette.m3error : Colours.palette.m3primary

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.padding.medium
            anchors.rightMargin: Tokens.padding.medium
            spacing: Tokens.spacing.medium

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: row.icon
                color: row.onColour
                fill: 1
                fontStyle: Tokens.font.icon.builders.medium.scale(1.2).build()
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                text: row.label
                font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                color: row.onColour
            }

            StyledRect {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: keyLabel.implicitWidth + Tokens.padding.small * 2
                implicitHeight: keyLabel.implicitHeight + Tokens.padding.extraSmall
                radius: height / 2
                color: Qt.alpha(row.onColour, row.activeFocus ? 0.22 : 0.1)

                StyledText {
                    id: keyLabel

                    anchors.centerIn: parent
                    text: row.key
                    font: Tokens.font.body.small
                    color: row.onColour
                }
            }
        }

        // Hold progress bar
        StyledRect {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: Tokens.padding.medium
            anchors.rightMargin: Tokens.padding.medium
            anchors.bottomMargin: 6
            implicitHeight: 3
            radius: 2
            color: "transparent"

            StyledRect {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: (parent.width) * row.holdProgress
                implicitHeight: 3
                radius: 2
                color: row.isDanger ? Colours.palette.m3error : Colours.palette.m3primary
                visible: row.holdProgress > 0
            }
        }

        Keys.onEnterPressed: exec()
        Keys.onReturnPressed: exec()
        Keys.onEscapePressed: root.screenState.session = false
        Keys.onPressed: event => {
            if (handleShortcut(event))
                return;
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if ((event.key === Qt.Key_J || event.key === Qt.Key_N) && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if ((event.key === Qt.Key_K || event.key === Qt.Key_P) && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }
    }
}

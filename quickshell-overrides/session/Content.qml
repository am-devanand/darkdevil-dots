pragma ComponentBehavior: Bound

import QtQuick
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

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    Column {
        id: col

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        // Slim glass pill
        StyledRect {
            id: bg

            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: row.implicitWidth + Tokens.padding.large * 2
            implicitHeight: row.implicitHeight + Tokens.padding.medium * 2
            radius: height / 2
            color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.92)

            Row {
                id: row

                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                SessionPill {
                    id: logout

                    icon: Config.session.icons.logout
                    label: "Log Out"
                    hint: "L"
                    command: Config.session.commands.logout

                    KeyNavigation.right: shutdown

                    Component.onCompleted: forceActiveFocus()

                    Connections {
                        function onLauncherChanged(): void {
                            if (!root.screenState.launcher)
                                logout.forceActiveFocus();
                        }

                        target: root.screenState
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 1
                    implicitHeight: 36
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.14)
                }

                SessionPill {
                    id: shutdown

                    icon: Config.session.icons.shutdown
                    label: "Shut Down"
                    hint: "hold S"
                    isConfirm: true
                    isDanger: true
                    command: Config.session.commands.shutdown

                    KeyNavigation.left: logout
                    KeyNavigation.right: hibernate
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 1
                    implicitHeight: 36
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.14)
                }

                SessionPill {
                    id: hibernate

                    icon: Config.session.icons.hibernate
                    label: "Hibernate"
                    hint: "H"
                    command: Config.session.commands.hibernate

                    KeyNavigation.left: shutdown
                    KeyNavigation.right: reboot
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 1
                    implicitHeight: 36
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.14)
                }

                SessionPill {
                    id: reboot

                    icon: Config.session.icons.reboot
                    label: "Reboot"
                    hint: "hold R"
                    isConfirm: true
                    command: Config.session.commands.reboot

                    KeyNavigation.left: hibernate
                }
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "hold click on Shut Down / Reboot to confirm  •  esc closes"
            font: Tokens.font.body.small
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    component SessionPill: ButtonBase {
        id: pill

        required property string icon
        required property string label
        required property string hint
        required property list<string> command
        property bool isDanger: false
        property bool isConfirm: false
        property int holdMs: 900
        property real holdProgress: 0

        function exec(): void {
            if (!SessionManager.exec(command))
                Quickshell.execDetached(command);
        }

        function handleShortcut(event) : bool {
            if (event.key === Qt.Key_L) {
                logout.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_S) {
                shutdown.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_H) {
                hibernate.exec();
                event.accepted = true;
                return true;
            } else if (event.key === Qt.Key_R) {
                reboot.exec();
                event.accepted = true;
                return true;
            }
            return false;
        }

        implicitWidth: 140
        implicitHeight: 60
        type: ButtonBase.Tonal

        inactiveColour: isDanger ? Qt.alpha(Colours.palette.m3error, activeFocus ? 1 : 0.14) : activeFocus ? Colours.palette.m3secondaryContainer : "transparent"
        activeColour: isDanger ? Colours.palette.m3error : Colours.palette.m3secondaryContainer
        inactiveOnColour: isDanger ? (activeFocus ? Colours.palette.m3onPrimary : Colours.palette.m3error) : activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
        activeOnColour: isDanger ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
        radius: height / 2
        font: Tokens.font.body.small

        // Hold-to-confirm only gates pointer clicks. Keyboard stays instant.
        onClicked: {
            if (!pill.isConfirm)
                pill.exec();
        }
        onPressedChanged: {
            if (!pill.isConfirm)
                return;
            if (pill.pressed) {
                pill.holdProgress = 0;
                fillAnim.restart();
                holdTimer.restart();
            } else {
                if (holdTimer.running) {
                    holdTimer.stop();
                    fillAnim.stop();
                    pill.holdProgress = 0;
                }
            }
        }

        Timer {
            id: holdTimer

            interval: pill.holdMs
            onTriggered: pill.exec()
        }

        NumberAnimation {
            id: fillAnim

            target: pill
            property: "holdProgress"
            from: 0
            to: 1
            duration: pill.holdMs
        }

        scale: activeFocus ? 1.05 : hovered ? 1.02 : 1
        Behavior on scale {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        border.width: activeFocus ? 2 : 0
        border.color: isDanger ? Colours.palette.m3error : Colours.palette.m3primary

        Row {
            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: pill.icon
                color: pill.onColour
                fill: 1
                fontStyle: Tokens.font.icon.builders.large.scale(1.25).build()
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                StyledText {
                    text: pill.label
                    font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                    color: pill.onColour
                }

                StyledText {
                    text: pill.hint
                    font: Tokens.font.body.small
                    color: pill.isConfirm && pill.pressed ? pill.onColour : Colours.palette.m3onSurfaceVariant
                }
            }
        }

        // Hold progress bar
        StyledRect {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            implicitWidth: (parent.width - 32) * pill.holdProgress
            implicitHeight: 3
            radius: 2
            color: pill.isDanger ? Colours.palette.m3error : Colours.palette.m3primary
            visible: pill.isConfirm && pill.holdProgress > 0
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
                if ((event.key === Qt.Key_J || event.key === Qt.Key_N) && KeyNavigation.right) {
                    KeyNavigation.right.focus = true;
                    event.accepted = true;
                } else if ((event.key === Qt.Key_K || event.key === Qt.Key_P) && KeyNavigation.left) {
                    KeyNavigation.left.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.right) {
                KeyNavigation.right.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.left) {
                    KeyNavigation.left.focus = true;
                    event.accepted = true;
                }
            }
        }
    }
}

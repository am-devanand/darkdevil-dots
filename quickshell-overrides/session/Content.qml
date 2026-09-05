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

    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight

    // Dark cinematic backdrop
    StyledRect {
        id: bg

        anchors.centerIn: parent
        implicitWidth: col.implicitWidth + Tokens.padding.extraLarge * 2
        implicitHeight: col.implicitHeight + Tokens.padding.extraLarge * 2
        radius: Tokens.rounding.extraLarge
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.92)
    }

    Column {
        id: col

        anchors.centerIn: bg
        spacing: Tokens.spacing.medium

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Power Menu"
            font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            color: Colours.palette.m3onSurface
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "← → navigate  •  L S H R shortcuts  •  esc closes"
            font: Tokens.font.body.small
            color: Colours.palette.m3onSurfaceVariant
        }

        Row {
            id: row

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Tokens.spacing.large

            SessionCard {
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

            SessionCard {
                id: shutdown

                icon: Config.session.icons.shutdown
                label: "Shut Down"
                hint: "S"
                isDanger: true
                command: Config.session.commands.shutdown

                KeyNavigation.left: logout
                KeyNavigation.right: hibernate
            }

            SessionCard {
                id: hibernate

                icon: Config.session.icons.hibernate
                label: "Hibernate"
                hint: "H"
                command: Config.session.commands.hibernate

                KeyNavigation.left: shutdown
                KeyNavigation.right: reboot
            }

            SessionCard {
                id: reboot

                icon: Config.session.icons.reboot
                label: "Reboot"
                hint: "R"
                command: Config.session.commands.reboot

                KeyNavigation.left: hibernate
            }
        }
    }

    component SessionCard: ButtonBase {
        id: card

        required property string icon
        required property string label
        required property string hint
        required property list<string> command
        property bool isDanger: false

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

        implicitWidth: 132
        implicitHeight: 152
        type: ButtonBase.Tonal

        inactiveColour: isDanger ? Qt.alpha(Colours.palette.m3error, activeFocus ? 1 : 0.16) : activeFocus ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer
        activeColour: isDanger ? Colours.palette.m3error : Colours.palette.m3secondaryContainer
        inactiveOnColour: isDanger ? (activeFocus ? Colours.palette.m3onPrimary : Colours.palette.m3error) : activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
        activeOnColour: isDanger ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
        radius: activeFocus ? Tokens.rounding.extraLarge : Tokens.rounding.large
        font: Tokens.font.body.small
        onClicked: exec()

        scale: activeFocus ? 1.06 : hovered ? 1.03 : 1
        Behavior on scale {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        border.width: activeFocus ? 2 : 0
        border.color: isDanger ? Colours.palette.m3error : Colours.palette.m3primary

        Column {
            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.icon
                color: card.onColour
                fill: 1
                fontStyle: Tokens.font.icon.builders.large.scale(1.7).build()
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.label
                font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                color: card.onColour
            }

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: hintLabel.implicitWidth + Tokens.padding.small * 2
                implicitHeight: hintLabel.implicitHeight + Tokens.padding.extraSmall
                radius: height / 2
                color: Qt.alpha(card.onColour, card.activeFocus ? 0.22 : 0.1)

                StyledText {
                    id: hintLabel

                    anchors.centerIn: parent
                    text: card.hint
                    font: Tokens.font.body.small
                    color: card.onColour
                }
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

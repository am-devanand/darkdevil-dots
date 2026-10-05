pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property ScreenState screenState

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer

    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    GridLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.padding.medium
        columns: 4
        rowSpacing: Tokens.spacing.small
        columnSpacing: Tokens.spacing.small

        Toggle {
            icon: "mic"
            checked: !Audio.sourceMuted
            onClicked: {
                const audio = Audio.source?.audio;
                if (audio)
                    audio.muted = !audio.muted;
            }
        }
        Toggle {
            icon: "wifi"
            checked: Nmcli.wifiEnabled
            onClicked: Nmcli.toggleWifi()
        }
        Toggle {
            icon: "bluetooth"
            checked: Bluetooth.defaultAdapter?.enabled ?? false // qmllint disable unresolved-type
            onClicked: {
                const adapter = Bluetooth.defaultAdapter; // qmllint disable unresolved-type
                if (adapter)
                    adapter.enabled = !adapter.enabled;
            }
        }
        Toggle {
            icon: "notifications_off"
            checked: Notifs.dnd
            onClicked: Notifs.dnd = !Notifs.dnd
        }
        Toggle {
            icon: "gamepad"
            checked: GameMode.enabled
            onClicked: GameMode.enabled = !GameMode.enabled
        }
        Toggle {
            icon: "settings"
            isToggle: false
            inactiveOnColour: Colours.palette.m3onSurfaceVariant
            onClicked: {
                root.screenState.sidebar = false;
                WindowFactory.create();
            }
        }
        Toggle {
            icon: "lock"
            isToggle: false
            inactiveOnColour: Colours.palette.m3onSurfaceVariant
            onClicked: {
                root.screenState.sidebar = false;
                Quickshell.execDetached(["loginctl", "lock-session"]);
            }
        }
        Toggle {
            icon: "power_settings_new"
            isToggle: false
            inactiveOnColour: Colours.palette.m3onSurfaceVariant
            onClicked: {
                root.screenState.sidebar = false;
                root.screenState.session = true;
            }
        }
    }

    component Toggle: IconButton {
        Layout.fillWidth: true
        inactiveColour: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
        isToggle: true
        isRound: true
        shapeMorph: true
    }
}

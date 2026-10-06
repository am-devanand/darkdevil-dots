pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus
import qs.modules.bar.popouts as BarPopouts

StyledRect {
    id: root

    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts

    readonly property var quickToggles: {
        const seenIds = new Set();

        return Config.utilities.quickToggles.values.filter(item => {
            if (!item.enabled)
                return false;

            if (seenIds.has(item.id)) {
                return false;
            }

            if (item.id === "vpn") {
                return GlobalConfig.utilities.vpn.selectedProvider.length > 0;
            }

            seenIds.add(item.id);
            return true;
        });
    }
    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    radius: Tokens.rounding.large
    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.65)

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.padding.medium
        spacing: Tokens.spacing.small

        RowLayout {
            visible: UPower.displayDevice !== null
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: Icons.getBatteryIcon(UPower.displayDevice?.percentage ?? 0, !UPower.onBattery)
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                text: `${Math.round((UPower.displayDevice?.percentage ?? 0) * 100)}%`
                color: Colours.palette.m3onSurface
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: Tokens.rounding.full
                color: Qt.alpha(Colours.palette.m3onSurface, 0.15)

                StyledRect {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * (UPower.displayDevice?.percentage ?? 0)
                    radius: parent.radius
                    color: Colours.palette.m3primary
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 4
            rowSpacing: Tokens.spacing.small
            columnSpacing: Tokens.spacing.small

            Repeater {
            model: root.quickToggles

            delegate: DelegateChooser {
                role: "id"

                DelegateChoice {
                    roleValue: "wifi"
                    delegate: Toggle {
                        icon: "wifi"
                        checked: Nmcli.wifiEnabled
                        onClicked: Nmcli.toggleWifi()
                    }
                }
                DelegateChoice {
                    roleValue: "bluetooth"
                    delegate: Toggle {
                        icon: "bluetooth"
                        checked: Bluetooth.defaultAdapter?.enabled ?? false // qmllint disable unresolved-type
                        onClicked: {
                            const adapter = Bluetooth.defaultAdapter; // qmllint disable unresolved-type
                            if (adapter)
                                adapter.enabled = !adapter.enabled;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "mic"
                    delegate: Toggle {
                        icon: "mic"
                        checked: !Audio.sourceMuted
                        onClicked: {
                            const audio = Audio.source?.audio;
                            if (audio)
                                audio.muted = !audio.muted;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "settings"
                    delegate: Toggle {
                        icon: "settings"
                        inactiveOnColour: Colours.palette.m3onSurfaceVariant
                        isToggle: false
                        onClicked: {
                            root.screenState.utilities = false;
                            root.screenState.sidebar = false;
                            WindowFactory.create();
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "gameMode"
                    delegate: Toggle {
                        icon: "gamepad"
                        checked: GameMode.enabled
                        onClicked: GameMode.enabled = !GameMode.enabled
                    }
                }
                DelegateChoice {
                    roleValue: "dnd"
                    delegate: Toggle {
                        icon: "notifications_off"
                        checked: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                }
                DelegateChoice {
                    roleValue: "vpn"
                    delegate: Toggle {
                        icon: "vpn_key"
                        checked: VPN.connected && VPN.status.state !== "needs-auth" && VPN.status.state !== "error"
                        enabled: !VPN.connecting && !VPN.disconnecting
                        isToggle: VPN.status.state !== "needs-auth" && VPN.status.state !== "error"
                        inactiveOnColour: Colours.palette.m3onSurfaceVariant
                        onClicked: VPN.toggle()
                    }
                }
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
    } // end GridLayout
    } // end ColumnLayout

    component Toggle: IconButton {
        Layout.fillWidth: true
        inactiveColour: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
        fillWidth: true
        isToggle: true
        isRound: true
        shapeMorph: true
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

StyledRect {
    id: root

    readonly property var brightnessMonitor: Brightness.getMonitor("active")

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer

    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.padding.medium
        spacing: Tokens.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.small
            }

            StyledSlider {
                Layout.fillWidth: true
                value: Audio.volume
                onInteraction: value => Audio.setVolume(value)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: `brightness_${(Math.round((root.brightnessMonitor?.brightness ?? 0) * 6) + 1)}`
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.small
            }

            StyledSlider {
                Layout.fillWidth: true
                value: root.brightnessMonitor?.brightness ?? 0
                onInteraction: value => root.brightnessMonitor?.setBrightness(value)
            }
        }
    }
}

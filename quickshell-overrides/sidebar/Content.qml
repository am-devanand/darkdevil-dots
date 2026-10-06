import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Props props
    required property ScreenState screenState

    // DarkDevil frosted glass: blurred wallpaper backdrop (compositor blur
    // does not affect the fullscreen drawers layer, so blur in-shell)
    Item {
        anchors.fill: parent

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 28
            blurMultiplier: 1
        }

        Image {
            anchors.fill: parent
            source: Wallpapers.current
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    StyledRect {
        anchors.fill: parent
        color: Qt.alpha(Colours.tPalette.m3surface, 0.3)
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.medium

        MediaCard {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? implicitHeight : 0
            visible: Players.active !== null
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.large
            color: Qt.alpha(Colours.tPalette.m3surfaceContainerLow, 0.65)

            NotifDock {
                objectName: "sidebarNotifications"

                props: root.props
                screenState: root.screenState
            }
        }

        SlidersCard {
            Layout.fillWidth: true
        }
    }
}

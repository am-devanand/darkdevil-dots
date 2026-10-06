import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Props props
    required property ScreenState screenState

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

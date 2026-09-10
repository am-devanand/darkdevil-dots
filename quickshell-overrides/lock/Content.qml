import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

RowLayout {
    id: root

    required property var lock

    spacing: Tokens.spacing.largeIncreased * 2

    ColumnLayout {
        visible: false
        Layout.fillWidth: true
        spacing: Tokens.spacing.medium

        WeatherInfo {
            Layout.fillWidth: true
            rootHeight: root.height
        }

        Fetch {
            Layout.fillWidth: true
            rootHeight: root.height
        }
    }

    Center {
        Layout.alignment: Qt.AlignHCenter

        lock: root.lock
    }

    ColumnLayout {
        visible: false
        Layout.fillWidth: true
        spacing: Tokens.spacing.medium

        Resources {
            Layout.fillWidth: true
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            bottomRightRadius: Tokens.rounding.extraLarge
            radius: Tokens.rounding.medium
            color: Qt.alpha("#ffffff", 0.07)
            border.width: 1
            border.color: Qt.alpha("#ffffff", 0.14)

            NotifDock {
                lock: root.lock
            }
        }
    }
}

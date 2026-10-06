pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Caelestia
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ScreenState screenState
    readonly property Props props: Props {}

    readonly property bool shouldBeActive: screenState.sidebar && Config.sidebar.enabled && !screenState.session
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.rightMargin: (-implicitWidth - 5) * offsetScale
    implicitWidth: Tokens.sizes.sidebar.width
    opacity: 1 - offsetScale

    // DarkDevil frosted glass over the whole panel incl. margins (covers the
    // blob region so no raw surface shows at the panel edge)
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

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: Tokens.padding.large
        anchors.margins: CUtils.clamp(anchors.leftMargin - Config.border.thickness, 0, anchors.leftMargin)
        anchors.bottomMargin: 0

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            implicitWidth: Tokens.sizes.sidebar.width - content.anchors.leftMargin - content.anchors.margins
            props: root.props
            screenState: root.screenState
        }
    }
}

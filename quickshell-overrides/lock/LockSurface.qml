pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.components.images
import qs.services
import qs.utils

WlSessionLockSurface {
    id: root

    required property WlSessionLock lock
    required property Pam pam

    readonly property alias unlocking: unlockAnim.running

    contentItem.Config.screen: screen.name
    contentItem.Tokens.screen: screen.name

    color: "transparent"

    Connections {
        function onUnlock(): void {
            unlockAnim.start();
        }

        target: root.lock
    }

    // DarkDevil: replay the background settle on every lock
    Connections {
        function onLockedChanged(): void {
            if (root.lock.locked) {
                settleAnim.restart();
                contentEnterAnim.restart();
            }
        }

        target: root.lock
    }

    SequentialAnimation {
        id: unlockAnim

        ParallelAnimation {
            Anim {
                target: lockContent
                properties: "implicitWidth,implicitHeight"
                to: lockContent.size
            }
            Anim {
                target: lockBg
                property: "radius"
                to: lockContent.radius
            }
            Anim {
                target: content
                property: "scale"
                to: 0
            }
            Anim {
                target: content
                property: "opacity"
                to: 0
                type: Anim.StandardSmall
            }
            Anim {
                target: lockIcon
                property: "opacity"
                to: 1
                type: Anim.StandardLarge
            }
            Anim {
                target: background
                property: "opacity"
                to: 0
                type: Anim.StandardLarge
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: Tokens.anim.durations.small
                }
                Anim {
                    type: Anim.Standard
                    target: lockContent
                    property: "opacity"
                    to: 0
                }
            }
        }
        PropertyAction {
            target: root.lock
            property: "locked"
            value: false
        }
    }

    // DarkDevil: background settle, replayed on every lock
    Anim {
        id: settleAnim

        target: background
        property: "scale"
        from: 1.06
        to: 1
        type: Anim.SlowEffects
    }

    // DarkDevil: content entrance, replayed on every lock
    ParallelAnimation {
        id: contentEnterAnim

        Anim {
            target: content
            property: "scale"
            from: 0.96
            to: 1
            type: Anim.FastSpatial
        }
        Anim {
            target: content
            property: "opacity"
            from: 0
            to: 1
            type: Anim.StandardSmall
        }
    }

    ParallelAnimation {
        id: initAnim

        running: true

        Anim {
            target: background
            property: "opacity"
            to: 1
            type: Anim.StandardLarge
        }
        // DarkDevil: slow Ken Burns settle on the background
        Anim {
            target: background
            property: "scale"
            from: 1.06
            to: 1
            type: Anim.SlowEffects
        }
        SequentialAnimation {
            ParallelAnimation {
                Anim {
                    target: lockContent
                    property: "scale"
                    to: 1
                    type: Anim.FastSpatial
                }
                Anim {
                    target: lockContent
                    property: "rotation"
                    to: 360
                    duration: Tokens.anim.durations.expressiveFastSpatial
                    easing: Tokens.anim.standardAccel
                }
            }
            ParallelAnimation {
                Anim {
                    target: lockIcon
                    property: "rotation"
                    to: 360
                    easing: Tokens.anim.standardDecel
                }
                Anim {
                    type: Anim.DefaultEffects
                    target: lockIcon
                    property: "opacity"
                    to: 0
                }
                Anim {
                    type: Anim.DefaultEffects
                    target: content
                    property: "opacity"
                    to: 1
                }
                Anim {
                    target: content
                    property: "scale"
                    to: 1
                }
                Anim {
                    target: lockBg
                    property: "radius"
                    to: lockContent.Tokens.rounding.extraLarge * 1.5
                }
                Anim {
                    target: lockContent
                    property: "implicitWidth"
                    to: (root.screen?.height ?? 0) * lockContent.Tokens.sizes.lock.heightMult * lockContent.Tokens.sizes.lock.ratio
                }
                Anim {
                    target: lockContent
                    property: "implicitHeight"
                    to: (root.screen?.height ?? 0) * lockContent.Tokens.sizes.lock.heightMult
                }
            }
        }
    }

    Item {
        id: background

        anchors.fill: parent
        opacity: 0

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 28
            blurMultiplier: 1
        }

        Loader {
            anchors.fill: parent
            sourceComponent: Config.lock.useWallpaper ? wallpaperBackground : screencopyBackground
        }

        // DarkDevil glass: diagonal scrim gradient over the blurred
        // background. Wallpaper stays visible through it.
        Rectangle {
            anchors.fill: parent
            // Default vertical gradient: dark corners, light middle
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.alpha(Colours.palette.m3scrim, 0.62)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.alpha(Colours.palette.m3scrim, 0.13)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.alpha(Colours.palette.m3scrim, 0.66)
                }
            }
        }

        // Glass top-light streak
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.height * 0.28
            // Default vertical gradient (no orientation enum on this Qt)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.alpha("#ffffff", 0.07)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.alpha("#ffffff", 0.0)
                }
            }
        }

    }

    // DarkDevil glass specular streak: crisp diagonal light band above
    // the blurred background (outside the blur layer so it stays sharp)
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            // Swapped dims + -108° rotation: default vertical gradient
            // runs along the band length (no orientation enum on this Qt)
            width: Math.max(parent.height * 0.2, 150)
            height: parent.width * 1.5
            rotation: -108
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.alpha("#ffffff", 0.0)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.alpha("#ffffff", 0.17)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.alpha("#ffffff", 0.0)
                }
            }
        }

        // Second thinner companion streak for a richer glass reflection
        Rectangle {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -parent.height * 0.18
            width: Math.max(parent.height * 0.07, 60)
            height: parent.width * 1.5
            rotation: -108
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.alpha("#ffffff", 0.0)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.alpha("#ffffff", 0.12)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.alpha("#ffffff", 0.0)
                }
            }
        }
    }

    Component {
        id: screencopyBackground

        ScreencopyView {
            captureSource: root.screen
        }
    }

    Component {
        id: wallpaperBackground

        CachingImage {
            path: Wallpapers.current
        }
    }

    // DarkDevil editorial rails: giant vertical month + day on the edges
    Item {
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.verticalCenter: parent.verticalCenter
        width: 200
        height: 700

        Text {
            anchors.centerIn: parent
            rotation: -90
            text: Time.format("MMMM").toUpperCase()
            color: Qt.alpha("#ffffff", 0.26)
            font: Tokens.font.headline.builders.large.scale(5).width(30).weight(Font.Light).build()
        }
    }

    Item {
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.verticalCenter: parent.verticalCenter
        width: 200
        height: 700

        Text {
            anchors.centerIn: parent
            rotation: 90
            text: Time.format("dd")
            color: Qt.alpha("#ffffff", 0.26)
            font: Tokens.font.headline.builders.large.scale(5).width(30).weight(Font.Light).build()
        }
    }

    // DarkDevil status chips: old-dashboard essentials, no bulk
    StyledRect {
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        implicitWidth: battText.implicitWidth + Tokens.padding.large * 2
        implicitHeight: battText.implicitHeight + Tokens.padding.medium * 2
        radius: height / 2
        color: Qt.alpha("#ffffff", 0.07)
        border.width: 1
        border.color: Qt.alpha("#ffffff", 0.14)

        StyledText {
            id: battText

            anchors.centerIn: parent
            text: {
                const pct = Math.round(UPower.displayDevice.percentage * 100);
                const charging = [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state);
                return `BATT ${pct}%${charging ? " +" : ""}  •  UP ${SysInfo.uptime}`;
            }
            color: Colours.palette.m3onSurface
            font: Tokens.font.body.small
        }
    }

    StyledRect {
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        implicitWidth: wxText.implicitWidth + Tokens.padding.large * 2
        implicitHeight: wxText.implicitHeight + Tokens.padding.medium * 2
        radius: height / 2
        color: Qt.alpha("#ffffff", 0.07)
        border.width: 1
        border.color: Qt.alpha("#ffffff", 0.14)

        StyledText {
            id: wxText

            anchors.centerIn: parent
            text: `${Weather.temp} • ${Weather.description}`
            color: Colours.palette.m3onSurface
            font: Tokens.font.body.small
        }
    }

    StyledRect {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        implicitWidth: notifText.implicitWidth + Tokens.padding.large * 2
        implicitHeight: notifText.implicitHeight + Tokens.padding.medium * 2
        radius: height / 2
        color: Qt.alpha("#ffffff", 0.07)
        border.width: 1
        border.color: Qt.alpha("#ffffff", 0.14)
        visible: !Config.lock.hideNotifs && Notifs.list.length > 0

        StyledText {
            id: notifText

            anchors.centerIn: parent
            text: `${Notifs.list.length} NOTIFICATION${Notifs.list.length === 1 ? "" : "S"}`
            color: Colours.palette.m3onSurface
            font: Tokens.font.body.small
        }
    }

    Item {
        id: lockContent

        readonly property int size: lockIcon.implicitHeight + Tokens.padding.large * 4
        readonly property int radius: size / 4 * Tokens.rounding.scale

        anchors.centerIn: parent
        implicitWidth: size
        implicitHeight: size

        visible: Config.lock.enabled
        rotation: 180
        scale: 0

        StyledRect {
            id: lockBg

            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            opacity: Colours.transparency.enabled ? Colours.transparency.base : 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
            }
        }

        MaterialIcon {
            id: lockIcon

            anchors.centerIn: parent
            text: "lock"
            fontStyle: Tokens.font.icon.builders.extraLarge.scale(4).weight(Font.Bold).build()
            rotation: 180
        }

        Content {
            id: content

            anchors.centerIn: parent
            width: (root.screen?.height ?? 0) * Tokens.sizes.lock.heightMult * Tokens.sizes.lock.ratio - Tokens.padding.extraLargeIncreased
            height: (root.screen?.height ?? 0) * Tokens.sizes.lock.heightMult - Tokens.padding.extraLargeIncreased

            lock: root
            opacity: 0
            scale: 0
        }
    }
}

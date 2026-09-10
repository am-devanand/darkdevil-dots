import QtQuick
import QtQuick.Shapes
import qs.services

Item {
    id: root

    readonly property real designWidth: 128
    readonly property real designHeight: 128

    property color hornColour: "#FFD700"
    property color flameColour: "#FF6B00"

    // Backward compat aliases
    property alias topColour: root.flameColour
    property alias bottomColour: root.hornColour

    implicitWidth: designWidth
    implicitHeight: designHeight

    Shape {
        anchors.centerIn: parent
        width: root.designWidth
        height: root.designHeight
        scale: Math.min(root.width / width, root.height / height)
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        // Left horn
        ShapePath {
            fillColor: root.hornColour
            strokeColor: "transparent"

            PathSvg {
                path: "M 32 68 L 16 16 L 48 56 Z"
            }
        }

        // Left flame tip
        ShapePath {
            fillColor: root.flameColour
            strokeColor: "transparent"

            PathSvg {
                path: "M 16 16 C 14 10 22 4 26 12 C 28 6 34 8 32 16 L 26 12 Z"
            }
        }

        // Right horn
        ShapePath {
            fillColor: root.hornColour
            strokeColor: "transparent"

            PathSvg {
                path: "M 96 68 L 112 16 L 80 56 Z"
            }
        }

        // Right flame tip
        ShapePath {
            fillColor: root.flameColour
            strokeColor: "transparent"

            PathSvg {
                path: "M 112 16 C 114 10 106 4 102 12 C 100 6 94 8 96 16 L 102 12 Z"
            }
        }

        // Bottom V / chin connector
        ShapePath {
            fillColor: root.hornColour
            strokeColor: "transparent"

            PathSvg {
                path: "M 32 68 L 64 100 L 96 68 Z"
            }
        }
    }
}

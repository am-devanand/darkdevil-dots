pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    visible: Players.active !== null

    radius: Tokens.rounding.large
    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.65)

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
            spacing: Tokens.spacing.medium

            StyledClippingRect {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignTop

                radius: Tokens.rounding.medium

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "music_note"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.medium
                }

                Image {
                    anchors.fill: parent
                    source: Players.active ? Players.getArtUrl(Players.active) : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    visible: status === Image.Ready
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: Players.active?.trackTitle || qsTr("Nothing playing")
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Players.active?.trackArtist || qsTr("Unknown artist")
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }
        }

        ButtonRow {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            IconButton {
                type: IconButton.Tonal
                icon: "shuffle"
                isRound: true
                shapeMorph: true
                checked: Players.active?.shuffle ?? false
                font: Tokens.font.icon.builders.medium.weight(Font.Medium).build()
                disabled: !Players.active?.shuffleSupported
                onClicked: Players.active.shuffle = !Players.active?.shuffle
                implicitWidth: Math.round(implicitHeight * 0.9)
            }

            IconButton {
                type: IconButton.Tonal
                icon: "skip_previous"
                isRound: true
                shapeMorph: true
                font: Tokens.font.icon.large
                disabled: !Players.active?.canGoPrevious
                onClicked: Players.active?.previous()
            }

            IconButton {
                icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                isRound: true
                shapeMorph: true
                fillWidth: true
                checked: Players.active?.isPlaying ?? false
                font: Tokens.font.icon.large
                disabled: !Players.active?.canTogglePlaying
                onClicked: Players.active?.togglePlaying()
            }

            IconButton {
                type: IconButton.Tonal
                icon: "skip_next"
                isRound: true
                shapeMorph: true
                font: Tokens.font.icon.large
                disabled: !Players.active?.canGoNext
                onClicked: Players.active?.next()
            }

            IconButton {
                type: IconButton.Tonal
                icon: Players.active?.loopState === MprisLoopState.Track ? "repeat_one" : "repeat"
                isRound: true
                shapeMorph: true
                checked: Players.active?.loopState === MprisLoopState.Track || Players.active?.loopState === MprisLoopState.Playlist
                font: Tokens.font.icon.builders.medium.weight(Font.Medium).build()
                disabled: !Players.active?.loopSupported
                onClicked: {
                    const state = Players.active.loopState;
                    if (state === MprisLoopState.None)
                        Players.active.loopState = MprisLoopState.Track;
                    else if (state === MprisLoopState.Track)
                        Players.active.loopState = MprisLoopState.Playlist;
                    else
                        Players.active.loopState = MprisLoopState.None;
                }
                implicitWidth: Math.round(implicitHeight * 0.9)
            }
        }
    }
}

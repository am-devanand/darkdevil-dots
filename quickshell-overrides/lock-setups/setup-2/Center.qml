import "center"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.Services
import Quickshell.Services.UPower
import qs.components
import qs.services

ColumnLayout {
    id: root

    required property var lock
    readonly property real centerScale: Math.min(1, (lock.screen?.height ?? 1440) / 1440)
    readonly property int centerWidth: Tokens.sizes.lock.centerWidth * centerScale

    Layout.preferredWidth: centerWidth
    Layout.fillWidth: false
    Layout.fillHeight: true

    spacing: Tokens.spacing.largeIncreased

    Item {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: mast.implicitWidth
        implicitHeight: mast.implicitHeight

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 3
            text: "DARKDEVIL"
            color: Qt.alpha("#000000", 0.65)
            font: Tokens.font.headline.builders.large.scale(3.8 * root.centerScale).width(30).weight(Font.Bold).build()
        }

        Text {
            id: mast

            anchors.centerIn: parent
            text: "DARKDEVIL"
            color: Qt.alpha("#ffffff", 0.92)
            style: Text.Outline
            styleColor: Qt.alpha("#ffffff", 0.55)
            font: Tokens.font.headline.builders.large.scale(3.8 * root.centerScale).width(30).weight(Font.Bold).build()
        }
    }

    Clock {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Tokens.padding.large
        centerScale: root.centerScale
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter

        text: {
            const now = new Date();
            const onejan = new Date(now.getFullYear(), 0, 1);
            const week = Math.ceil((((now - onejan) / 86400000) + onejan.getDay() + 1) / 7);
            return `${Time.format("dddd • d MMM").toUpperCase()} • W${week}`;
        }
        color: Colours.palette.m3onSurface
        font: Tokens.font.title.builders.medium.weight(Font.DemiBold).build()
    }

    PasswordInput {
        Layout.alignment: Qt.AlignHCenter
        centerScale: Math.max(0.8, root.centerScale)
        centerWidth: root.centerWidth
        lock: root.lock
    }

    StateMessage {
        Layout.fillWidth: true
        pam: root.lock.pam
    }

    Media {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.medium
        lock: root.lock
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.large
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: {
            const quotes = [
                ["The impediment to action advances action. What stands in the way becomes the way.", "Marcus Aurelius"],
                ["You must understand that there is more than one path to the top of the mountain.", "Miyamoto Musashi"],
                ["Be water, my friend.", "Bruce Lee"],
                ["We suffer more often in imagination than in reality.", "Seneca"],
                ["Great things come from hard work and perseverance.", "Kobe Bryant"],
                ["Everyone has a plan until they get punched in the mouth.", "Mike Tyson"],
                ["It is not what happens to you, but how you react to it that matters.", "Epictetus"],
                ["Victorious warriors win first and then go to war.", "Sun Tzu"],
                ["He who has a why to live can bear almost any how.", "Friedrich Nietzsche"],
                ["Do not count the days, make the days count.", "Muhammad Ali"],
                ["The hero and the coward both feel the same thing. The hero uses his fear.", "Cus D'Amato"],
                ["Stay hard.", "David Goggins"]
            ];
            const now = new Date();
            const start = new Date(now.getFullYear(), 0, 1);
            const doy = Math.floor((now - start) / 86400000);
            const q = quotes[doy % quotes.length];
            return `\u201C${q[0]}\u201D — ${q[1]}`;
        }
        color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.75)
        font: Tokens.font.body.small
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Tokens.spacing.extraSmall
        text: {
            const now = new Date();
            const y = now.getFullYear();
            const start = new Date(y, 0, 1);
            const doy = Math.floor((now - start) / 86400000) + 1;
            const total = ((y % 4 === 0 && y % 100 !== 0) || y % 400 === 0) ? 366 : 365;
            return `${y} • ${Math.round(doy / total * 100)}% • DAY ${doy}`;
        }
        color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.55)
        font: Tokens.font.body.small
    }
}

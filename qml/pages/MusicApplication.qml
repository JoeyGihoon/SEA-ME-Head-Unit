import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQml 2.15
import QtQml.Models 2.15
import QtMultimedia 5.15

Item {
    id: musicApplication
    property bool showControls: false
    property int currentTrack: -1
    signal backRequested()

    function norm(u) {
        if (!u) return ""
        u = "" + u            // QUrl/QString → string
        if (u.startsWith("file://")) u = u.replace("file://", "")
        if (u.indexOf('%') !== -1) {  // 퍼센트 인코딩된 경우만 decode
            try { u = decodeURIComponent(u) } catch(e) {}
        }
        return u
    }

    // ===== 상단 바 =====
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: "#041c2e"
        anchors.top: parent.top

        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "Music Player"
            color: "#dbe3ee"
            font.family: "Roboto"
            font.pixelSize: 32
        }

        Image {
            id: frontButton_grey
            width: 40; height: 40
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/qml/images/right_origin.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Item {
            id: backButton
            width: 40; height: 40
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: backIcon
                anchors.centerIn: parent
                source: "qrc:/qml/images/left_green.png"
                width: 40; height: 40
                fillMode: Image.PreserveAspectFit
                opacity: mouseArea.pressed ? 0.6 : (mouseArea.containsMouse ? 0.85 : 1.0)
                scale: mouseArea.pressed ? 0.92 : 1.0
                smooth: true
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    var view = musicApplication.parent
                    if (view && view.pop) view.pop()
                    else musicApplication.backRequested()
                }
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // ===== 상단 바 아래의 실제 컨텐츠 영역 =====
    Item {
        id: contentArea
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // 오디오 플레이어 (상태에 따라 컨트롤바 노출)
        Audio {
            id: audioPlayer
            autoPlay: false
            onPlaybackStateChanged: showControls = (playbackState !== Audio.StoppedState)

            onSourceChanged: {
                var u = norm(audioPlayer.source)
                for (var i = 0; i < trackModel.count; ++i) {
                    if (norm(trackModel.get(i).url) === u) { currentTrack = i; break }
                }
            }
        }

        // 배경 커버이미지 (상단바 아래로)
        Image {
            id: coverArt
            width: 450; height: 450
            anchors.top: topBar.bottom
            anchors.topMargin: 200
            anchors.left: parent.left
            anchors.leftMargin: 100

            source: {
                var c = (currentTrack >= 0 && currentTrack < trackModel.count)
                         ? trackModel.get(currentTrack).cover : ""
                if (!c || c.length === 0) return "qrc:/qml/images/m5logo.png"
                return c.startsWith("file:") ? c : "file://" + c
            }
            onStatusChanged: console.log("[cover] status", status, "src:", source)
            // 0: Null, 1: Ready, 2: Loading, 3: Error
            asynchronous: true
            cache: false
            fillMode: Image.PreserveAspectFit
        }

        // 트랙 모델
        ListModel { id: trackModel }

        // UsbScanner → 모델 채우기
        Connections {
            target: usbScanner
            function onTracksChanged() {
                trackModel.clear()
                for (var i = 0; i < usbScanner.trackUrls.length; ++i) {
                    trackModel.append({
                        title: usbScanner.trackNames[i] || ("Track " + (i+1)),
                        url:   usbScanner.trackUrls[i],
                        // 선택 전엔 기본 로고로
                        cover: "qrc:/qml/images/m5logo.png"
                    })
                }
                if (trackModel.count > 0) currentTrack = 0;   // ✅ 중요: 초기 선택
            }
        }

        Component.onCompleted: {
            console.log("MusicApplication loaded, forcing rescan...")
            if (usbScanner && usbScanner.rescanMountedUsb)
                usbScanner.rescanMountedUsb()
        }

        Connections {
            target: imageExtract
            function onExtractionFinished(filePath, imageUrl) {
                var fp  = norm(filePath)
                var img = imageUrl.toString()

                var hit = -1
                for (var i = 0; i < trackModel.count; ++i) {
                    if (norm("" + trackModel.get(i).url) === fp) { hit = i; break }
                }
                if (hit >= 0) {
                    trackModel.setProperty(hit, "cover", img)
                    if (currentTrack === -1) currentTrack = hit   // ✅ 선택없으면 이번 트랙으로
                }
            }
        }

        // 오른쪽 리스트 패널 (상단바 아래, 컨트롤바 위)
        Rectangle {
            id: listPanel
            width: Math.min(parent.width * 0.38, 420)
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: controlBar.top
            anchors.margins: 12
            color: "#1b2330aa"
            radius: 12

            ListView {
                id: trackList
                anchors.fill: parent
                clip: true
                model: trackModel
                delegate: Item {
                    width: trackList.width
                    height: 52

                    Rectangle {
                        anchors.fill: parent
                        color: mouse.pressed ? "#2b3a50" : "transparent"
                    }

                    Text {
                        text: title
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        elide: Text.ElideRight
                        color: "white"
                        font.pixelSize: 18
                        width: parent.width - 100
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        onClicked: {
                            if (!url || url.toString().length === 0) return
                            currentTrack = index
                            audioPlayer.source = url
                            audioPlayer.play()
                            imageExtract.requestCoverForFile(url.toString().replace("file://",""))
                        }
                    }
                }
            }

            // 빈 목록 안내
            Label {
                visible: trackModel.count === 0
                anchors.centerIn: parent
                text: "Please Insert USB with mp3 files"
                color: "#d0d7e2"
                font.pixelSize: 16
            }
        }

        // 하단 컨트롤바 (상단바 아래의 영역에서만 높이 애니메이션)
        Rectangle {
            id: controlBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: showControls ? 84 : 0
            Behavior on height { NumberAnimation { duration: 160 } }
            color: "#0e1624dd"

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Row {
                    id: infoRow
                    width: parent.width          // ✅ 부모로부터 폭을 '고정'받아 루프 차단
                    spacing: 12

                    Button {
                        id: toggleBtn
                        text: audioPlayer.playbackState === Audio.PlayingState ? "Pause" : "Play"
                        onClicked: {
                            if (audioPlayer.playbackState === Audio.PlayingState) audioPlayer.pause()
                            else audioPlayer.play()
                        }
                    }

                    Text {
                        id: currentTitle
                        // Row의 폭은 이제 고정값이므로 안전하게 계산 가능
                        width: infoRow.width - toggleBtn.implicitWidth - 40
                        elide: Text.ElideRight
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            if (currentTrack >= 0 && currentTrack < trackModel.count) {
                                var t = trackModel.get(currentTrack).title
                                return (t && t.length) ? t : baseName(trackModel.get(currentTrack).url)
                            }
                            var u = norm(audioPlayer.source)
                            for (var i=0; i<trackModel.count; ++i) {
                                if (norm(trackModel.get(i).url) === u) return trackModel.get(i).title
                            }
                            return ""
                        }
                    }
                }

                Slider {
                    id: progress
                    from: 0
                    to: audioPlayer.duration
                    value: audioPlayer.position
                    onMoved: audioPlayer.position = value
                    width: parent.width
                }

                Row {
                    width: parent.width
                    spacing: 8
                    Text { text: msToStr(audioPlayer.position); color: "#cfd6e4" }
                    Text { text: " / "; color: "#cfd6e4" }
                    Text { text: msToStr(audioPlayer.duration); color: "#cfd6e4" }
                }
            }
        }
    }

    function msToStr(ms) {
        if (!ms || ms <= 0) return "00:00"
        var s = Math.floor(ms / 1000)
        var m = Math.floor(s / 60)
        var r = s % 60
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }
    // 감시 기반이라 컴포넌트 완료 시 강제 rescan()은 필요 없음
    // (이미 main.cpp에서 usbScanner.rescanMountedUsb() 한 번 호출을 권장)
}

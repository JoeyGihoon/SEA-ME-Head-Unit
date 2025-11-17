// YoutubeApplication.qml
// Qt5 + QtWebEngine(1.x) 기준. HU의 StackView에 push해서 전체 화면처럼 띄워 쓰는 용도.
// youtubeController (C++ QObject) 가 QML 컨텍스트에 등록되어 있다고 가정.
//   - Q_INVOKABLE QString getYoutubeHtml()
//   - Q_INVOKABLE QString getYoutubeHtmlForRank(int rank)
//
// 기능 요약:
//  - 상단 바(뒤로가기) + "YouTube" 타이틀
//  - 1~10위 인기영상 rank 탐색(Prev/Next, 숫자 직접 입력)
//  - WebEngineView로 data:URL 로드 (HTML은 youtubeController에서 생성)
//  - 컨텍스트 미연결/오류 시 폴백 HTML 표시
//  - 로딩 인디케이터 & 키보드 ←/→ 로 순위 이동

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.7
import QtGraphicalEffects 1.0

Item {
    id: root
    width: 1024
    height: 600

    // ===== 외부로 보내는 시그널 (StackView.pop 등에 연결)
    signal backRequested()
    signal loadVideo(int index)  // 동영상 로드 신호

    // ===== 상태/설정 =====
    property int  rank: 1               // 1~10 사이 유지
    property bool isLoading: false
    property bool controllerAvailable: typeof youtubeController !== "undefined" && youtubeController !== null

    // ===== 유틸: rank 보정 =====
    function clampRank(v) {
        if (v < 1)  return 1;
        if (v > 10) return 10;
        return v;
    }

    // ===== 유틸: 컨트롤러 호출 래퍼 (폴백 내장) =====
    function htmlForRank(r) {
        try {
            if (controllerAvailable && youtubeController.getYoutubeHtmlForRank) {
                return youtubeController.getYoutubeHtmlForRank(r);
            }
        } catch(e) {
            // 아래 폴백으로 이동
        }
        // 폴백: 컨텍스트가 없거나 예외 발생 시 간단한 안내 페이지
        return "<!doctype html><html><head><meta charset='utf-8'><title>YouTube</title>" +
               "<style>body{background:#0b1a2a;color:#dbe3ee;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0}" +
               ".card{background:#13283f;border:1px solid #27415e;border-radius:12px;padding:24px;max-width:720px;text-align:center}" +
               "code{background:#0b1a2a;padding:2px 6px;border-radius:6px;border:1px solid #27415e}" +
               "</style></head><body><div class='card'>" +
               "<h2>youtubeController 미연결</h2>" +
               "<p>QML 컨텍스트에 <code>youtubeController</code> 를 등록해주세요.</p>" +
               "<p>예) <code>engine.rootContext()->setContextProperty(\"youtubeController\", &yt);</code></p>" +
               "<p>또는 getYoutubeHtmlForRank(int)를 확인하세요.</p>" +
               "</div></body></html>";
    }

    function loadCurrentRank() {
        root.isLoading = true
        try {
            if (root.controllerAvailable && youtubeController.getMostPopularVideoId) {
                var vid = youtubeController.getMostPopularVideoId(root.rank);
                if (vid && vid.length > 0) {
                    web.url = embedUrlById(vid);
                    return;
                }
            }
        } catch(e) { /* 폴백으로 진행 */ }
        // 폴백(컨트롤러 없거나 실패 시)
        web.url = "https://m.youtube.com";
    }

    // ===== 상단 바 =====
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: "#041c2e"
        anchors.top: parent.top

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
                        var view = root.parent
                        if (view && view.pop) {
                            view.pop()
                        } else {
                            root.backRequested()
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Text{
                id: youtubepage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "Youtube"
                color: "#dbe3ee"
                font.family: "Roboto"       // 예: Roboto, Noto Sans, Open Sans 등
                font.pixelSize: 32
            }

            Image {
                id: frontButton_grey
                width: 40; height: 40
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:qml/images/right_origin.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            // Item { Layout.fillWidth: true }

            // 순위 입력(1~10)
            // SpinBox {
            //     id: rankBox
            //     from: 1
            //     to: 10
            //     value: root.rank
            //     editable: true
            //     onValueModified: {
            //         root.rank = clampRank(value);
            //     }
            //     anchors.right: parent.right
            //     anchors.left: parent.left
            //     anchors.leftMargin: 850
            // }

            // Button {
            //     text: "Prev"
            //     onClicked: root.rank = clampRank(root.rank - 1)
            // }
            // Button {
            //     text: "Next"
            //     onClicked: root.rank = clampRank(root.rank + 1)
            // }

    }

    // ===== 본문 영역 =====
    Rectangle {
        id: contentArea
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, parent.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#041c2e" }
                GradientStop { position: 0.5; color: "white" }
                GradientStop { position: 1.0; color: "#041c2e" }
            }
        }

        // 로딩 스피너
        BusyIndicator {
            id: spinner
            running: root.isLoading
            visible: running
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
        }

        WebEngineProfile {
            id: profile
            storageName: "YTProfile"
            persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
            httpCacheType: WebEngineProfile.DiskHttpCache
        }

        WebEngineView {
            id: web
            anchors.fill: parent
            anchors.margins: 12
            profile: profile

            // 초기 & rank 변경시마다 로드
            onLoadingChanged: {
                if (loadRequest.status === WebEngineLoadRequest.LoadStartedStatus)
                    root.isLoading = true;
                if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus ||
                    loadRequest.status === WebEngineLoadRequest.LoadFailedStatus)
                    root.isLoading = false;
            }
        }

        // rank 바뀔 때마다 HTML 재적용
        onVisibleChanged: if (visible) loadCurrentRank()
        Component.onCompleted: {
            loadCurrentRank()
            YouTube.refreshTrending("KR", 10)
        }

        Connections {
            target: root
            // onRankChanged: loadCurrentRank()
            function onRankChanged() { loadCurrentRank() }
        }

        // function loadCurrentRank() {
        //     root.isLoading = true
        //     // data:URL + encodeURIComponent 로 안전하게 전달
        //     var html = htmlForRank(root.rank)
        //     web.url = "data:text/html;charset=utf-8," + encodeURIComponent(html)
        // }

        // 키보드 ←/→ 로 rank 이동
        Keys.onLeftPressed:  root.rank = clampRank(root.rank - 1)
        Keys.onRightPressed: root.rank = clampRank(root.rank + 1)
        focus: true
    }
}


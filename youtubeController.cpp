#include "youtubeController.h"

YoutubeController::YoutubeController(QObject *parent) : QObject(parent) {
    apiKey = "AIzaSyCB6BR7fk93W-1qOiHORaPNHS_lyFrubkA";
}

QString YoutubeController::getYoutubeHtml() const {
    return R"(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>YouTube 인기 동영상</title>
    <script>
        async function fetchPopularVideos() {
            const apiKey = 'AIzaSyCB6BR7fk93W-1qOiHORaPNHS_lyFrubkA';
            const response = await fetch(`https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=10&key=${apiKey}&regionCode=KR`);
            const data = await response.json();
            const videos = data.items;

            const body = document.body;
            videos.forEach(video => {
                const videoId = video.id;
                const iframe = document.createElement('iframe');
                iframe.width = 720;
                iframe.height = 405;
                iframe.src = `https://www.youtube.com/embed/${videoId}`;
                iframe.frameBorder = 0;
                iframe.allowFullscreen = true;
                body.appendChild(iframe);
            });
        }

        window.onload = fetchPopularVideos;
    </script>
</head>
<body>
</body>
</html>
        )";
}

QString YoutubeController::getYoutubeHtmlForRank(int rank) const {
    if (rank < 1 || rank > 10) {
        return "<p>Invalid rank. Please choose a rank from 1 to 10.</p>";
    }

    return QString(R"(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>YouTube 인기 동영상</title>
    <style>
        html, body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            width: 100%
            height: 100%
            display: flex;
            align-items: center;
            justify-content: center;
        }
        iframe {
            width: 100vw;
            height: 100vh;
            border: none;
        }
    </style>
    <script>
        async function fetchVideoForRank(rank) {
            const apiKey = 'AIzaSyCB6BR7fk93W-1qOiHORaPNHS_lyFrubkA';
            const response = await fetch(`https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=10&key=${apiKey}&regionCode=KR`);
            const data = await response.json();
            const videos = data.items;

            const body = document.body;
            if (rank >= 1 && rank <= videos.length) {
                const video = videos[rank - 1];
                const videoId = video.id;
                const iframe = document.createElement('iframe');
                iframe.width = 640;
                iframe.height = 360;
                iframe.src = `https://www.youtube.com/embed/${videoId}`;
                iframe.frameBorder = 0;
                iframe.allowFullscreen = true;
                body.appendChild(iframe);
            } else {
                body.innerHTML = '<p>해당 순위의 동영상을 찾을 수 없습니다.</p>';
            }
        }

        window.onload = () => fetchVideoForRank(%1);
    </script>
</head>
<body>
</body>
</html>
    )").arg(rank);
}


// #include "youtubeController.h"

// #include <QUrl>
// #include <QUrlQuery>
// #include <QNetworkRequest>
// #include <QNetworkReply>
// #include <QJsonDocument>
// #include <QJsonObject>
// #include <QJsonArray>
// #include <memory>

// YoutubeController::YoutubeController(QObject *parent)
//     : QObject(parent)
// {
//     // 보안상 권장: 환경변수로 API 키 공급
//     m_apiKey = QString::fromUtf8(qgetenv("YOUTUBE_API_KEY"));
//     // (필요 시 설정 파일/명령행 인자로 대체 가능)
// }

// void YoutubeController::refreshTrending(const QString &regionCode, int maxResults)
// {
//     if (m_apiKey.isEmpty()) {
//         emit errorOccured(QStringLiteral("YouTube API key is missing (env YOUTUBE_API_KEY)."));
//         return;
//     }

//     QUrl url(QStringLiteral("https://www.googleapis.com/youtube/v3/videos"));
//     QUrlQuery q;
//     q.addQueryItem(QStringLiteral("part"),  QStringLiteral("snippet,contentDetails,statistics"));
//     q.addQueryItem(QStringLiteral("chart"), QStringLiteral("mostPopular"));
//     q.addQueryItem(QStringLiteral("maxResults"), QString::number(maxResults));
//     q.addQueryItem(QStringLiteral("regionCode"), regionCode);
//     q.addQueryItem(QStringLiteral("key"), m_apiKey);
//     url.setQuery(q);

//     QNetworkRequest req(url);
//     auto *reply = m_net.get(req);
//     connect(reply, &QNetworkReply::finished, this, [this, reply]() { handleTrendingReply(reply); });
// }

// void YoutubeController::handleTrendingReply(QNetworkReply *reply)
// {
//     const std::unique_ptr<QNetworkReply, void(*)(QNetworkReply*)> guard(reply, [](QNetworkReply* r){ r->deleteLater(); });

//     if (reply->error() != QNetworkReply::NoError) {
//         emit errorOccured(reply->errorString());
//         return;
//     }

//     const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
//     const QJsonObject root = doc.object();
//     const QJsonArray items = root.value(QStringLiteral("items")).toArray();

//     QVariantList out;
//     out.reserve(items.size());

//     for (const auto &it : items) {
//         const QJsonObject obj = it.toObject();
//         const QString id = obj.value(QStringLiteral("id")).toString();
//         const QJsonObject sn = obj.value(QStringLiteral("snippet")).toObject();
//         const QJsonObject st = obj.value(QStringLiteral("statistics")).toObject();

//         const QJsonObject thumbs = sn.value(QStringLiteral("thumbnails")).toObject();
//         const QString maxres = thumbs.value(QStringLiteral("maxres")).toObject().value(QStringLiteral("url")).toString();
//         const QString high   = thumbs.value(QStringLiteral("high")).toObject().value(QStringLiteral("url")).toString();
//         const QString deflt  = thumbs.value(QStringLiteral("default")).toObject().value(QStringLiteral("url")).toString();

//         QVariantMap row;
//         row.insert(QStringLiteral("videoId"), id);
//         row.insert(QStringLiteral("title"), sn.value(QStringLiteral("title")).toString());
//         row.insert(QStringLiteral("channel"), sn.value(QStringLiteral("channelTitle")).toString());
//         row.insert(QStringLiteral("publishedAt"), sn.value(QStringLiteral("publishedAt")).toString());
//         row.insert(QStringLiteral("thumbnail"), !maxres.isEmpty() ? maxres : (!high.isEmpty() ? high : deflt));
//         row.insert(QStringLiteral("views"), st.value(QStringLiteral("viewCount")).toString());

//         out.push_back(row);
//     }

//     m_trending = out;
//     emit trendingChanged();
// }

// // === 핵심: QML에서 기존처럼 rank만 던져도 동작 ===
// QString YoutubeController::getYoutubeHtmlForRank(int rank) const
// {
//     // 1) 최신 트렌딩이 캐시되어 있으면 그것을 우선 사용
//     // rank는 1-based 로 들어온다고 가정 → 0-based로 보정
//     const int idx = rank - 1;
//     if (idx >= 0 && idx < m_trending.size()) {
//         const QVariantMap row = m_trending.at(idx).toMap();
//         const QString vid = row.value(QStringLiteral("videoId")).toString();
//         if (!vid.isEmpty())
//             return makeEmbedHtmlFromVideoId(vid);
//     }

//     // 2) 폴백: 네 기존 레거시 구현을 그대로 사용
//     //    (아래 함수 본문에 "기존 코드"를 그대로 붙여 넣어 유지하세요)
//     return legacyHtmlForRank(rank);
// }

// // youtube-nocookie 임베드 HTML (쿠키/동의 화면 최소화 + iframe 전용 URL)
// QString YoutubeController::makeEmbedHtmlFromVideoId(const QString &videoId) const
// {
//     static const char *TPL =
//         "<!DOCTYPE html><html><head><meta charset='utf-8'>"
//         "<meta name='viewport' content='width=device-width, initial-scale=1'>"
//         "<style>html,body{margin:0;padding:0;height:100%;overflow:hidden}"
//         "#p{position:fixed;inset:0;border:0;width:100vw;height:100vh}</style>"
//         "</head><body>"
//         "<iframe id='p' "
//         "src='https://www.youtube-nocookie.com/embed/%1?autoplay=1&rel=0&modestbranding=1&playsinline=1' "
//         "allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share' "
//         "allowfullscreen></iframe>"
//         "</body></html>";
//     return QString::fromUtf8(TPL).arg(videoId);
// }

// // --- 여기엔 "네가 기존에 쓰던 rank 기반 HTML 생성 코드"를 그대로 둡니다 ---
// // 예: switch(rank) { case 1: return "<html>...</html>"; ... }
// // 또는 기존에 갖고 있던 watch/embed 템플릿 로직 그대로 유지
// QString YoutubeController::legacyHtmlForRank(int rank) const
// {
//     // 🔴 여기에 너의 기존 구현 본문을 그대로 남겨두세요.
//         return R"(
//     <!DOCTYPE html>
//     <html>
//     <head>
//         <meta charset="UTF-8">
//         <meta http-equiv="X-UA-Compatible" content="IE=edge">
//         <title>YouTube 인기 동영상</title>
//         <script>
//             async function fetchPopularVideos() {
//                 const apiKey = 'AIzaSyCB6BR7fk93W-1qOiHORaPNHS_lyFrubkA';
//                 const response = await fetch(`https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=10&key=${apiKey}&regionCode=KR`);
//                 const data = await response.json();
//                 const videos = data.items;

//                 const body = document.body;
//                 videos.forEach(video => {
//                     const videoId = video.id;
//                     const iframe = document.createElement('iframe');
//                     iframe.width = 720;
//                     iframe.height = 405;
//                     iframe.src = `https://www.youtube.com/embed/${videoId}`;
//                     iframe.frameBorder = 0;
//                     iframe.allowFullscreen = true;
//                     body.appendChild(iframe);
//                 });
//             }

//             window.onload = fetchPopularVideos;
//         </script>
//     </head>
//     <body>
//     </body>
//     </html>
//             )";
//     // 임시 기본값 (캐시도 없고 레거시도 없다면 빈 페이지)
//     return QStringLiteral("<html><body style='background:#0b2236;color:#cdd7e3;font-family:sans-serif'>"
//                           "<div style='display:flex;align-items:center;justify-content:center;height:100vh'>"
//                           "No video for this rank.</div></body></html>");
// }

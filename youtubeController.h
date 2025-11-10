#ifndef YOUTUBECONTROLLER_H
#define YOUTUBECONTROLLER_H

#include <QObject>

class YoutubeController : public QObject {
    Q_OBJECT
public:
    explicit YoutubeController(QObject *parent = nullptr);

    Q_INVOKABLE QString getYoutubeHtml() const;
    Q_INVOKABLE QString getYoutubeHtmlForRank(int rank) const;

private:
    QString apiKey;
};

#endif // YOUTUBECONTROLLER_H
// #pragma once
// #include <QObject>
// #include <QVariant>
// #include <QNetworkAccessManager>

// class QNetworkReply;

// class YoutubeController : public QObject
// {
//     Q_OBJECT
//     // 필요하면 QML에서 목록 자체도 바인딩할 수 있도록 공개. (기존 QML이 안 쓰면 무시됨)
//     Q_PROPERTY(QVariantList trending READ trending NOTIFY trendingChanged)

// public:
//     explicit YoutubeController(QObject *parent = nullptr);

//     // === 기존 인터페이스 유지 ===
//     Q_INVOKABLE QString getYoutubeHtmlForRank(int rank) const;

//     // === 신규 (캐시 채우기용) ===
//     Q_INVOKABLE void refreshTrending(const QString &regionCode = "DE", int maxResults = 10);

//     QVariantList trending() const { return m_trending; }

// signals:
//     void trendingChanged();
//     void errorOccured(const QString &message);

// private:
//     void handleTrendingReply(QNetworkReply *reply);
//     QString makeEmbedHtmlFromVideoId(const QString &videoId) const;

//     // --- 레거시 폴백: 네 기존 구현을 여기로 그대로 남겨두면 됨 ---
//     QString legacyHtmlForRank(int rank) const; // 본문은 cpp에 "네 기존 코드 그대로" 유지

// private:
//     QNetworkAccessManager m_net;
//     QString m_apiKey;
//     QVariantList m_trending; // [{ videoId, title, ... }, ...]
// };

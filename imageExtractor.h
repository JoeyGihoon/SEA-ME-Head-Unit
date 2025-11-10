#ifndef IMAGEEXTRACTOR_H
#define IMAGEEXTRACTOR_H

#pragma once
#include <QObject>
#include <QUrl>
#include <QDir>
#include <QProcess>
#include <QScopedPointer>

class ImageExtract : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl coverImageUrl READ coverImageUrl NOTIFY coverImageUrlChanged)

public:
    explicit ImageExtract(QObject* parent = nullptr);

    // 추출기 설정: 예) setExtractorCommand("python3", {"/usr/bin/extract_cover.py", "--in", "%IN%", "--out", "%OUT%"});
    Q_INVOKABLE void setExtractorCommand(const QString& program, const QStringList& defaultArgs = {});

    // mp3 파일 경로를 넘기면: 캐시 있으면 바로 사용, 없으면 비동기 추출
    Q_INVOKABLE void requestCoverForFile(const QString& filePath);

    // 상태 초기화
    Q_INVOKABLE void clear();

    QUrl coverImageUrl() const { return m_coverImageUrl; }

signals:
    void coverImageUrlChanged();
    void extractionStarted(const QString& filePath);
    void extractionFinished(const QString& filePath, const QUrl& imageUrl);
    void extractionFailed(const QString& filePath, const QString& reason);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus status);
    void onProcessError(QProcess::ProcessError error);

private:
    QString cacheDirPath() const;                  // 캐시 디렉터리 경로(~/.cache/sea_me_covers)
    QString cachePathFor(const QString& mp3Path) const; // mp3 고유 캐시 파일 경로
    bool ensureCacheDir() const;                   // 캐시 디렉터리 생성

    QUrl m_coverImageUrl;
    QString m_program;
    QStringList m_defaultArgs;

    mutable QDir m_cacheDir;
    QScopedPointer<QProcess> m_proc;
    QString m_pendingFilePath;                     // 현재 처리 중인 mp3
};

#endif // IMAGEEXTRACTOR_H

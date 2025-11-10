#ifndef USBSCANNER_H
#define USBSCANNER_H

#pragma once
#include <QObject>
#include <QStringList>
#include <QUrl>
#include <QFileSystemWatcher>

class UsbScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList trackNames READ trackNames NOTIFY tracksChanged)
    Q_PROPERTY(QList<QUrl> trackUrls   READ trackUrls   NOTIFY tracksChanged)

public:
    explicit UsbScanner(QObject* parent = nullptr);

    QStringList trackNames() const { return m_trackNames; }
    QList<QUrl> trackUrls()  const { return m_trackUrls;  }

    // 필요시 수동 재스캔(장착된 이동식 디스크만 대상)
    Q_INVOKABLE void rescanMountedUsb();

signals:
    void tracksChanged();
    void scanningStarted(const QString& root);
    void scanningFinished(const QString& root, int count);
    void scanningFailed(const QString& reason);

private slots:
    void onRootDirChanged(const QString& path);

private:
    void initWatchRoots();                   // /run/media, /media, /media/$USER 등록
    void scanMountRoot(const QString& root); // 특정 마운트 루트만 스캔
    static bool isMp3Path(const QString& path);

private:
    QStringList m_trackNames;
    QList<QUrl> m_trackUrls;

    QFileSystemWatcher m_watcher;
    QStringList m_watchRoots;                // 감시 중인 루트들
};

#endif // USBSCANNER_H

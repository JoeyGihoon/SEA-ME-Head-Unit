#include "usbscanner.h"

#include <QStorageInfo>
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QSet>
#include <QFile>
#include <QTextStream>
#include <QDebug>

static QString userMediaRoot()
{
    const char* u = qgetenv("USER").constData();
    return u && *u ? QString("/media/%1").arg(QString::fromUtf8(u)) : QString();
}

static QStringList candidatePrefixDirs()
{
    const QString user = qEnvironmentVariable("USER");
    QStringList dirs;
    if (!user.isEmpty()) {
        dirs << QStringLiteral("/media/%1").arg(user);
        dirs << QStringLiteral("/run/media/%1").arg(user);
    }
    dirs << QStringLiteral("/media");
    dirs << QStringLiteral("/run/media");
    return dirs;
}

UsbScanner::UsbScanner(QObject* parent)
    : QObject(parent)
{
    initWatchRoots();

    // 초기 상태에서 이미 장착된 USB가 있다면 한 번만 스캔
    rescanMountedUsb();

    // watcher signal 연결(헤더에서 m_watcher 선언되어 있다고 가정)
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged,
            this, &UsbScanner::onRootDirChanged);
}

void UsbScanner::initWatchRoots() {
    m_watchRoots.clear();

    // 1) QStorageInfo에서 마운트된 볼륨 중 /media 또는 /run/media 계열 경로를 후보로 추가
    const auto vols = QStorageInfo::mountedVolumes();
    for (const QStorageInfo &si : vols) {
        if (!si.isValid() || !si.isReady()) continue;
        const QString root = si.rootPath();
        if (root.isEmpty()) continue;

        // Qt5 용 대안: root 경로가 /media 또는 /run/media 하위여야 후보로 간주
        if (root.startsWith("/media") || root.startsWith("/run/media")) {
            // (선택) 장치명이 /dev/sd* 인 경우만 더 신뢰
            const QString dev = QString::fromUtf8(si.device());
            if (dev.startsWith("/dev/sd") || dev.startsWith("/dev/mmcblk") || dev.startsWith("/dev/nvme"))
                m_watchRoots << root;
            else
                m_watchRoots << root; // 장치명 기준을 더 엄격히 하고 싶지 않으면 이 줄 유지
        }
    }

    // 2) /proc/mounts 폴백: 데스크탑/데몬 환경 차이로 마운트 정보가 위에서 안 잡힐 수 있음
    QFile mounts("/proc/mounts");
    if (mounts.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream ts(&mounts);
        while (!ts.atEnd()) {
            const QString line = ts.readLine();
            const QStringList parts = line.split(' ', Qt::SkipEmptyParts);
            if (parts.size() < 2) continue;
            const QString src = parts.at(0);   // 예: /dev/sdb1
            const QString tgt = parts.at(1);   // 예: /media/gihoon/USB_DRIVE
            if ((src.startsWith("/dev/sd") || src.startsWith("/dev/mmcblk") || src.startsWith("/dev/nvme"))
                && (tgt.startsWith("/media") || tgt.startsWith("/run/media"))
                && QDir(tgt).exists()) {
                m_watchRoots << tgt;
            }
        }
    }

    // 3) 사용자/시스템 후보 디렉터리 자체도 감시
    const QStringList prefixes = candidatePrefixDirs();
    for (const QString &p : prefixes) {
        if (QDir(p).exists())
            m_watchRoots << p;
    }

    m_watchRoots.removeDuplicates();

    // qDebug() << "[UsbScanner] watchRoots:" << m_watchRoots;

    // QFileSystemWatcher에 경로 추가
    for (const QString &root : m_watchRoots) {
        if (!m_watcher.directories().contains(root))
            m_watcher.addPath(root);
    }
}


void UsbScanner::onRootDirChanged(const QString& path)
{
    // 특정 루트에 변화가 있을 때 그 루트만 스캔
    // QFileSystemWatcher는 상위 디렉터리(예: /media) 변경도 줄 수 있으므로,
    // 변경된 경로 하위에 실제 마운트 포인트들이 있는지 검사해서 스캔.
    QDir d(path);
    if (!d.exists()) return;

    // 만약 변경된 것이 실제 마운트 포인트라면 직접 스캔
    // (예: /media/gihoon/USB_DRIVE)
    if (QStorageInfo(path).isValid() && QStorageInfo(path).isReady()) {
        scanMountRoot(path);
        return;
    }

    // 그렇지 않으면 하위 디렉터리들을 후보로 스캔(예: /media 의 하위)
    const QFileInfoList subs = d.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &fi : subs) {
        const QString subPath = fi.absoluteFilePath();
        if (QStorageInfo(subPath).isValid() && QStorageInfo(subPath).isReady()) {
            scanMountRoot(subPath);
        } else {
            // 한 단계 더 내려가서 체크 (ex: /media/<user>/<label>)
            QDir d2(subPath);
            const QFileInfoList subs2 = d2.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
            for (const QFileInfo &fi2 : subs2) {
                const QString maybeMount = fi2.absoluteFilePath();
                if (QStorageInfo(maybeMount).isValid() && QStorageInfo(maybeMount).isReady())
                    scanMountRoot(maybeMount);
            }
        }
    }
}

void UsbScanner::rescanMountedUsb()
{
    const auto vols = QStorageInfo::mountedVolumes();
    QSet<QString> rootsToScan;

    // qDebug() << "[UsbScanner] rootsToScan:" << rootsToScan.toList();

    for (const QStorageInfo& v : vols) {
        if (!v.isValid() || !v.isReady()) continue;

        const QString root = v.rootPath();
        // Qt5에는 isRemovable()이 없음 → 경로 기반으로 필터
        if (!root.startsWith("/media") && !root.startsWith("/run/media"))
            continue;

        // (선택) 장치명이 /dev/sd* 형태인 경우만 포함
        const QString dev = QString::fromUtf8(v.device());
        if (!dev.startsWith("/dev/sd") && !dev.startsWith("/dev/mmcblk") && !dev.startsWith("/dev/nvme"))
            continue;

        // rootsToScan에 root 자체를 넣음
        rootsToScan.insert(root);
    }

    // 만약 위에서 못 찾았으면 /proc/mounts 폴백으로도 시도
    if (rootsToScan.isEmpty()) {
        QFile mounts("/proc/mounts");
        if (mounts.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream ts(&mounts);
            while (!ts.atEnd()) {
                const QString line = ts.readLine();
                const QStringList parts = line.split(' ', Qt::SkipEmptyParts);
                if (parts.size() < 2) continue;
                const QString src = parts.at(0);
                const QString tgt = parts.at(1);
                if ((src.startsWith("/dev/sd") || src.startsWith("/dev/mmcblk") || src.startsWith("/dev/nvme"))
                    && (tgt.startsWith("/media") || tgt.startsWith("/run/media"))
                    && QDir(tgt).exists()) {
                    rootsToScan.insert(tgt);
                }
            }
        }
    }

    if (rootsToScan.isEmpty()) {
        // m_trackNames.clear();
        // m_trackUrls.clear();
        // emit tracksChanged();
        return;
    }

    for (const QString& r : rootsToScan)
        scanMountRoot(r);
}

void UsbScanner::scanMountRoot(const QString& root)
{
    emit scanningStarted(root);

    QStringList newNames;
    QList<QUrl>  newUrls;

    // 루트는 /media, /run/media, /media/<user> 중 하나여야 함
    QDir rootDir(root);
    if (!rootDir.exists()) {
        // 경로가 없으면 바로 리턴
        m_trackNames = newNames;
        m_trackUrls  = newUrls;
        emit tracksChanged();
        emit scanningFinished(root, 0);
        return;
    }

    const QFileInfoList entries = rootDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);

    // 후보 마운트 포인트 목록 만들기
    QStringList candidateMounts;

    QStorageInfo stRoot(root);
    if (stRoot.isValid() && stRoot.isReady()
        && (root.startsWith("/media") || root.startsWith("/run/media"))) {
        candidateMounts << root;   // ← 이 한 줄이 최상위 mp3를 잡아준다
    }

    // 1) 바로 하위 디렉터리를 후보에 추가
    for (const QFileInfo& e : entries)
        candidateMounts << e.absoluteFilePath();

    // 2) /media 처럼 사용자 폴더가 한 단계 더 있는 경우(예: /media/pi/XXXX)
    for (const QString& cand : candidateMounts) {
        QDir d(cand);
        if (!d.exists()) continue;
        const auto subDirs = d.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QFileInfo& sub : subDirs) {
            // 중첩 후보도 추가
            if (!candidateMounts.contains(sub.absoluteFilePath()))
                candidateMounts << sub.absoluteFilePath();
        }
    }

    // 후보들 중 실제로 "준비된" 마운트만 선별해서 *.mp3 재귀 탐색
    for (const QString& mp : candidateMounts) {
        QStorageInfo st(mp);
        if (!st.isValid() || !st.isReady())
            continue;

        // Qt5 대안 필터:
        if (!mp.startsWith("/media") && !mp.startsWith("/run/media"))
            continue;

        const QString dev = QString::fromUtf8(st.device());
        if (!dev.startsWith("/dev/sd") && !dev.startsWith("/dev/mmcblk") && !dev.startsWith("/dev/nvme"))
            continue;

        // 이 마운트 포인트 내부만 재귀 탐색 (*.mp3)
        QDirIterator it(mp, QStringList() << "*.mp3" << "*.MP3",
                        QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString filePath = it.next();
            if (!isMp3Path(filePath)) continue;

            const QFileInfo fi(filePath);
            const QUrl url = QUrl::fromLocalFile(fi.absoluteFilePath());
            if (!url.isValid()) continue;

            qDebug() << "[UsbScanner] found file candidate:" << filePath;

            newNames << fi.completeBaseName();
            newUrls  << url;
        }
    }

    // qDebug() << "[UsbScanner] scanning root:" << root;
    // qDebug() << "[UsbScanner] candidateMounts:" << candidateMounts;

    m_trackNames = newNames;
    m_trackUrls  = newUrls;
    emit tracksChanged();
    emit scanningFinished(root, m_trackUrls.size());
}


bool UsbScanner::isMp3Path(const QString& path)
{
    const QString ext = QFileInfo(path).suffix().toLower();
    return (ext == "mp3");
}

#include "imageExtractor.h"

#include <QFileInfo>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <QFile>

namespace {
// 필요하면 qrc 기본 이미지로 교체하세요.
const QUrl kFallbackCover = QUrl("qrc:/qml/images/m5logo.png");
}

ImageExtract::ImageExtract(QObject* parent)         // 기본 캐시 디렉터리 설정
    : QObject(parent)
{
    m_cacheDir = QDir(cacheDirPath());
}

void ImageExtract::setExtractorCommand(const QString& program, const QStringList& defaultArgs)
{
    m_program = program;
    m_defaultArgs = defaultArgs;
}

void ImageExtract::clear()                          // 상태 초기화
{
    m_coverImageUrl = QUrl();
    emit coverImageUrlChanged();
    m_pendingFilePath.clear();
}

QString ImageExtract::cacheDirPath() const          // 데이터가 쌓일 경로 생성
{
    // Qt5/Qt6 모두 호환: AppDataLocation이 없으면 Home 하위 .cache 로 대체
    QString base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (base.isEmpty())
        base = QDir::homePath() + "/.cache";
    return QDir(base).filePath("sea_me_covers");
}

bool ImageExtract::ensureCacheDir() const           // 실제 캐시 경로가 있는지 판단
{
    if (!m_cacheDir.exists())
        return QDir().mkpath(m_cacheDir.path());
    return true;
}

QString ImageExtract::cachePathFor(const QString& mp3Path) const        // 이미지의 캐시 파일명 결정
{
    QFileInfo fi(mp3Path);          // QFileInfo는 주어진 경로에 대한 메타정보(파일명, 확장자, 절대경로 등)를 다루는 Qt 클래스.
    const QByteArray key = QCryptographicHash::hash(fi.absoluteFilePath().toUtf8(), QCryptographicHash::Sha1).toHex();  //Sha1 알고리즘으로 해싱
    const QString base = fi.completeBaseName();  // 파일명(확장자 제외)
    // 충돌 최소화를 위해 파일명 + 해시를 함께 사용
    return m_cacheDir.filePath(QString("%1_%2.png").arg(base, QString::fromLatin1(key)));
}

void ImageExtract::requestCoverForFile(const QString& filePath)         // 이미지 추출 명령
{
    if (filePath.isEmpty()) {       // filePath input이 잘못되었을 때
        m_coverImageUrl = kFallbackCover;
        emit coverImageUrlChanged();
        emit extractionFailed(filePath, QStringLiteral("Empty file path"));
        return;
    }

    if (!ensureCacheDir()) {        // 캐시 경로가 잘못되어 있을 때
        m_coverImageUrl = kFallbackCover;
        emit coverImageUrlChanged();
        emit extractionFailed(filePath, QStringLiteral("Failed to create cache directory"));
        return;
    }

    const QString outPath = cachePathFor(filePath);

    // 1) 캐시 히트: 즉시 사용
    QFileInfo outInfo(outPath);
    if (outInfo.exists() && outInfo.size() > 0) {
        m_coverImageUrl = QUrl::fromLocalFile(outPath);
        emit coverImageUrlChanged();
        emit extractionFinished(filePath, m_coverImageUrl);
        return;
    }

    // 2) 추출기 미설정 시 즉시 실패 처리(기본 이미지로 대체)
    if (m_program.isEmpty()) {
        m_coverImageUrl = kFallbackCover;
        emit coverImageUrlChanged();
        emit extractionFailed(filePath, QStringLiteral("Extractor command is not configured"));
        return;
    }

    // 3) 비동기 추출 시작
    if (!m_proc) {
        m_proc.reset(new QProcess(this));
        connect(m_proc.data(), SIGNAL(finished(int,QProcess::ExitStatus)),
                this, SLOT(onProcessFinished(int,QProcess::ExitStatus)));
        connect(m_proc.data(), SIGNAL(errorOccurred(QProcess::ProcessError)),
                this, SLOT(onProcessError(QProcess::ProcessError)));
    } else if (m_proc->state() != QProcess::NotRunning) {
        // 간단히 이전 작업 취소(필요시 큐잉 로직 추가 가능)
        m_proc->kill();
        m_proc->waitForFinished(100);
    }

    m_pendingFilePath = QFileInfo(filePath).absoluteFilePath();

    // 인자 치환: %IN% → 입력 mp3, %OUT% → 출력 png
    QStringList args;
    args.reserve(m_defaultArgs.size());
    for (const QString& a : m_defaultArgs) {
        if (a == "%IN%")      args << m_pendingFilePath;
        else if (a == "%OUT%") args << outPath;
        else                  args << a;
    }

    m_proc->setWorkingDirectory(m_cacheDir.path());
    emit extractionStarted(m_pendingFilePath);
    m_proc->start(m_program, args);
}

void ImageExtract::onProcessFinished(int exitCode, QProcess::ExitStatus status) // 이미지 추출 완료 신호 전송
{
    const QString filePath = m_pendingFilePath;
    const QString outPath  = cachePathFor(filePath);

    if (status == QProcess::NormalExit && exitCode == 0 && QFileInfo(outPath).exists()) {
        m_coverImageUrl = QUrl::fromLocalFile(outPath);
        emit coverImageUrlChanged();
        emit extractionFinished(filePath, m_coverImageUrl);
    } else {
        m_coverImageUrl = kFallbackCover;
        emit coverImageUrlChanged();

        QString reason = QStringLiteral("Extractor failed (exit=%1, status=%2)").arg(exitCode).arg(int(status));
        if (m_proc)
            reason += QStringLiteral(", stderr: %1").arg(QString::fromLocal8Bit(m_proc->readAllStandardError()));
        emit extractionFailed(filePath, reason);
    }

    m_pendingFilePath.clear();
}

void ImageExtract::onProcessError(QProcess::ProcessError error)
{
    const QString filePath = m_pendingFilePath;
    m_pendingFilePath.clear();

    m_coverImageUrl = kFallbackCover;
    emit coverImageUrlChanged();
    emit extractionFailed(filePath, QStringLiteral("Process error=%1").arg(int(error)));
}

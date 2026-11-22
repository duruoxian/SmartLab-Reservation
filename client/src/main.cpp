#include "UserViewModel.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("SmartLab"));
    app.setApplicationDisplayName(QStringLiteral("智约实验室设备预约系统"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));
    QQuickStyle::setStyle(QStringLiteral("Material"));

    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    QCommandLineOption apiUrl("api-url", QStringLiteral("API 服务地址"), "url", "http://127.0.0.1:8765");
    parser.addOption(apiUrl);
    parser.process(app);
    const QUrl address(parser.value(apiUrl));
    if (!address.isValid() || address.host().isEmpty() || !address.userInfo().isEmpty() ||
            (address.scheme() != "https" && address.scheme() != "http")) {
        qCritical("Invalid --api-url.");
        return 2;
    }

    UserViewModel userViewModel(address);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("viewModel", &userViewModel);
    engine.load(QUrl(QStringLiteral("qrc:/SmartLab/ui/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return 1;
    return app.exec();
}

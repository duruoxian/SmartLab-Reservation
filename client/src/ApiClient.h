#pragma once

#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QUrl>
#include <functional>

struct ApiResult {
    int code;
    QString message;
    QJsonValue data;

    bool ok() const { return code == 200; }
};

class ApiClient {
public:
    using Callback = std::function<void(ApiResult)>;

    explicit ApiClient(QUrl baseUrl);

    void setToken(const QString &token);
    void send(const QByteArray &method, const QString &path, const QJsonObject &body,
              bool authenticated, Callback callback);

private:
    QUrl baseUrl_;
    QString token_;
    QNetworkAccessManager network_;
};

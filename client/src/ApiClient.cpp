#include "ApiClient.h"

#include <QJsonDocument>
#include <QNetworkProxy>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <utility>

ApiClient::ApiClient(QUrl baseUrl) : baseUrl_(std::move(baseUrl)) {
    // API 目标是本机或实验室局域网服务：直连，禁用系统代理。
    // 否则 QNetworkAccessManager 走系统代理自动探测（WPAD），在配置了
    // 代理（如 Clash）的机器上首次请求会把 GUI 线程阻塞数十秒。
    network_.setProxy(QNetworkProxy::NoProxy);
}

void ApiClient::setToken(const QString &token) {
    token_ = token;
}

void ApiClient::send(const QByteArray &method, const QString &path, const QJsonObject &body,
                     bool authenticated, Callback callback) {
    QNetworkRequest request(baseUrl_.resolved(QUrl(path)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    request.setRawHeader("Accept", "application/json");
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::ManualRedirectPolicy);
    request.setTransferTimeout(8000);
    if (authenticated && !token_.isEmpty())
        request.setRawHeader("Authorization", "Bearer " + token_.toUtf8());

    const QByteArray bytes = method == "GET" ? QByteArray() : QJsonDocument(body).toJson(QJsonDocument::Compact);
    auto *reply = network_.sendCustomRequest(request, method, bytes);
    QObject::connect(reply, &QNetworkReply::finished, &network_, [this, reply, authenticated, callback = std::move(callback)]() {
        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const auto json = QJsonDocument::fromJson(reply->readAll());
        const auto renewed = reply->rawHeader("X-SmartLab-Token");
        reply->deleteLater();
        if (status == 0) {
            callback({0, QStringLiteral("无法连接到智约服务，请确认后端已启动后重试。"), {}});
            return;
        }
        if (!json.isObject()) {
            callback({status == 200 ? 0 : status, QStringLiteral("服务返回了无法读取的数据。"), {}});
            return;
        }
        const auto object = json.object();
        const int code = status >= 200 && status < 300 ? object.value("code").toInt() : status;
        if (authenticated && status != 401 && !renewed.isEmpty())
            token_ = QString::fromUtf8(renewed);
        callback({code, object.value("message").toString(QStringLiteral("请求未完成。")), object.value("data")});
    });
}

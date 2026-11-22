#include "UserViewModel.h"

#include <QRegularExpression>
#include <QUrlQuery>
#include <utility>

namespace {
bool validAccount(const QString &value) {
    static const QRegularExpression pattern(QStringLiteral("^[A-Za-z0-9]{8,12}$"));
    return pattern.match(value.trimmed()).hasMatch();
}

bool validPhone(const QString &value) {
    static const QRegularExpression pattern(QStringLiteral("^1[3-9][0-9]{9}$"));
    return pattern.match(value.trimmed()).hasMatch();
}
}

UserViewModel::UserViewModel(QUrl address, QObject *parent) : QObject(parent), api_(std::move(address)) {}

void UserViewModel::setMessage(const QString &message, bool error) {
    message_ = message;
    error_ = error;
    emit messageChanged();
}

void UserViewModel::clearMessage() {
    setMessage({});
}

void UserViewModel::setUser(const QJsonValue &data) {
    user_ = data.toObject().toVariantMap();
    emit userChanged();
}

void UserViewModel::clearSession() {
    api_.setToken({});
    accounts_.clear();
    page_ = 1;
    hasMore_ = false;
    emit accountsChanged();
    setUser({});
}

void UserViewModel::request(const QByteArray &method, const QString &path, const QJsonObject &body,
                            bool authenticated, ApiClient::Callback callback) {
    if (busy_)
        return;
    busy_ = true;
    emit busyChanged();
    clearMessage();
    api_.send(method, path, body, authenticated,
              [this, authenticated, callback = std::move(callback)](const ApiResult &result) {
        busy_ = false;
        emit busyChanged();
        if (!result.ok()) {
            if (authenticated && (result.code == 401 ||
                (result.code == 403 && result.message.contains(QStringLiteral("账号已被禁用")))))
                clearSession();
            const auto retry = result.data.toObject().value("retry_after").toInt();
            setMessage(retry > 0 ? result.message + QStringLiteral("，约 %1 分钟后可重试。").arg((retry + 59) / 60)
                                 : result.message, true);
            return;
        }
        callback(result);
    });
}

bool UserViewModel::passwordConfirmed(const QString &password, const QString &confirmation) {
    if (password != confirmation) {
        setMessage(QStringLiteral("两次输入的密码不一致。"), true);
        return false;
    }
    static const QRegularExpression pattern(QStringLiteral("^(?=.*[A-Za-z])(?=.*[0-9]).{8,32}$"));
    if (!pattern.match(password).hasMatch()) {
        setMessage(QStringLiteral("请设置 8 至 32 位密码，包含英文字母和数字。"), true);
        return false;
    }
    return true;
}

void UserViewModel::loadRoles() {
    request("GET", "/api/auth/roles", {}, false, [this](const ApiResult &result) {
        roles_ = result.data.toArray().toVariantList();
        emit rolesChanged();
    });
}

void UserViewModel::login(const QString &userNo, const QString &password) {
    if (!validAccount(userNo) || password.isEmpty()) {
        setMessage(QStringLiteral("请输入 8 至 12 位学号或工号及密码。"), true);
        return;
    }
    request("POST", "/api/auth/login", {{"user_no", userNo}, {"password", password}}, false,
            [this](const ApiResult &result) {
        const auto data = result.data.toObject();
        api_.setToken(data.value("token").toString());
        setUser(data.value("user"));
    });
}

void UserViewModel::registerAccount(const QVariantMap &form, const QString &confirmation) {
    if (!validAccount(form.value("user_no").toString()) || !validPhone(form.value("phone").toString())
        || form.value("name").toString().trimmed().isEmpty() || form.value("college").toString().trimmed().isEmpty()
        || form.value("major").toString().trimmed().isEmpty()) {
        setMessage(QStringLiteral("请填写有效的账号、姓名、学院、专业和手机号。"), true);
        return;
    }
    if (!passwordConfirmed(form.value("password").toString(), confirmation))
        return;
    request("POST", "/api/auth/register", QJsonObject::fromVariantMap(form), false, [this](const ApiResult &result) {
        const auto data = result.data.toObject();
        emit registered(data.value("user").toObject().value("user_no").toString());
        setMessage(QStringLiteral("注册成功，请使用新账号登录。"));
        emit recoveryCodeReady(data.value("recovery_code").toString());
    });
}

void UserViewModel::resetPassword(const QVariantMap &form, const QString &confirmation) {
    if (!validAccount(form.value("user_no").toString()) || !validPhone(form.value("phone").toString())
        || form.value("recovery_code").toString().trimmed().length() != 24) {
        setMessage(QStringLiteral("请检查账号、预留手机号和 24 位恢复码。"), true);
        return;
    }
    if (!passwordConfirmed(form.value("new_password").toString(), confirmation))
        return;
    request("POST", "/api/auth/reset-password", QJsonObject::fromVariantMap(form), false,
            [this, userNo = form.value("user_no").toString()](const ApiResult &result) {
        emit passwordReset(userNo);
        setMessage(result.message);
    });
}

void UserViewModel::refreshProfile() {
    request("GET", "/api/users/me", {}, true, [this](const ApiResult &result) { setUser(result.data); });
}

void UserViewModel::updateProfile(const QVariantMap &form) {
    if (!validPhone(form.value("phone").toString()) || form.value("college").toString().trimmed().isEmpty()
        || form.value("major").toString().trimmed().isEmpty()) {
        setMessage(QStringLiteral("请填写学院、专业和有效的预留手机号。"), true);
        return;
    }
    request("PUT", "/api/users/me", QJsonObject::fromVariantMap(form), true, [this](const ApiResult &result) {
        setUser(result.data);
        setMessage(result.message);
    });
}

void UserViewModel::changePassword(const QString &current, const QString &password, const QString &confirmation) {
    if (!passwordConfirmed(password, confirmation))
        return;
    request("PUT", "/api/users/me/password", {{"current_password", current}, {"new_password", password}}, true,
            [this](const ApiResult &result) { clearSession(); setMessage(result.message); });
}

void UserViewModel::renewRecoveryCode(const QString &current) {
    request("POST", "/api/users/me/recovery-code", {{"current_password", current}}, true,
            [this](const ApiResult &result) { emit recoveryCodeReady(result.data.toObject().value("recovery_code").toString()); });
}

void UserViewModel::logout() {
    request("POST", "/api/auth/logout", {}, true, [this](const ApiResult &) { clearSession(); });
}

void UserViewModel::loadAccounts(const QString &keyword, int page) {
    QUrlQuery query;
    query.addQueryItem("keyword", keyword.trimmed());
    query.addQueryItem("page", QString::number(page));
    request("GET", "/api/admin/users?" + query.toString(QUrl::FullyEncoded), {}, true,
            [this](const ApiResult &result) {
        const auto data = result.data.toObject();
        accounts_ = data.value("items").toArray().toVariantList();
        page_ = data.value("page").toInt(1);
        hasMore_ = data.value("has_more").toBool();
        emit accountsChanged();
    });
}

void UserViewModel::changeRole(int id, const QString &role) {
    request("PUT", QStringLiteral("/api/admin/users/%1/role").arg(id), {{"role", role}}, true,
            [this, id](const ApiResult &result) {
        for (auto &item : accounts_) {
            if (item.toMap().value("id").toInt() == id) {
                item = result.data.toObject().toVariantMap();
                break;
            }
        }
        emit accountsChanged();
        setMessage(result.message);
    });
}

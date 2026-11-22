#pragma once

#include "ApiClient.h"
#include <QObject>
#include <QVariantList>
#include <QVariantMap>

class UserViewModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantMap user READ user NOTIFY userChanged)
    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY userChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    Q_PROPERTY(bool error READ error NOTIFY messageChanged)
    Q_PROPERTY(QVariantList roles READ roles NOTIFY rolesChanged)
    Q_PROPERTY(QVariantList accounts READ accounts NOTIFY accountsChanged)
    Q_PROPERTY(int page READ page NOTIFY accountsChanged)
    Q_PROPERTY(bool hasMore READ hasMore NOTIFY accountsChanged)

public:
    explicit UserViewModel(QUrl address, QObject *parent = nullptr);

    QVariantMap user() const { return user_; }
    bool loggedIn() const { return !user_.isEmpty(); }
    bool busy() const { return busy_; }
    QString message() const { return message_; }
    bool error() const { return error_; }
    QVariantList roles() const { return roles_; }
    QVariantList accounts() const { return accounts_; }
    int page() const { return page_; }
    bool hasMore() const { return hasMore_; }

    Q_INVOKABLE void clearMessage();
    Q_INVOKABLE void loadRoles();
    Q_INVOKABLE void login(const QString &userNo, const QString &password);
    Q_INVOKABLE void registerAccount(const QVariantMap &form, const QString &confirmation);
    Q_INVOKABLE void resetPassword(const QVariantMap &form, const QString &confirmation);
    Q_INVOKABLE void refreshProfile();
    Q_INVOKABLE void updateProfile(const QVariantMap &form);
    Q_INVOKABLE void changePassword(const QString &current, const QString &password, const QString &confirmation);
    Q_INVOKABLE void renewRecoveryCode(const QString &current);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void loadAccounts(const QString &keyword = {}, int page = 1);
    Q_INVOKABLE void changeRole(int id, const QString &role);

signals:
    void userChanged();
    void busyChanged();
    void messageChanged();
    void rolesChanged();
    void accountsChanged();
    void registered(const QString &userNo);
    void passwordReset(const QString &userNo);
    void recoveryCodeReady(const QString &code);

private:
    void request(const QByteArray &method, const QString &path, const QJsonObject &body,
                 bool authenticated, ApiClient::Callback callback);
    void setMessage(const QString &message, bool error = false);
    void setUser(const QJsonValue &data);
    void clearSession();
    bool passwordConfirmed(const QString &password, const QString &confirmation);

    ApiClient api_;
    QVariantMap user_;
    QVariantList roles_;
    QVariantList accounts_;
    QString message_;
    int page_ = 1;
    bool hasMore_ = false;
    bool busy_ = false;
    bool error_ = false;
};

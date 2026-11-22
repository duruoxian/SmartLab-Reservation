"""Create a local administrator interactively before opening the desktop app."""

import argparse
import sys
from getpass import getpass

from pydantic import ValidationError

from app.core.database import SessionLocal
from app.core.exceptions import ApiError
from app.core.security import ADMIN
from app.models.schemas import NewAccount
from app.services.user_service import create_account, initialize


def main() -> int:
    parser = argparse.ArgumentParser(description="创建智约管理员账号")
    parser.add_argument("--user-no", default="admin0001", help="8 至 12 位字母或数字")
    args = parser.parse_args()
    try:
        name = input("管理员名称 [实验室管理员] > ").strip() or "实验室管理员"
        phone = input("预留手机号 > ").strip()
        password = getpass("设置密码 > ")
        if password != getpass("确认密码 > "):
            print("两次密码不一致", file=sys.stderr)
            return 1
        form = NewAccount(user_no=args.user_no, name=name, college="实验室管理",
                          major="实验室管理", phone=phone, password=password)
        initialize()
        with SessionLocal() as db:
            result = create_account(db, form, ADMIN)
    except ValidationError:
        print("请检查账号、名称、手机号及 8 至 32 位密码格式。", file=sys.stderr)
        return 1
    except ApiError as error:
        print(error.message, file=sys.stderr)
        return 1
    print(f"管理员 {result['user']['user_no']} 已创建。")
    print(f"请妥善保存一次性恢复码：{result['recovery_code']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

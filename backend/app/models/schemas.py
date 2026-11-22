"""Request validation and public user data."""

from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, StringConstraints

Account = Annotated[str, StringConstraints(strip_whitespace=True, to_lower=True, pattern=r"^[A-Za-z0-9]{8,12}$")]
Password = Annotated[str, StringConstraints(min_length=8, max_length=32, pattern=r"^[^\r\n]+$")]
Name = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=20)]
Department = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=60)]
Phone = Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^1[3-9][0-9]{9}$")]
RecoveryCode = Annotated[str, StringConstraints(strip_whitespace=True, min_length=24, max_length=24)]


class Input(BaseModel):
    model_config = ConfigDict(extra="forbid")


class NewAccount(Input):
    user_no: Account
    name: Name
    college: Department
    major: Department
    phone: Phone
    password: Password


class Registration(NewAccount):
    role: Literal["student", "teacher"]


class Login(Input):
    user_no: Account
    password: Annotated[str, StringConstraints(min_length=1, max_length=128)]


class ProfileUpdate(Input):
    college: Department
    major: Department
    phone: Phone


class ResetPassword(Input):
    user_no: Account
    phone: Phone
    recovery_code: RecoveryCode
    new_password: Password


class CurrentPassword(Input):
    current_password: Password


class ChangePassword(CurrentPassword):
    new_password: Password


class RoleUpdate(Input):
    role: Literal["student", "teacher", "admin"]


class PublicUser(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_no: str
    name: str
    role: str
    college: str
    major: str
    phone: str
    status: str
    violation_count: int
    frozen_until: int | None
    booking_frozen: bool

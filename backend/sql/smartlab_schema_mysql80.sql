-- 智约系统 V0.1. MySQL 8.0.16+.
-- 通过连接参数选定一个新建的空数据库，再执行本文件。
-- 首次初始化使用。本文件依外键顺序建表和初始化字典。
SET NAMES utf8mb4;
SET SESSION time_zone = '+00:00';

CREATE TABLE t_dept (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '院系ID',
  dept_code VARCHAR(32) NOT NULL COMMENT '院系编码',
  dept_name VARCHAR(100) NOT NULL COMMENT '院系名称',
  is_active TINYINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_dept_code (dept_code),
  CONSTRAINT ck_dept_active CHECK (is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='院系表';

CREATE TABLE t_dict (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '字典项ID',
  type VARCHAR(20) NOT NULL COMMENT '字典分类',
  code VARCHAR(24) NOT NULL COMMENT '项编码',
  name VARCHAR(30) NOT NULL COMMENT '显示名称',
  sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  UNIQUE KEY uq_dict_type_code (type, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='数据字典表';

CREATE TABLE t_user (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
  user_no VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(20) NOT NULL COMMENT '真实姓名',
  role VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  college VARCHAR(60) NOT NULL COMMENT '现有系统使用的学院名称',
  major VARCHAR(60) NOT NULL,
  phone VARCHAR(11) NOT NULL,
  dept_id BIGINT UNSIGNED NULL COMMENT '可选院系ID',
  password_hash VARCHAR(96) CHARACTER SET ascii NOT NULL COMMENT '带盐散列',
  recovery_hash VARCHAR(64) CHARACTER SET ascii NULL COMMENT '恢复码摘要',
  status VARCHAR(8) NOT NULL DEFAULT '启用',
  fail_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  lock_until BIGINT UNSIGNED NULL COMMENT '登录锁定截止 Unix 秒',
  violation_count INT UNSIGNED NOT NULL DEFAULT 0,
  frozen_until BIGINT UNSIGNED NULL COMMENT '预约冻结截止 Unix 秒',
  created_at BIGINT UNSIGNED NOT NULL COMMENT '创建时间 Unix 秒',
  UNIQUE KEY uq_user_no (user_no),
  KEY ix_user_role_status (role, status),
  CONSTRAINT fk_user_dept FOREIGN KEY (dept_id) REFERENCES t_dept (id),
  CONSTRAINT ck_user_no_length CHECK (CHAR_LENGTH(user_no) BETWEEN 8 AND 12),
  CONSTRAINT ck_user_role CHECK (role IN ('student', 'teacher', 'admin')),
  CONSTRAINT ck_user_status CHECK (status IN ('启用', '禁用'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

CREATE TABLE t_auth_session (
  sid VARCHAR(43) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  last_activity_at BIGINT UNSIGNED NOT NULL COMMENT '最近活动 Unix 秒',
  KEY ix_session_user_activity (user_id, last_activity_at),
  KEY ix_session_activity (last_activity_at),
  CONSTRAINT fk_session_user FOREIGN KEY (user_id)
    REFERENCES t_user (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='登录会话表';

CREATE TABLE t_password_reset (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  issued_by BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  expires_at DATETIME(3) NOT NULL,
  used_at DATETIME(3) NULL,
  UNIQUE KEY uq_reset_hash (token_hash),
  KEY ix_reset_user_expires (user_id, expires_at),
  CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES t_user (id),
  CONSTRAINT fk_reset_issuer FOREIGN KEY (issued_by) REFERENCES t_user (id),
  CONSTRAINT ck_reset_time CHECK (
    created_at < expires_at
    AND (used_at IS NULL OR used_at BETWEEN created_at AND expires_at)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='一次性密码重置凭证表';

CREATE TABLE t_lab (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '实验室ID',
  lab_code VARCHAR(32) NOT NULL,
  lab_name VARCHAR(100) NOT NULL,
  dept_id BIGINT UNSIGNED NULL,
  manager_id BIGINT UNSIGNED NULL,
  location VARCHAR(160) NOT NULL,
  time_zone VARCHAR(64) NOT NULL DEFAULT 'Asia/Shanghai',
  description VARCHAR(500) NULL,
  is_active TINYINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_lab_code (lab_code),
  CONSTRAINT fk_lab_dept FOREIGN KEY (dept_id) REFERENCES t_dept (id),
  CONSTRAINT fk_lab_manager FOREIGN KEY (manager_id) REFERENCES t_user (id),
  CONSTRAINT ck_lab_active CHECK (is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='实验室表';

CREATE TABLE t_lab_open_hour (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  lab_id BIGINT UNSIGNED NOT NULL,
  weekday TINYINT UNSIGNED NOT NULL,
  opens_at TIME NOT NULL,
  closes_at TIME NOT NULL,
  UNIQUE KEY uq_open_lab_day_start (lab_id, weekday, opens_at),
  CONSTRAINT fk_open_lab FOREIGN KEY (lab_id) REFERENCES t_lab (id),
  CONSTRAINT ck_open_weekday CHECK (weekday BETWEEN 1 AND 7),
  CONSTRAINT ck_open_time CHECK (
    opens_at >= '00:00:00' AND opens_at < closes_at
    AND closes_at <= '24:00:00'
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='实验室开放时段表';

CREATE TABLE t_equipment (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '设备ID',
  equipment_code VARCHAR(32) NOT NULL,
  equipment_name VARCHAR(100) NOT NULL,
  model VARCHAR(64) NULL,
  lab_id BIGINT UNSIGNED NOT NULL,
  category_code VARCHAR(32) NOT NULL,
  specifications TEXT NULL,
  usage_note TEXT NULL,
  safety_note TEXT NULL,
  status VARCHAR(16) CHARACTER SET ascii NOT NULL DEFAULT 'active',
  archived_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
    ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_equipment_code (equipment_code),
  KEY ix_equipment_lab_category (lab_id, category_code),
  CONSTRAINT fk_equipment_lab FOREIGN KEY (lab_id) REFERENCES t_lab (id),
  CONSTRAINT ck_equipment_status
    CHECK (status IN ('active', 'maintenance', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='设备表';

CREATE TABLE t_reservation (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reservation_no VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL COMMENT '申请人ID',
  equipment_id BIGINT UNSIGNED NOT NULL,
  request_key VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  start_at DATETIME(3) NOT NULL,
  end_at DATETIME(3) NOT NULL,
  purpose VARCHAR(200) NOT NULL,
  status VARCHAR(16) CHARACTER SET ascii NOT NULL DEFAULT 'pending',
  checked_in_at DATETIME(3) NULL,
  returned_at DATETIME(3) NULL,
  returned_by BIGINT UNSIGNED NULL,
  return_note VARCHAR(100) NULL,
  cancel_reason VARCHAR(200) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
    ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_res_no (reservation_no),
  UNIQUE KEY uq_res_user_request (user_id, request_key),
  UNIQUE KEY uq_res_id_party (id, equipment_id, user_id),
  KEY ix_res_my_list (user_id, status, created_at, id),
  KEY ix_res_scan_start (status, start_at, id),
  KEY ix_res_scan_end (status, end_at, id),
  KEY ix_res_equipment_time (equipment_id, start_at, id),
  CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES t_user (id),
  CONSTRAINT fk_res_equipment FOREIGN KEY (equipment_id) REFERENCES t_equipment (id),
  CONSTRAINT fk_res_receiver FOREIGN KEY (returned_by) REFERENCES t_user (id),
  CONSTRAINT ck_res_time CHECK (start_at < end_at),
  CONSTRAINT ck_res_return CHECK (
    returned_at IS NULL
    OR (checked_in_at IS NOT NULL AND returned_at >= checked_in_at
        AND returned_by IS NOT NULL)
  ),
  CONSTRAINT ck_res_status CHECK (
    status IN ('pending', 'approved', 'rejected', 'in_use',
               'completed', 'cancelled', 'violated')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='实验室设备预约表';

CREATE TABLE t_res_slot (
  reservation_id BIGINT UNSIGNED NOT NULL,
  equipment_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  slot_start DATETIME(3) NOT NULL COMMENT '30分钟槽开始时刻',
  PRIMARY KEY (reservation_id, slot_start),
  UNIQUE KEY uq_slot_equipment_time (equipment_id, slot_start),
  UNIQUE KEY uq_slot_user_time (user_id, slot_start),
  CONSTRAINT fk_slot_res FOREIGN KEY (reservation_id, equipment_id, user_id)
    REFERENCES t_reservation (id, equipment_id, user_id),
  CONSTRAINT ck_slot_grid CHECK (
    MINUTE(slot_start) IN (0, 30) AND SECOND(slot_start) = 0
    AND MICROSECOND(slot_start) = 0
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='预约计划占用槽表';

CREATE TABLE t_equipment_custody (
  equipment_id BIGINT UNSIGNED PRIMARY KEY,
  reservation_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL COMMENT '持有设备的用户',
  hold_reason VARCHAR(24) CHARACTER SET ascii NOT NULL DEFAULT 'in_use',
  held_at DATETIME(3) NOT NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
    ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_custody_res (reservation_id),
  CONSTRAINT fk_custody_res
    FOREIGN KEY (reservation_id, equipment_id, user_id)
    REFERENCES t_reservation (id, equipment_id, user_id),
  CONSTRAINT ck_custody_reason CHECK (
    hold_reason IN ('in_use', 'overdue', 'admin_pending')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='设备实物交接占用表';

CREATE TABLE t_approval_log (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reservation_id BIGINT UNSIGNED NOT NULL,
  approver_id BIGINT UNSIGNED NOT NULL COMMENT '审批管理员ID',
  decision VARCHAR(16) CHARACTER SET ascii NOT NULL,
  opinion VARCHAR(200) NULL,
  decided_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_approval_res (reservation_id),
  KEY ix_approval_date (decided_at, id),
  CONSTRAINT fk_approval_res FOREIGN KEY (reservation_id)
    REFERENCES t_reservation (id),
  CONSTRAINT fk_approval_user FOREIGN KEY (approver_id)
    REFERENCES t_user (id),
  CONSTRAINT ck_approval_decision CHECK (decision IN ('approve', 'reject')),
  CONSTRAINT ck_approval_opinion CHECK (
    decision <> 'reject'
    OR (opinion IS NOT NULL AND CHAR_LENGTH(TRIM(opinion)) > 0)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='审批记录表';

CREATE TABLE t_violation (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reservation_id BIGINT UNSIGNED NOT NULL,
  violation_type VARCHAR(24) CHARACTER SET ascii NOT NULL,
  status VARCHAR(16) CHARACTER SET ascii NOT NULL DEFAULT 'open',
  occurred_at DATETIME(3) NOT NULL,
  resolved_at DATETIME(3) NULL,
  resolved_by BIGINT UNSIGNED NULL,
  resolution_note VARCHAR(200) NULL,
  UNIQUE KEY uq_violation_res_type (reservation_id, violation_type),
  KEY ix_violation_time_status (occurred_at, status, id),
  CONSTRAINT fk_violation_res FOREIGN KEY (reservation_id)
    REFERENCES t_reservation (id),
  CONSTRAINT fk_violation_resolver FOREIGN KEY (resolved_by)
    REFERENCES t_user (id),
  CONSTRAINT ck_violation_type CHECK (
    violation_type IN ('no_show', 'late_return')
  ),
  CONSTRAINT ck_violation_status CHECK (status IN ('open', 'resolved'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='违约记录表';

CREATE TABLE t_notification_event (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_key VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  event_type VARCHAR(32) CHARACTER SET ascii NOT NULL,
  reservation_id BIGINT UNSIGNED NULL,
  payload JSON NOT NULL COMMENT '生成通知所需的业务参数',
  status VARCHAR(16) CHARACTER SET ascii NOT NULL DEFAULT 'pending',
  attempt_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  available_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  locked_until DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  processed_at DATETIME(3) NULL,
  UNIQUE KEY uq_notice_event_key (event_key),
  KEY ix_notice_event_due (status, available_at, id),
  CONSTRAINT fk_notice_event_res FOREIGN KEY (reservation_id)
    REFERENCES t_reservation (id),
  CONSTRAINT ck_notice_event_status CHECK (
    status IN ('pending', 'processing', 'sent', 'failed')
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='通知事件表';

CREATE TABLE t_notification (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id BIGINT UNSIGNED NOT NULL,
  recipient_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(50) NOT NULL,
  content VARCHAR(500) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  read_at DATETIME(3) NULL,
  deleted_at DATETIME(3) NULL,
  UNIQUE KEY uq_notice_event_recipient (event_id, recipient_id),
  KEY ix_notice_recipient_list (recipient_id, deleted_at, created_at, id),
  KEY ix_notice_recipient_unread (recipient_id, deleted_at, read_at),
  CONSTRAINT fk_notice_event FOREIGN KEY (event_id)
    REFERENCES t_notification_event (id),
  CONSTRAINT fk_notice_recipient FOREIGN KEY (recipient_id)
    REFERENCES t_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='站内消息表';

CREATE TABLE t_operation_log (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actor_id BIGINT UNSIGNED NULL,
  target_user_id BIGINT UNSIGNED NULL,
  action VARCHAR(36) NOT NULL,
  result VARCHAR(80) NOT NULL,
  created_at BIGINT UNSIGNED NOT NULL COMMENT '记录时间 Unix 秒',
  target_type VARCHAR(32) NULL,
  target_id VARCHAR(64) NULL,
  detail VARCHAR(500) NULL,
  source_ip VARCHAR(45) NULL,
  KEY ix_operation_log_action_time (action, created_at),
  KEY ix_audit_actor_time (actor_id, created_at, id),
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_id) REFERENCES t_user (id),
  CONSTRAINT fk_audit_target_user FOREIGN KEY (target_user_id)
    REFERENCES t_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci COMMENT='操作审计日志表';

INSERT INTO t_dict (type, code, name, sort_order) VALUES
  ('role', 'student', '学生', 10),
  ('role', 'teacher', '教师', 20),
  ('role', 'admin', '管理员', 30),
  ('violation_type', 'no_show', '未签到', 10),
  ('violation_type', 'late_return', '逾期未归还', 20);

CREATE TABLE IF NOT EXISTS users (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  email         VARCHAR(255) NOT NULL UNIQUE,
  name          VARCHAR(100) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS expense_groups (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  created_by BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_group_creator FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS group_members (
  group_id  BIGINT NOT NULL,
  user_id   BIGINT NOT NULL,
  role      VARCHAR(10) NOT NULL,
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (group_id, user_id),
  INDEX idx_members_user (user_id),
  CONSTRAINT fk_member_group FOREIGN KEY (group_id) REFERENCES expense_groups(id),
  CONSTRAINT fk_member_user  FOREIGN KEY (user_id)  REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS expenses (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  group_id     BIGINT NOT NULL,
  paid_by      BIGINT NOT NULL,
  description  VARCHAR(200) NOT NULL,
  amount_cents BIGINT NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_expenses_group_time (group_id, created_at),
  CONSTRAINT fk_expense_group FOREIGN KEY (group_id) REFERENCES expense_groups(id),
  CONSTRAINT fk_expense_payer FOREIGN KEY (paid_by)  REFERENCES users(id),
  CONSTRAINT chk_expense_positive CHECK (amount_cents > 0)
);

CREATE TABLE IF NOT EXISTS expense_splits (
  expense_id  BIGINT NOT NULL,
  user_id     BIGINT NOT NULL,
  share_cents BIGINT NOT NULL,
  PRIMARY KEY (expense_id, user_id),
  INDEX idx_splits_user (user_id),
  CONSTRAINT fk_split_expense FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
  CONSTRAINT fk_split_user    FOREIGN KEY (user_id)    REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS settlements (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  group_id     BIGINT NOT NULL,
  from_user    BIGINT NOT NULL,
  to_user      BIGINT NOT NULL,
  amount_cents BIGINT NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_settlements_group (group_id),
  CONSTRAINT fk_settle_group FOREIGN KEY (group_id)  REFERENCES expense_groups(id),
  CONSTRAINT fk_settle_from  FOREIGN KEY (from_user) REFERENCES users(id),
  CONSTRAINT fk_settle_to    FOREIGN KEY (to_user)   REFERENCES users(id),
  CONSTRAINT chk_settle_positive CHECK (amount_cents > 0)
);
CREATE TABLE IF NOT EXISTS ev_characters (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 license VARCHAR(100) NOT NULL,
 firstname VARCHAR(32) NOT NULL,
 lastname VARCHAR(32) NOT NULL,
 permission_group VARCHAR(32) NOT NULL DEFAULT 'user',
 job VARCHAR(64) NOT NULL DEFAULT 'unemployed',
 job_grade INT UNSIGNED NOT NULL DEFAULT 0,
  pos_x DOUBLE NULL,
  pos_y DOUBLE NULL,
  pos_z DOUBLE NULL,
  pos_heading FLOAT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_ev_characters_license (license)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ev_accounts (
 character_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(32) NOT NULL,
 balance BIGINT UNSIGNED NOT NULL DEFAULT 0,
 PRIMARY KEY (character_id,name),
 CONSTRAINT fk_ev_accounts_character FOREIGN KEY (character_id) REFERENCES ev_characters(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ev_jobs (
 name VARCHAR(64) PRIMARY KEY,
 label VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ev_job_grades (
 job_name VARCHAR(64) NOT NULL,
 grade INT UNSIGNED NOT NULL,
 label VARCHAR(100) NOT NULL,
 salary INT UNSIGNED NOT NULL DEFAULT 0,
 PRIMARY KEY (job_name,grade),
 FOREIGN KEY (job_name) REFERENCES ev_jobs(name) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT IGNORE INTO ev_jobs (name,label) VALUES ('unemployed','Sans emploi');
INSERT IGNORE INTO ev_job_grades (job_name,grade,label,salary) VALUES ('unemployed',0,'Citoyen',0);

-- Ledger pour audit et atomicité des mouvements
CREATE TABLE IF NOT EXISTS ev_account_ledger (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  character_id BIGINT UNSIGNED NOT NULL,
  account_name VARCHAR(32) NOT NULL,
  amount BIGINT NOT NULL,
  reason VARCHAR(100) NOT NULL,
  related_character_id BIGINT UNSIGNED NULL,
  transfer_id VARCHAR(36) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ledger_character (character_id),
  CONSTRAINT fk_ledger_character FOREIGN KEY (character_id) REFERENCES ev_characters(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Procédure stockée pour transfert atomique avec contrôle ROW_COUNT
DELIMITER $$
DROP PROCEDURE IF EXISTS ev_transfer_bank$$
CREATE PROCEDURE ev_transfer_bank(
  IN p_from BIGINT UNSIGNED,
  IN p_to BIGINT UNSIGNED,
  IN p_amount BIGINT,
  IN p_transfer_id VARCHAR(36)
)
BEGIN
  DECLARE v_affected INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  UPDATE ev_accounts
  SET balance = balance - p_amount
  WHERE character_id = p_from AND name = 'bank' AND balance >= p_amount;

  SET v_affected = ROW_COUNT();
  IF v_affected <> 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'insufficient_funds_or_missing_account';
  END IF;

  UPDATE ev_accounts
  SET balance = balance + p_amount
  WHERE character_id = p_to AND name = 'bank';

  IF ROW_COUNT() <> 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'target_account_missing';
  END IF;

  INSERT INTO ev_account_ledger (character_id, account_name, amount, reason, related_character_id, transfer_id)
  VALUES (p_from, 'bank', -p_amount, 'transfer_out', p_to, p_transfer_id);

  INSERT INTO ev_account_ledger (character_id, account_name, amount, reason, related_character_id, transfer_id)
  VALUES (p_to, 'bank', p_amount, 'transfer_in', p_from, p_transfer_id);

  COMMIT;
END$$
DELIMITER ;

-- Ajout de la colonne transfer_id si elle n'existe pas (pour installs existants)
-- À exécuter manuellement si la table existe déjà sans la colonne
-- ALTER TABLE ev_account_ledger ADD COLUMN transfer_id VARCHAR(36) NULL AFTER related_character_id;

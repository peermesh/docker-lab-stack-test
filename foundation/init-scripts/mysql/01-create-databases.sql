-- ==============================================================
-- MySQL Database Initialization
-- ==============================================================
-- Creates databases and users for all applications that use MySQL
-- Executed on first container startup
-- ==============================================================

-- WriteFreely database
CREATE DATABASE IF NOT EXISTS writefreely CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'writefreely'@'%' IDENTIFIED BY 'writefreely_password_replace_me';
GRANT ALL PRIVILEGES ON writefreely.* TO 'writefreely'@'%';

-- Pixelfed database
CREATE DATABASE IF NOT EXISTS pixelfed CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'pixelfed'@'%' IDENTIFIED BY 'pixelfed_password_replace_me';
GRANT ALL PRIVILEGES ON pixelfed.* TO 'pixelfed'@'%';

-- Castopod database
CREATE DATABASE IF NOT EXISTS castopod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'castopod'@'%' IDENTIFIED BY 'castopod_password_replace_me';
GRANT ALL PRIVILEGES ON castopod.* TO 'castopod'@'%';

FLUSH PRIVILEGES;

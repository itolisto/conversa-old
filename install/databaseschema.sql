--
-- Database : `conversadb`
--
CREATE DATABASE IF NOT EXISTS `conversadb`
DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE conversadb;


DROP TABLE IF EXISTS `co_blackmail_list`;
CREATE TABLE IF NOT EXISTS `co_blackmail_list` (
  `bl_id`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bl_added`  INT UNSIGNED NOT NULL,
  `bl_email`  VARCHAR(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (bl_id)
)
  COMMENT='Lista de email bloqueados'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_block_contacts`;
CREATE TABLE IF NOT EXISTS `co_block_contacts` (
  `blc_id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `blc_from_id`    INT UNSIGNED NOT NULL,
  `blc_to_id`      INT UNSIGNED NOT NULL,
  `blc_from_type`  TINYINT UNSIGNED NOT NULL COMMENT '1:Negocio 2:Usuario',
  `blc_to_type`    TINYINT UNSIGNED NOT NULL COMMENT '1:Negocio 2:Usuario',
  `blc_valid`      TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1: Valido 2: Invalido',
  `blc_created`    INT UNSIGNED NOT NULL,
  `blc_modified`   INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (blc_id)
)
  COMMENT='Lista de contactos bloqueados'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_password_change_request`;
CREATE TABLE IF NOT EXISTS `co_password_change_request` (
  `psr_id`      INT      UNSIGNED NOT NULL AUTO_INCREMENT,
  `psr_user_id` INT      UNSIGNED NOT NULL,
  `psr_created` INT      UNSIGNED NOT NULL,
  `psr_valid`   TINYINT  UNSIGNED NOT NULL DEFAULT 1 COMMENT '1:Solicitud valida 0:Solicitud invalida',
  `psr_token`   VARCHAR(90) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (psr_id)
)
  COMMENT='Historial de peticiones de cambio de contraseña'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */

DROP TABLE IF EXISTS `co_servers`;
CREATE TABLE IF NOT EXISTS `co_servers` (
  `se_id`       TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `se_name`     VARCHAR(100) COLLATE utf8_bin NOT NULL,
  `se_url`      VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `se_created`  INT UNSIGNED NOT NULL,
  `se_modified` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (se_id)
)
  COMMENT='Lista de servidores'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */
/* ********************************************************************** */

DROP TABLE IF EXISTS `co_message`;
CREATE TABLE IF NOT EXISTS `co_message` (
  `me_id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `me_from_user_id`        INT UNSIGNED NOT NULL,
  `me_to_user_id`          INT UNSIGNED NOT NULL,
  `me_created`             INT UNSIGNED NOT NULL,
  `me_modified`            INT UNSIGNED NOT NULL DEFAULT 0,
  `me_read_at`             INT UNSIGNED NOT NULL DEFAULT 0,
  `me_report_count`        INT UNSIGNED NOT NULL DEFAULT 0,
  `me_message_type`        INT UNSIGNED NOT NULL COMMENT '1:Text 2:Image 3:Location',
  `me_valid`               TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `me_from_user_type`      TINYINT UNSIGNED NOT NULL COMMENT '1:Negocio 2:Usuario',
  `me_to_user_type`        TINYINT UNSIGNED NOT NULL COMMENT '1:Negocio 2:Usuario',
  `me_message_target_type` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1:Usuario 2:Grupo',
  `me_body`                  VARCHAR(1200) COLLATE utf8_bin NOT NULL,
  `me_picture_file_id`       VARCHAR(155)  COLLATE utf8_bin NOT NULL,
  `me_picture_thumb_file_id` VARCHAR(155)  COLLATE utf8_bin NOT NULL,
  `me_longitude`             FLOAT NOT NULL,
  `me_latitude`              FLOAT NOT NULL,
  PRIMARY KEY (me_id)
)
  COMMENT='Historial de mensajes'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */

DROP TABLE IF EXISTS `co_admins`;
CREATE TABLE IF NOT EXISTS `co_admins` (
  `ad_id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ad_created`         INT UNSIGNED NOT NULL,
  `ad_modified`        INT UNSIGNED NOT NULL DEFAULT 0,
  `ad_last_login`      INT UNSIGNED NOT NULL DEFAULT 0,
  `ad_birthday`        DATE NOT NULL COMMENT 'yyyy-mm-dd',
  `ad_gender`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1:Hombre 2:Mujer',
  `ad_name`                 VARCHAR(30)  COLLATE utf8_bin NOT NULL,
  `ad_about`                VARCHAR(180) COLLATE utf8_bin NOT NULL,
  `ad_email`                VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `ad_password`             VARCHAR(32)  COLLATE utf8_bin NOT NULL,
  `ad_token`                VARCHAR(100) COLLATE utf8_bin NOT NULL,
  `ad_avatar_file_id`       VARCHAR(155) COLLATE utf8_bin NOT NULL,
  `ad_avatar_thumb_file_id` VARCHAR(155) COLLATE utf8_bin NOT NULL,
  `ad_ios_push_token`       VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `ad_android_push_token`   VARCHAR(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (ad_id)
)
  COMMENT='Usuarios que son administradores'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */

DROP TABLE IF EXISTS `co_user`;
CREATE TABLE IF NOT EXISTS `co_user` (
  `us_id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `us_last_login`   INT UNSIGNED NOT NULL,
  `us_created`      INT UNSIGNED NOT NULL,
  `us_modified`     INT UNSIGNED NOT NULL DEFAULT 0,
  `us_birthday`     DATE NOT NULL COMMENT 'yyyy-mm-dd',
  `us_gender`       TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1:Hombre 2:Mujer',
  `us_name`                 VARCHAR(30)  COLLATE utf8_bin NOT NULL,
  `us_email`                VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `us_password`             VARCHAR(32)  COLLATE utf8_bin NOT NULL,
  `us_about`                VARCHAR(180) COLLATE utf8_bin NOT NULL,
  `us_token`                VARCHAR(100) COLLATE utf8_bin NOT NULL,
  `us_avatar_file_id`       VARCHAR(155) COLLATE utf8_bin NOT NULL,
  `us_avatar_thumb_file_id` VARCHAR(155) COLLATE utf8_bin NOT NULL,
  `us_ios_push_token`       VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `us_android_push_token`   VARCHAR(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (us_id)
)
  COMMENT='Usuarios que son clientes'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_user_contact`;
CREATE TABLE IF NOT EXISTS `co_user_contact` (
  `uc_id`                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uc_user_id`              INT UNSIGNED NOT NULL COMMENT 'Id del usuario',
  `uc_contact_business_id`  INT UNSIGNED NOT NULL COMMENT 'Id del negocio (contacto)',
  `uc_created`              INT UNSIGNED NOT NULL,
  `uc_valid`                TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (uc_id)
)
  COMMENT='Negocios contactados por usuario'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_user_favorite_business`;
CREATE TABLE IF NOT EXISTS `co_user_favorite_business` (
  `ufb_id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ufb_user_id`     INT UNSIGNED NOT NULL,
  `ufb_business_id` INT UNSIGNED NOT NULL,
  `ufb_created`     INT UNSIGNED NOT NULL,
  `ufb_modified`    INT UNSIGNED NOT NULL DEFAULT 0,
  `ufb_valid`       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (ufb_id)
)
  COMMENT='Historial de negocios marcados como favoritos por un usuario'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */

DROP TABLE IF EXISTS `co_business`;
CREATE TABLE IF NOT EXISTS `co_business` (
  `bu_id`                INT  UNSIGNED NOT NULL AUTO_INCREMENT,
  `bu_created`           INT  UNSIGNED NOT NULL,
  `bu_modified`          INT  UNSIGNED NOT NULL DEFAULT 0,
  `bu_max_devices`       SMALLINT  UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Dispositivos permitidos',
  `bu_diffusion`         MEDIUMINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total de mensajes en difusion permitidos',
  `bu_country`           TINYINT   UNSIGNED NOT NULL,
  `bu_id_category`       TINYINT   UNSIGNED NOT NULL COMMENT 'Id de la categoria a la que pertenece',
  `bu_paid_plan`         TINYINT   UNSIGNED NOT NULL DEFAULT 0 COMMENT '0:Free 1:Premiun 2:Ultimate',
  `bu_valid`             TINYINT   UNSIGNED NOT NULL DEFAULT 1 COMMENT '1: Valid 0: Invalido',
  `bu_founded`           DATE NOT NULL COMMENT 'yyyy-mm-dd',
  `bu_plan_expiration`   DATE NOT NULL DEFAULT '0000-00-00' COMMENT 'yyyy-mm-dd Si esta en plan de pago. Sin fecha para gratuito',
  `bu_name`                 VARCHAR(75)  COLLATE utf8_bin NOT NULL,
  `bu_conversa_id`          VARCHAR(6)   COLLATE utf8_bin NOT NULL,
  `bu_email`                VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `bu_password`             VARCHAR(32)  COLLATE utf8_bin NOT NULL,
  `bu_about`                VARCHAR(180) COLLATE utf8_bin NOT NULL,
  `bu_avatar_file_id`       VARCHAR(155) COLLATE utf8_bin NOT NULL,
  `bu_avatar_thumb_file_id` VARCHAR(155) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (bu_id)
)
  COMMENT='Usuarios que son negocios'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_locations`;
CREATE TABLE IF NOT EXISTS `co_locations` (
  `lo_id`             INT  UNSIGNED NOT NULL AUTO_INCREMENT,
  `lo_business_id`    INT  UNSIGNED NOT NULL,
  `lo_contact_number` INT  UNSIGNED NOT NULL,
  `lo_country`        INT  UNSIGNED NOT NULL,
  `lo_address`        VARCHAR(150) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (lo_id)
)
  COMMENT='Ubicaciones registradas por negocio'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_business_push_tokens`;
CREATE TABLE IF NOT EXISTS `co_business_push_tokens` (
  `bpt_id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bpt_business_id`  INT UNSIGNED NOT NULL COMMENT 'Id del negocio',
  `bpt_last_login`   INT UNSIGNED NOT NULL DEFAULT 0,
  `bpt_location`     INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'ID of location',
  `bpt_os_type`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1: iOS 2: Android 3: Windows 4: Otro',
  `bpt_status`       TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1: Waiting for token change  2: Already changed  (4Login)',
  `bpt_push_turn`    TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1: Waiting for push          2: Already send push(4SendLocation)',
  `bpt_add_turn`     TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1: Waiting to be added       2: Already added(4ContactAdd)',
  `bpt_token`        VARCHAR(100) COLLATE utf8_bin NOT NULL,
  `bpt_push_token`   VARCHAR(255) COLLATE utf8_bin NOT NULL COMMENT 'Value for push notifications',
  PRIMARY KEY (bpt_id)
)
  COMMENT='Lista de tokens validos para un dispositivo de un negocio'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_business_response`;
CREATE TABLE IF NOT EXISTS `co_business_response` (
    `br_id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `br_id_business`  INT UNSIGNED NOT NULL,
    `br_response`     VARCHAR(25)  NOT NULL COMMENT'keyword',
    `br_valid`        TINYINT UNSIGNED NOT NULL DEFAULT 1,
   PRIMARY KEY (br_id)
)
  COMMENT='Lista de palabras claves por negocio'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_business_unique_response`;
CREATE TABLE IF NOT EXISTS `co_business_unique_response` (
    `bur_id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `bur_id_business` INT UNSIGNED NOT NULL,
    `bur_response`    VARCHAR(200) NOT NULL,
    `bur_valid`       TINYINT UNSIGNED DEFAULT 1,
   PRIMARY KEY (bur_id)
)
  COMMENT='Respuesta unica por negocio'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_business_contact`;
CREATE TABLE IF NOT EXISTS `co_business_contact` (
  `bc_id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bc_user_id`             INT UNSIGNED NOT NULL COMMENT 'Id del negocio',
  `bc_contact_business_id` INT UNSIGNED NOT NULL COMMENT 'Id del negocio (contacto)',
  `bc_contact_user_id`     INT UNSIGNED NOT NULL COMMENT 'Id del usuario (contacto)',
  `bc_business_push_id`    INT UNSIGNED NOT NULL COMMENT 'Id relacionado de la tabla business_push_tokens',
  `bc_created`             INT UNSIGNED NOT NULL,
  `bc_valid`               TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (bc_id)
)
  COMMENT='Lista de contactos, por dispositivo, para un negocio'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */
/* ********************************************************************** */

DROP TABLE IF EXISTS `co_emoticon`;
CREATE TABLE IF NOT EXISTS `co_emoticon` (
  `em_id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `em_created`   INT UNSIGNED NOT NULL,
  `em_modified`  INT UNSIGNED NOT NULL DEFAULT 0,
  `em_name`      VARCHAR(25) COLLATE utf8_bin NOT NULL,
  `em_file_id`   VARCHAR(155) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (em_id)
)
  COMMENT='Lista de emoticons'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */

DROP TABLE IF EXISTS `co_category`;
CREATE TABLE IF NOT EXISTS `co_category` (
  `ca_id`       TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ca_created`  INT UNSIGNED NOT NULL,
  `ca_modified` INT UNSIGNED NOT NULL DEFAULT 0,
  `ca_title`    VARCHAR(30)  COLLATE utf8_bin NOT NULL,
  `ca_file_id`  VARCHAR(155) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (ca_id)
)
  COMMENT='Lista de categorias'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/* ********************************************************************** */
DROP TABLE IF EXISTS `co_plan_type`;
CREATE TABLE IF NOT EXISTS `co_plan_type` (
  `pt_id`          TINYINT   UNSIGNED NOT NULL AUTO_INCREMENT,
  `pt_diffusion`   MEDIUMINT UNSIGNED NOT NULL DEFAULT 100,
  `pt_created`     INT UNSIGNED NOT NULL,
  `pt_name`        VARCHAR(25) COLLATE utf8_bin NOT NULL,
  `pt_description` VARCHAR(100) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (pt_id)
) 
  COMMENT='Tipos de plan para negocios'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_status`;
CREATE TABLE IF NOT EXISTS `co_status` (
  `st_id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `st_created`   INT UNSIGNED NOT NULL,
  `st_status`    VARCHAR(25) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (st_id)
) 
  COMMENT='1: Online 2: Offline 3: Away 4: Invisible'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_message_type`;
CREATE TABLE IF NOT EXISTS `co_message_type` (
    `mt_id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `mt_description`  VARCHAR(32)  NOT NULL COMMENT 'Texto, Imagen, Ubicacion',
    PRIMARY KEY (mt_id)
)
  COMMENT='Tipos de mensajes'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_user_type`;
CREATE TABLE IF NOT EXISTS `co_user_type` (
    `ut_id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `ut_description`  VARCHAR(32)  NOT NULL COMMENT '1:Negocio 2:Usuario',
  PRIMARY KEY (ut_id)
)
  COMMENT='Tipos de usuario'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `co_country`;
CREATE TABLE IF NOT EXISTS `co_country` (
  `cnt_id`    TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cnt_code`  VARCHAR(5)  COLLATE utf8_bin NOT NULL,
  `cnt_name`  VARCHAR(50) COLLATE utf8_bin NOT NULL,
  `cnt_abbv`  VARCHAR(3)  COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (cnt_id)
)
  COMMENT='Lista de paises'
  ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

# CREATE UNIQUE INDEX `ST_ID_UNI_IDX`  ON `co_status` (st_id);
# CREATE UNIQUE INDEX `BL_ID_UNI_IDX`  ON `co_blackmail_list` (bl_id);
# CREATE UNIQUE INDEX `EM_ID_UNI_IDX`  ON `co_emoticon` (em_id);
# CREATE UNIQUE INDEX `PSR_ID_UNI_IDX` ON `co_password_change_request` (psr_id);
# CREATE UNIQUE INDEX `ME_ID_UNI_IDX`  ON `co_message` (me_id);
# CREATE UNIQUE INDEX `MT_ID_UNI_IDX`  ON `co_message_type` (mt_id);
# CREATE UNIQUE INDEX `SE_ID_UNI_IDX`  ON `co_servers` (se_id);
# CREATE UNIQUE INDEX `AD_ID_UNI_IDX`  ON `co_admins` (ad_id);
# CREATE UNIQUE INDEX `US_ID_UNI_IDX`  ON `co_user` (us_id);
# CREATE UNIQUE INDEX `UC_ID_UNI_IDX`  ON `co_user_contact` (uc_id);
# CREATE UNIQUE INDEX `BU_ID_UNI_IDX`  ON `co_business` (bu_id);
# CREATE UNIQUE INDEX `BPT_ID_UNI_IDX` ON `co_business_push_tokens` (bpt_id);
# CREATE UNIQUE INDEX `CA_ID_UNI_IDX`  ON `co_category` (ca_id);
# CREATE UNIQUE INDEX `UFB_ID_UNI_IDX` ON `co_user_favorite_business` (ufb_id);
# CREATE UNIQUE INDEX `BC_ID_UNI_IDX`  ON `co_block_contacts` (bc_id);
# CREATE UNIQUE INDEX `LO_ID_UNI_IDX`  ON `co_locations` (lo_id);
# CREATE UNIQUE INDEX `UT_ID_UNI_IDX`  ON `co_user_type` (ut_id_user_type);

CREATE INDEX `BL_EMAIL_IDX`               ON `co_blackmail_list` (bl_email);
CREATE INDEX `EM_NAME_IDX`                ON `co_emoticon` (em_name);
CREATE INDEX `PSR_USER_ID_IDX`            ON `co_password_change_request` (psr_user_id, psr_valid);
CREATE INDEX `PSR_TOKEN_IDX`              ON `co_password_change_request` (psr_token, psr_valid);
CREATE INDEX `ME_IDX`                     ON `co_message` (me_from_user_id,me_from_user_type,me_to_user_id,me_to_user_type,me_message_target_type,me_read_at,me_valid);
CREATE INDEX `ME_TO_IDX`                  ON `co_message` (me_to_user_id,me_to_user_type,me_message_target_type,me_read_at,me_valid);
CREATE INDEX `ME_MESSAGE_TYPE_IDX`        ON `co_message` (me_message_type);
CREATE INDEX `SE_NAME_IDX`                ON `co_servers` (se_name);
CREATE INDEX `SE_URL_IDX`                 ON `co_servers` (se_url);
CREATE INDEX `AD_BIRTHDAY_IDX`            ON `co_admins` (ad_birthday);
CREATE INDEX `AD_GENDER_IDX`              ON `co_admins` (ad_gender);
CREATE INDEX `AD_PASSWORD_IDX`            ON `co_admins` (ad_password);
CREATE INDEX `AD_AUTH_IDX`                ON `co_admins` (ad_email,ad_password);
CREATE INDEX `AD_TOKEN_IDX`               ON `co_admins` (ad_token);
CREATE INDEX `US_BIRTHDAY_IDX`            ON `co_user` (us_birthday);
CREATE INDEX `US_GENDER_IDX`              ON `co_user` (us_gender);
CREATE INDEX `US_NAME_IDX`                ON `co_user` (us_name);
CREATE INDEX `US_TOKEN_IDX`               ON `co_user` (us_token);
CREATE INDEX `US_AUTH_IDX`                ON `co_user` (us_email,us_password);
CREATE INDEX `UC_IDX`                     ON `co_user_contact` (uc_user_id,uc_contact_business_id,uc_valid);
CREATE INDEX `UC_BUSINESS_ID_IDX`         ON `co_user_contact` (uc_contact_business_id,uc_valid);
CREATE INDEX `BU_DIFFUSION_IDX`           ON `co_business` (bu_diffusion_total);
CREATE INDEX `BU_ID_CATEGORY_IDX`         ON `co_business` (bu_id_category);
CREATE INDEX `BU_PAID_PLAN_IDX`           ON `co_business` (bu_paid_plan);
CREATE INDEX `BU_CONVERSA_ID_IDX`         ON `co_business` (bu_conversa_id);
CREATE INDEX `BU_NAME_IDX`                ON `co_business` (bu_name);
CREATE INDEX `BU_AUTH_IDX`                ON `co_business` (bu_email,bu_password);
CREATE INDEX `BR_RESPONSE_IDX`            ON `co_business_response` (br_id_business, br_response, br_valid);
CREATE INDEX `BUR_ID_BUSINESS_IDX`        ON `co_business_unique_response` (bur_id_business, bur_valid);
CREATE INDEX `BC_IDX`                     ON `co_business_contact` (bc_user_id,bc_contact_user_id,bc_contact_business_id,bc_business_push_id,bc_valid);
CREATE INDEX `BC_PUSH_ID_IDX`             ON `co_business_contact` (bc_business_push_id,bc_valid);
CREATE INDEX `BPT_BUSINESS_IDX`           ON `co_business_push_tokens` (bpt_business_id,bpt_token);
CREATE INDEX `BPT_BUSINESS_LOCATION_IDX`  ON `co_business_push_tokens` (bpt_location);
CREATE INDEX `BPT_STATUS_IDX`             ON `co_business_push_tokens` (bpt_status);
CREATE INDEX `BPT_PUSH_TURN_IDX`          ON `co_business_push_tokens` (bpt_push_turn);
CREATE INDEX `BPT_ADD_TURN_IDX`           ON `co_business_push_tokens` (bpt_add_turn);
CREATE INDEX `CA_TITLE_IDX`               ON `co_category` (ca_title);
CREATE INDEX `CA_FILE_ID_IDX`             ON `co_category` (ca_file_id);
CREATE INDEX `UFB_IDX`                    ON `co_user_favorite_business` (ufb_user_id, ufb_business_id, ufb_valid);
CREATE INDEX `UFB_BUSINESS_ID_IDX`        ON `co_user_favorite_business` (ufb_business_id, ufb_valid);
CREATE INDEX `BLC_IDX`                    ON `co_block_contacts` (blc_from_id, blc_from_type, blc_to_id, blc_to_type, blc_valid);
CREATE INDEX `LO_COUNTRY_ID_IDX`          ON `co_locations` (lo_business_id, lo_country);
/*
 * METODO QUE LO INVOCA: addRemoveFavorite
 */
DROP PROCEDURE IF EXISTS `SP_UPDINS_FAVORITE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDINS_FAVORITE`(IN `i_id`         INT UNSIGNED,
                                                                 IN `i_target_id`  INT UNSIGNED,
                                                                 IN `i_action`     TINYINT UNSIGNED,
                                                                 IN `i_created`    INT UNSIGNED,
                                                                 OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    # Obtener id de registro
    DECLARE id INT UNSIGNED;

    # REMOVE
    IF i_action = 0 THEN
        SELECT `ufb_id`
        INTO id
        FROM  `co_user_favorite_business`
        WHERE `ufb_user_id`     = i_id
        AND   `ufb_business_id` = i_target_id 
        AND   `ufb_valid`       = 1 LIMIT 1;

        IF (id IS NOT NULL) THEN
            # Exito
            UPDATE `co_user_favorite_business`
            SET    `ufb_valid`    = 0,
                   `ufb_modified` = i_created
            WHERE  `ufb_id` = id;

            SET o_result = 1;
        ELSE
            # No existe registro. Se regresa exito para quitar favorito
            SET o_result = 2;
        END IF;
    ELSE
        # ADD
        IF i_action = 1 THEN
            SELECT `ufb_id`
            INTO id
            FROM  `co_user_favorite_business`
            WHERE `ufb_user_id`     = i_id
            AND   `ufb_business_id` = i_target_id LIMIT 1;

            IF (id IS NOT NULL) THEN
                # Ya esta agregado
                UPDATE `co_user_favorite_business`
                SET    `ufb_valid`    = 1,
                       `ufb_modified` = i_created
                WHERE  `ufb_id` = id;

                SET o_result = 2;
            ELSE
                INSERT INTO `co_user_favorite_business` (
                `ufb_user_id`,
                `ufb_business_id`,
                `ufb_created`,
                `ufb_valid`)
                VALUES (i_id, i_target_id, i_created, 1);

                # Exito
                SET o_result = 1;
            END IF;
        ELSE
            # Action not defined
            SET o_result = 0;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO INVOCA: blockContact
 */
DROP PROCEDURE IF EXISTS `SP_UPDINS_BLOCK_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDINS_BLOCK_CONTACT`(IN `i_id`          INT UNSIGNED,
                                                                      IN `i_target_id`   INT UNSIGNED,
                                                                      IN `i_type`        TINYINT UNSIGNED,
                                                                      IN `i_target_type` TINYINT UNSIGNED,
                                                                      IN `i_action`      TINYINT UNSIGNED,
                                                                      IN `i_created`     INT UNSIGNED,
                                                                      OUT `o_result`     TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    # Obtener id de registro
    DECLARE id INT UNSIGNED;

    # UNBLOCK
    IF i_action = 0 THEN
        SELECT `blc_id`
        INTO id
        FROM  `co_block_contacts`
        WHERE `blc_from_id`   = i_id
        AND   `blc_from_type` = i_type
        AND   `blc_to_id`     = i_target_id
        AND   `blc_to_type`   = i_target_type
        AND   `blc_valid`     = 1 LIMIT 1;

        IF (id IS NOT NULL) THEN
            # Actualiza a invalido
            UPDATE `co_block_contacts`
            SET    `blc_valid`    = 0,
                   `blc_modified` = i_created
            WHERE  `blc_id`    = id;
            # Ya existia el registro. Se actualiza y regresa exito para desbloqueo
            SET o_result = 1;
        ELSE
            # No existe registro de bloqueo. Se regresa exito para desbloqueo.
            SET o_result = 2;
        END IF;
    ELSE
        # BLOCK
        IF i_action = 1 THEN
            SELECT `blc_id`
            INTO id
            FROM  `co_block_contacts`
            WHERE `blc_from_id`   = i_id
            AND   `blc_from_type` = i_type
            AND   `blc_to_id`     = i_target_id
            AND   `blc_to_type`   = i_target_type LIMIT 1;

            IF (id IS NOT NULL) THEN
                # Actualiza a valido
                UPDATE `co_block_contacts`
                SET    `blc_valid`    = 1,
                       `blc_modified` = i_created
                WHERE  `blc_id`    = id;
                # Ya existia el registro. Se actualiza y regresa exito para bloqueo
                SET o_result = 2;
            ELSE
                INSERT INTO `co_block_contacts` (
                `blc_from_id`,
                `blc_to_id`,
                `blc_from_type`,
                `blc_to_type`,
                `blc_created`)
                VALUES (i_id, i_target_id, i_type, i_target_type, i_created);

                # Exito
                SET o_result = 1;
            END IF;
        ELSE
            # Action not defined
            SET o_result = 0;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_USER_INFO`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_USER_INFO`(IN `i_name`                  VARCHAR(255) CHARSET utf8,
                                                               IN `i_about`                 VARCHAR(180) CHARSET utf8,
                                                               IN `i_birthday`              DATE,
                                                               IN `i_gender`                TINYINT UNSIGNED,
                                                               IN `i_avatar_file_id`        VARCHAR(155) CHARSET utf8,
                                                               IN `i_avatar_thumb_file_id`  VARCHAR(155) CHARSET utf8,
                                                               IN `i_modified`              INT UNSIGNED,
                                                               IN `i_email`                 VARCHAR(255) CHARSET utf8,
                                                               IN `i_password`              VARCHAR(110) CHARSET utf8,
                                                               IN `i_id`                    INT UNSIGNED,
                                                               IN `i_action`                TINYINT UNSIGNED,
                                                               OUT `o_result`               TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # Secure
    IF i_action = 1 THEN
        IF (SELECT 1 = 1 FROM `co_user` WHERE  `us_id` = i_id) THEN
            UPDATE `co_user`
            SET 
                `us_name`           = i_name,
                `us_about`          = i_about,
                `us_birthday`       = i_birthday,
                `us_gender`         = i_gender,
                `us_avatar_file_id` = i_avatar_file_id,
                `us_modified`       = i_modified,
                `us_avatar_thumb_file_id` = i_avatar_thumb_file_id
            WHERE `us_id` = i_id;

            SET o_result = 1;
        ELSE
            SET o_result = 0;
        END IF;
    ELSE
        # Non secure
        IF i_action = 2 THEN
            IF (SELECT 1 = 1 FROM `co_user` WHERE  `us_id` = i_id) THEN
                UPDATE `co_user`
                SET 
                    `us_name`           = i_name,
                    `us_email`          = i_email,
                    `us_password`       = i_password,
                    `us_about`          = i_about,
                    `us_birthday`       = i_birthday,
                    `us_gender`         = i_gender,
                    `us_avatar_file_id` = i_avatar_file_id,
                    `us_modified`       = i_modified,
                    `us_avatar_thumb_file_id` = i_avatar_thumb_file_id
                WHERE `us_id` = i_id;

                SET o_result = 1;
            ELSE
                SET o_result = 0;
            END IF;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_USER_APP_INFO`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_USER_APP_INFO`(IN `i_action`        INT UNSIGNED,
                                                                   IN `i_id`            INT UNSIGNED,
                                                                   IN `i_time_modified` INT UNSIGNED,
                                                                   IN `i_value`         VARCHAR(255) CHARSET utf8,
                                                                   OUT `o_result`       INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE x INT DEFAULT 1;
    DECLARE date_birthday DATE;
    DECLARE int_gender INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # iOS Token
    IF i_action = 1 THEN
        UPDATE `co_user`
        SET    `us_ios_push_token` = i_value,
               `us_android_push_token` = "",
               `us_modified`  = i_time_modified
        WHERE  `us_id` = i_id;
    ELSE
        # Android Token
        IF i_action = 2 THEN
            UPDATE `co_user`
            SET    `us_android_push_token` = i_value,
                   `us_ios_push_token` = "",
                   `us_modified`  = i_time_modified
            WHERE  `us_id` = i_id;
        ELSE
            # Email
            IF i_action = 3 THEN
                UPDATE `co_user`
                SET    `us_email` = i_value,
                       `us_modified`  = i_time_modified
                WHERE  `us_id` = i_id;
            ELSE
                # Nombre de usuario
                IF i_action = 4 THEN
                    UPDATE `co_user`
                    SET    `us_name` = i_value,
                           `us_modified`  = i_time_modified
                    WHERE  `us_id` = i_id;
                ELSE
                    # Password
                    IF i_action = 5 THEN
                        UPDATE `co_user`
                        SET    `us_password` = i_value,
                               `us_modified`  = i_time_modified
                        WHERE  `us_id` = i_id;
                    ELSE
                        # Birthday
                        IF i_action = 6 THEN
                            SELECT CONVERT(i_value,DATE) INTO date_birthday;

                            UPDATE `co_user`
                            SET    `us_birthday` = date_birthday,
                                   `us_modified`  = i_time_modified
                            WHERE  `us_id` = i_id;
                        ELSE
                            # Gender
                            IF i_action = 7 THEN
                                SELECT CONVERT(i_value,UNSIGNED) INTO int_gender;

                                UPDATE `co_user`
                                SET    `us_gender` = int_gender,
                                       `us_modified`  = i_time_modified
                                WHERE  `us_id` = i_id;
                            ELSE
                                # ERROR
                                SET x = 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    IF x = 1 THEN
        SET o_result = 1;
    ELSE
        SET o_result = 0;
    END IF;

END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO LLAMA: removeContact
 */
DROP PROCEDURE IF EXISTS `SP_UPD_USER_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_USER_CONTACT`(IN `i_user_id`    INT UNSIGNED,
                                                                  IN `i_contact_id` INT UNSIGNED,
                                                                  OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    SELECT `uc_id`
    INTO id
    FROM `co_user_contact`
    WHERE `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id LIMIT 1;

    IF (id IS NOT NULL) THEN

        UPDATE `co_user_contact`
        SET    `uc_valid` = 0
        WHERE  `uc_id` = id;

        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_SERVER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_SERVER`(IN `i_id`       TINYINT UNSIGNED,
                                                            IN `i_name`     VARCHAR(100) CHARSET utf8,
                                                            IN `i_url`      VARCHAR(255) CHARSET utf8,
                                                            IN `i_modified` INT UNSIGNED,
                                                            OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_servers` WHERE `se_id` = i_id LIMIT 1) THEN
        UPDATE `co_servers`
        SET `se_name`     = i_name,
            `se_url`      = i_url,
            `se_modified` = i_modified
        WHERE `se_id` = i_id;
        #regresar un valor de exito
        SET o_result = 1;
    ELSE
        #regresar un valor de error
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_PASSWORD`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_PASSWORD`(IN `i_user_id`  INT UNSIGNED,
                                                              IN `i_new_pass` VARCHAR(110) CHARSET utf8,
                                                              OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_user` WHERE `us_id` = i_user_id) THEN
        UPDATE `co_user`
        SET    `us_password` = i_new_pass
        WHERE  `us_id`       = i_user_id;

        IF (SELECT 1 = 1 FROM `co_password_change_request` WHERE `psr_valid` = 1 AND `psr_user_id` = i_user_id LIMIT 1) THEN
            UPDATE `co_password_change_request`
            SET    `psr_valid`   = 0
            WHERE  `psr_user_id` = i_user_id;

            SET o_result = 1;
        ELSE
            # Se actualizo password pero hubo un error al actualizar la peticion de reset
            SET o_result = 2;
        END IF;
    ELSE
        IF (SELECT 1 = 1 FROM `co_password_change_request` WHERE `psr_valid` = 1 AND `psr_user_id` = i_user_id LIMIT 1) THEN
            UPDATE `co_password_change_request`
            SET    `psr_valid`   = 0
            WHERE  `psr_user_id` = i_user_id;

            SET o_result = 3;
        ELSE
            # No actualizo password y hubo un error al actualizar la peticion de reset
            SET o_result = 4;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGES_DELIVERED`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGES_DELIVERED`(IN `i_from_user_id`         INT UNSIGNED,
                                                                        IN `i_from_user_type`       TINYINT UNSIGNED,
                                                                        IN `i_to_user_id`           INT UNSIGNED,
                                                                        IN `i_to_user_type`         TINYINT UNSIGNED,
                                                                        IN `i_message_target_type`  TINYINT UNSIGNED,
                                                                        IN `i_offset`               INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
#   DECLARE lastId INT UNSIGNED;
#    
#    SELECT `me_id` INTO lastId
#    FROM   `co_message`
#    WHERE  `co_message`.`me_from_user_id`        = i_to_user_id
#    AND    `co_message`.`me_from_user_type`      = i_to_user_type
#    AND    `co_message`.`me_to_user_id`          = i_from_user_id
#    AND    `co_message`.`me_to_user_type`        = i_from_user_type
#    AND    `co_message`.`me_message_target_type` = i_message_target_type
#    AND    `co_message`.`me_delivered`           = 0
#    LIMIT 1
#    OFFSET i_offset;
    
    UPDATE `co_message`
    SET    `me_delivered` = 1
    WHERE  `co_message`.`me_from_user_id`        = i_to_user_id
    AND    `co_message`.`me_from_user_type`      = i_to_user_type
    AND    `co_message`.`me_to_user_id`          = i_from_user_id
    AND    `co_message`.`me_to_user_type`        = i_from_user_type
    AND    `co_message`.`me_message_target_type` = i_message_target_type
    AND    `co_message`.`me_delivered`           = 0
    LIMIT 200;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGES_DELIVERED_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGES_DELIVERED_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    UPDATE `co_message`
    SET    `me_delivered` = 1
    WHERE  `me_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGE_REPORT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGE_REPORT`(IN `i_id_message` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
    # Verifica si existe el mensaje
    IF (SELECT 1 = 1 FROM `co_message` WHERE `me_id` = i_id_message) THEN
        UPDATE `co_message`
        SET    `me_report_count` = `me_report_count` + 1
        WHERE  `me_id` = i_id_message;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGE_READ_AT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGE_READ_AT`(IN `i_from_user_id`    INT UNSIGNED,
                                                                     IN `i_to_user_id`      INT UNSIGNED,
                                                                     IN `i_from_user_type`  TINYINT UNSIGNED,
                                                                     IN `i_to_user_type`    TINYINT UNSIGNED,
                                                                     IN `i_new_read_at`     INT UNSIGNED,
                                                                     OUT `o_total`          INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE x INT;
    SELECT COUNT(*)
    INTO x
    FROM `co_message`
    WHERE `me_from_user_id`   = i_from_user_id
    AND   `me_to_user_id`     = i_to_user_id
    AND   `me_from_user_type` = i_from_user_type
    AND   `me_to_user_type`   = i_to_user_type
    AND   `me_message_target_type` = 1
    AND   `me_read_at` = 0;

    IF (x > 0) THEN
        UPDATE `co_message`
        SET `me_read_at` = i_new_read_at
        WHERE `me_from_user_id`   = i_from_user_id  AND `me_from_user_type` = i_from_user_type
        AND   `me_to_user_id`     = i_to_user_id    AND `me_to_user_type`   = i_to_user_type
        AND   `me_message_target_type` = 1          AND `me_read_at`        = 0;
    END IF;

    SET o_total = x;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_EMOTICON`(IN `i_id`       INT UNSIGNED,
                                                              IN `i_title`    VARCHAR(25) CHARSET utf8,
                                                              IN `i_picture`  VARCHAR(155) CHARSET utf8,
                                                              IN `i_modified` INT UNSIGNED,
                                                              OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_emoticon` WHERE `em_id` = i_id LIMIT 1) THEN
        UPDATE `co_emoticon`
        SET `em_name`     = i_title,
            `em_file_id`  = i_picture,
            `em_modified` = i_modified
        WHERE `em_id` = i_id;
        #regresar un valor de exito
        SET o_result = 1;
    ELSE
        #regresar un valor de error
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_CATEGORY`(IN `i_id`       TINYINT UNSIGNED,
                                                              IN `i_title`    VARCHAR(30)  CHARSET utf8,
                                                              IN `i_picture`  VARCHAR(155) CHARSET utf8,
                                                              IN `i_modified` INT UNSIGNED,
                                                              OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_id` = i_id LIMIT 1) THEN
        IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_title` = i_id LIMIT 1) THEN
            UPDATE `co_category`
            SET `ca_title`    = i_title,
                `ca_file_id`  = i_picture,
                `ca_modified` = i_modified
            WHERE `ca_id` = i_id;
            SET o_result = 1;
        ELSE
            SET o_result = 2;
        END IF;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_BUS_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_LOCATION`(IN `i_id`             INT UNSIGNED,
                                                                  IN `i_contact_number` INT UNSIGNED,
                                                                  IN `i_modified`       INT UNSIGNED,
                                                                  IN `i_country`        TINYINT UNSIGNED,
                                                                  IN `i_address`        VARCHAR(150) CHARSET utf8,
                                                                  IN `i_status`         TINYINT UNSIGNED,
                                                                  OUT `o_result`        TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # Ya esta agregado
    UPDATE `co_business_location`
    SET    `blo_contact_number` = i_contact_number,
           `blo_modified`       = i_modified,
           `blo_country`        = i_country,
           `blo_address`        = i_address,
           `blo_valid`          = i_status
    WHERE `blo_id` = i_id;

    SET o_result = 1;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO LLAMA: removeContactBusiness
 */
DROP PROCEDURE IF EXISTS `SP_UPD_BUS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_CONTACT`(IN `i_business_id` INT UNSIGNED,
                                                                 IN `i_contact_id`  INT UNSIGNED,
                                                                 IN `i_buspush_id`  INT UNSIGNED,
                                                                 OUT `o_result`     TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    SELECT `bc_id`
    INTO   id
    FROM   `co_business_contact`
    WHERE  `bc_user_id`             = i_business_id
    AND    `bc_contact_user_id`     = i_contact_id
    AND    `bc_contact_business_id` = 0
    AND    `bc_business_push_id`    = i_buspush_id
    AND    `bc_valid`               = 1 LIMIT 1;

    IF (id IS NOT NULL) THEN
        UPDATE `co_business_contact`
        SET    `bc_valid` = 0
        WHERE  `bc_id` = id;

        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_BUS_APP_INFO`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_APP_INFO`(IN `i_action`        TINYINT UNSIGNED,
                                                                  IN `i_id`            INT UNSIGNED,
                                                                  IN `i_token`         VARCHAR(100) CHARSET utf8,
                                                                  IN `i_time_modified` INT UNSIGNED,
                                                                  IN `i_value`         VARCHAR(255) CHARSET utf8,
                                                                  OUT `o_result`       TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE x INT DEFAULT 1;

    # iOS Token
    IF i_action = 1 THEN
        # Limpiar tokens parecidos
        UPDATE `co_business_push_tokens`
        SET    `bpt_push_token` = '',
               `bpt_os_type`    = 0
        WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token AND `bpt_push_token` = i_value AND `bpt_os_type` = 1;
        # Actualizar
        UPDATE `co_business_push_tokens`
        SET    `bpt_push_token` = i_value,
               `bpt_os_type`    = 1
        WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token;
    ELSE
        # Android Token
        IF i_action = 2 THEN
            # Limpiar tokens parecidos
            UPDATE `co_business_push_tokens`
            SET    `bpt_push_token` = '',
                   `bpt_os_type`    = 0
            WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token AND `bpt_push_token` = i_value AND `bpt_os_type` = 2;
            # Actualizar
            UPDATE `co_business_push_tokens`
            SET    `bpt_push_token` = i_value,
                   `bpt_os_type`    = 2
            WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token;
        ELSE
            # Email
            IF i_action = 3 THEN
                UPDATE  `co_business`
                SET     `bu_email`    = i_value,
                        `bu_modified` = i_time_modified
                WHERE   `bu_id` = i_id;
            ELSE
                # Nombre de usuario
                IF i_action = 4 THEN
                    UPDATE  `co_business`
                    SET     `bu_name`     = i_value,
                            `bu_modified` = i_time_modified
                    WHERE   `bu_id` = i_id;
                ELSE
                    # Password
                    IF i_action = 5 THEN
                        UPDATE  `co_business`
                        SET     `bu_password` = i_value,
                                `bu_modified` = i_time_modified
                        WHERE   `bu_id` = i_id;
                    ELSE
                        # ERROR
                        SET x = 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    IF x = 1 THEN
        SET o_result = 1;
    ELSE
        SET o_result = 0;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_UPD_ADMIN_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_ADMIN_TOKEN`(IN `i_id`         INT UNSIGNED,
                                                                 IN `i_token`      VARCHAR(100) CHARSET utf8,
                                                                 IN `i_last_login` INT UNSIGNED,
                                                                 OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;


    IF (SELECT 1 = 1 FROM `co_admins` WHERE `ad_id` = i_id) THEN
        UPDATE `co_admins`
        SET    `ad_token`       = i_token,
               `ad_last_login`  = i_last_login
        WHERE  `ad_id` = i_id;

        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USERS_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USERS_BY_ID_APP`(IN `i_ids` TEXT) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SET @sql = CONCAT('SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_gender` AS `gender`, `us_avatar_thumb_file_id` AS `avatar_thumb_file_id` FROM `co_user` WHERE `us_id` IN (', i_ids, ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USER_MESSAGES`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_MESSAGES`(IN `i_from_user_id`         INT UNSIGNED,
                                                                   IN `i_from_user_type`       TINYINT UNSIGNED,
                                                                   IN `i_to_user_id`           INT UNSIGNED,
                                                                   IN `i_to_user_type`         TINYINT UNSIGNED,
                                                                   IN `i_message_target_type`  TINYINT UNSIGNED,
                                                                   IN `i_count`                INT UNSIGNED,
                                                                   IN `i_offset`               INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
        SELECT
            `co_message`.`me_id`                   AS `_id`,
            `co_message`.`me_from_user_id`         AS `from_user_id`,
            `co_message`.`me_to_user_id`           AS `to_user_id`,
            `co_message`.`me_created`              AS `created`,
            `co_message`.`me_modified`             AS `modified`,
            `co_message`.`me_read_at`              AS `read_at`,
            `co_message`.`me_message_type`         AS `message_type`,
            `co_message`.`me_from_user_type`       AS `from_user_type`,
            `co_message`.`me_to_user_type`         AS `to_user_type`,
            `co_message`.`me_message_target_type`  AS `message_target_type`,
            `co_message`.`me_body`                 AS `body`,
            `co_message`.`me_picture_file_id`      AS `picture_file_id`,
            `co_message`.`me_longitude`            AS `longitude`,
            `co_message`.`me_latitude`             AS `latitude`
        FROM  `co_message`
        FORCE INDEX(ME_IDX)
        WHERE `co_message`.`me_from_user_id`        = i_from_user_id
        AND   `co_message`.`me_from_user_type`      = i_from_user_type
        AND   `co_message`.`me_to_user_id`          = i_to_user_id
        AND   `co_message`.`me_to_user_type`        = i_to_user_type
        AND   `co_message`.`me_message_target_type` = i_message_target_type
    UNION ALL
        SELECT
            `co_message`.`me_id`                   AS `_id`,
            `co_message`.`me_from_user_id`         AS `from_user_id`,
            `co_message`.`me_to_user_id`           AS `to_user_id`,
            `co_message`.`me_created`              AS `created`,
            `co_message`.`me_modified`             AS `modified`,
            `co_message`.`me_read_at`              AS `read_at`,
            `co_message`.`me_message_type`         AS `message_type`,
            `co_message`.`me_from_user_type`       AS `from_user_type`,
            `co_message`.`me_to_user_type`         AS `to_user_type`,
            `co_message`.`me_message_target_type`  AS `message_target_type`,
            `co_message`.`me_body`                 AS `body`,
            `co_message`.`me_picture_file_id`      AS `picture_file_id`,
            `co_message`.`me_longitude`            AS `longitude`,
            `co_message`.`me_latitude`             AS `latitude`
        FROM  `co_message`
        FORCE INDEX(ME_IDX)
        WHERE `co_message`.`me_from_user_id`        = i_to_user_id
        AND   `co_message`.`me_from_user_type`      = i_to_user_type
        AND   `co_message`.`me_to_user_id`          = i_from_user_id
        AND   `co_message`.`me_to_user_type`        = i_from_user_type
        AND   `co_message`.`me_message_target_type` = i_message_target_type
    LIMIT i_count
    OFFSET i_offset;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USER_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_COUNT`(OUT `o_total` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT COUNT(1)
    INTO o_total
    FROM `co_user`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USER_BY_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_BY_TOKEN`(IN `i_token` VARCHAR(100) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `us_id`                   AS `_id`,
        `us_name`                 AS `name`,
        `us_email`                AS `email`,
        `us_about`                AS `about`,
        `us_token`                AS `token`,
        `us_birthday`             AS `birthday`,
        `us_gender`               AS `gender`,
        `us_avatar_file_id`       AS `avatar_file_id`,
        `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
    FROM `co_user` WHERE `us_token` = i_token;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USER_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_BY_ID`(IN `i_os` INT UNSIGNED,
                                                                IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    # iOS
    IF i_os = 1 THEN
        SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`,
                `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`, `us_ios_push_token` AS `ios_push_token`
        FROM    `co_user` WHERE `us_id` = i_id;
    ELSE
        # Android
        IF i_os = 2 THEN
            SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`,
                    `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`, `us_android_push_token` AS `android_push_token`
            FROM    `co_user` WHERE `us_id` = i_id;
        ELSE
            # Both OS
            IF i_os = 3 THEN
                SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`,
                        `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`,`us_android_push_token` AS `android_push_token`, 
                        `us_ios_push_token` AS `ios_push_token`
                FROM    `co_user` WHERE `us_id` = i_id;
            ELSE
                #Just simple select info
                SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`,  `us_password` AS `password`, `us_about` AS `about`,
                        `us_token` AS `token`, `us_birthday` AS `birthday`, `us_gender`AS `gender`, `us_avatar_file_id` AS `avatar_file_id`,
                        `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
                FROM `co_user` WHERE `us_id` = i_id;
            END IF;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USER_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_BY_ID_APP`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_gender` AS `gender`, `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
    FROM `co_user` WHERE `us_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USER_BY_EMAIL_NAME`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_BY_EMAIL_NAME`(IN `i_action`  TINYINT UNSIGNED,
                                                                        IN `i_value`   VARCHAR(255) CHARSET utf8,
                                                                        OUT `o_result` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    # Name
    IF i_action = 1 THEN
        IF (SELECT 1 = 1 FROM `co_user` WHERE `us_name` = i_value LIMIT 1) THEN
            SELECT `us_id`
            INTO o_result
            FROM   `co_user`
            WHERE  `us_name` = i_value;
        ELSE
            SET o_result = 0;
        END IF;
    ELSE
        # Email
        IF i_action = 2 THEN
            IF (SELECT 1 = 1 FROM `co_user` WHERE `us_email` = i_value LIMIT 1) THEN
                SELECT `us_id`
                INTO o_result
                FROM   `co_user`
                WHERE  `us_email` = i_value;
            ELSE
                SET o_result = 0;
            END IF;
        ELSE
            SET o_result = 0;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_USBU_CONTACTS_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USBU_CONTACTS_BY_ID`(IN `i_type`    TINYINT UNSIGNED,
                                                                         IN `i_id`      INT UNSIGNED,
                                                                         IN `i_token`   VARCHAR(100) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    # Business type
    IF i_type = 1 THEN
        SELECT  `bc_contact_user_id` AS `contact_u`,`bc_contact_business_id` AS `contact_b`
        FROM    `co_business_contact`
        WHERE   `bc_business_push_id` = ( 
            SELECT  `bpt_id`
            FROM    `co_business_push_tokens`
            WHERE   `bpt_business_id` = i_id AND `bpt_token` = i_token
        ) AND `bc_valid` = 1;
    ELSE
        # User type
        IF i_type = 2 THEN
            SELECT  `uc_contact_business_id` AS `contact_b`
            FROM    `co_user_contact`
            WHERE   `uc_user_id` = i_id
                AND `uc_valid`   = 1;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO INVOCA: findContactsById
 */
DROP PROCEDURE IF EXISTS `SP_SEL_USBU_CONTACTS_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USBU_CONTACTS_BY_ID`(IN `i_type`    TINYINT UNSIGNED,
                                                                         IN `i_id`      INT UNSIGNED,
                                                                         IN `i_token`   VARCHAR(100) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE id INT UNSIGNED;
    
    # Business type
    IF i_type = 1 THEN
        SELECT  `bpt_id`
        INTO id
        FROM    `co_business_push_tokens`
        WHERE   `bpt_business_id` = i_id AND `bpt_token` = i_token LIMIT 1;

        IF (id IS NOT NULL) THEN
            SELECT  `bc_contact_user_id` AS `contact_u`,`bc_contact_business_id` AS `contact_b`
            FROM    `co_business_contact`
            WHERE   `bc_business_push_id` = id AND `bc_valid` = 1;
        END IF;
    ELSE
        # User type
        IF i_type = 2 THEN
            SELECT  `uc_contact_business_id` AS `contact_b`
            FROM    `co_user_contact`
            WHERE   `uc_user_id` = i_id
                AND `uc_valid`   = 1;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_SERVERS_WITH_PAGING`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SERVERS_WITH_PAGING`(IN `i_count`  INT UNSIGNED,
                                                                         IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    IF `i_count` = 0 THEN
        SELECT
            `se_id`        AS `_id`,
            `se_created`   AS `created`,
            `se_modified`  AS `modified`,
            `se_name`      AS `name`,
            `se_url`       AS `url`
        FROM `co_servers`
        ORDER BY `se_created`;
    ELSE
        SELECT
            `se_id`        AS `_id`,
            `se_created`   AS `created`,
            `se_modified`  AS `modified`,
            `se_name`      AS `name`,
            `se_url`       AS `url`
        FROM `co_servers`
        ORDER BY `se_created`
        LIMIT i_count
        OFFSET i_offset;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_SERVER_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SERVER_BY_ID`(IN `i_id` TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
    SELECT
        `se_id`        AS `_id`,
        `se_created`   AS `created`,
        `se_modified`  AS `modified`,
        `se_name`      AS `name`,
        `se_url`       AS `url`
    FROM `co_servers`
    WHERE `se_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_SERVERS_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SERVERS_COUNT`(OUT `se_count` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT COUNT(1)
    INTO   se_count
    FROM   `co_servers`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_SEARCH_BUSINESS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SEARCH_BUSINESS`(IN `i_user_id`      INT UNSIGNED,
                                                                     IN `i_target_name`  VARCHAR(30) CHARSET utf8,
                                                                     IN `i_count`        INT UNSIGNED,
                                                                     IN `i_offset`       INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT
            b.`bu_id`                   AS _id,
            b.`bu_name`                 AS name,
            b.`bu_about`                AS about,
            b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
            b.`bu_id_category`          AS id_category,
            IF(f.`ufb_id` IS NULL,0,1)  AS favorite
        FROM `co_business` b
        LEFT JOIN `co_user_favorite_business` f
        ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
        WHERE b.`bu_conversa_id` = i_target_name
    UNION
        SELECT
        b.`bu_id`                   AS _id,
        b.`bu_name`                 AS name,
        b.`bu_about`                AS about,
        b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
        b.`bu_id_category`          AS id_category,
        IF(f.`ufb_id` IS null,0,1)  AS favorite
        FROM `co_business` b
        LEFT JOIN `co_user_favorite_business` f
        ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
        WHERE b.`bu_paid_plan` <> 0
        AND   LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_target_name,'%'))
        LIMIT  i_count
        OFFSET i_offset;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_SEARCH_BUSINESS_BY_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SEARCH_BUSINESS_BY_CATEGORY`(IN `i_user_id`      INT UNSIGNED,
                                                                                 IN `i_target_name`  VARCHAR(30) CHARSET utf8,
                                                                                 IN `i_category_id`  INT UNSIGNED,
                                                                                 IN `i_count`        INT UNSIGNED,
                                                                                 IN `i_offset`       INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
        SELECT
            b.`bu_id`                   AS _id,
            b.`bu_name`                 AS name,
            b.`bu_about`                AS about,
            b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
            b.`bu_id_category`          AS id_category,
            IF(f.`ufb_id` IS NULL,0,1)  AS favorite
        FROM `co_business` b
        LEFT JOIN `co_user_favorite_business` f
        ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
        WHERE b.`bu_conversa_id` = i_target_name
        AND   b.`bu_id_category` = i_category_id
    UNION
        SELECT
            b.`bu_id`                   AS _id,
            b.`bu_name`                 AS name,
            b.`bu_about`                AS about,
            b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
            b.`bu_id_category`          AS id_category,
            IF(f.`ufb_id` IS null,0,1)  AS favorite
        FROM `co_business` b
        LEFT JOIN `co_user_favorite_business` f
        ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
        WHERE b.`bu_paid_plan` <> 0
        AND   b.`bu_id_category` = i_category_id
        AND   LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_target_name,'%'))
        LIMIT  i_count
        OFFSET i_offset;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_PASSWORD_RESET_REQUEST`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_PASSWORD_RESET_REQUEST`(IN `i_token` VARCHAR(90) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT
        `psr_id`      AS `_id`,
        `psr_user_id` AS `user_id`,
        `psr_created` AS `created`,
        `psr_valid`   AS `valid`,
        `psr_token`   AS `token`
    FROM `co_password_change_request`
    WHERE `psr_token` = i_token AND `psr_valid` = 1;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_MESSAGES_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_MESSAGES_BY_ID`(IN `i_from_user_id`         INT UNSIGNED,
                                                                    IN `i_from_user_type`       TINYINT UNSIGNED,
                                                                    IN `i_to_user_id`           INT UNSIGNED,
                                                                    IN `i_to_user_type`         TINYINT UNSIGNED,
                                                                    IN `i_message_target_type`  TINYINT UNSIGNED,
                                                                    IN `i_offset`               INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `co_message`.`me_id`                   AS `_id`,
        `co_message`.`me_from_user_id`         AS `from_user_id`,
        `co_message`.`me_to_user_id`           AS `to_user_id`,
        `co_message`.`me_created`              AS `created`,
        `co_message`.`me_modified`             AS `modified`,
        `co_message`.`me_read_at`              AS `read_at`,
        `co_message`.`me_message_type`         AS `message_type`,
        `co_message`.`me_from_user_type`       AS `from_user_type`,
        `co_message`.`me_to_user_type`         AS `to_user_type`,
        `co_message`.`me_message_target_type`  AS `message_target_type`,
        `co_message`.`me_body`                 AS `body`,
        `co_message`.`me_picture_file_id`      AS `picture_file_id`,
        `co_message`.`me_longitude`            AS `longitude`,
        `co_message`.`me_latitude`             AS `latitude`
    FROM  `co_message`
    WHERE `co_message`.`me_from_user_id`        = i_to_user_id
    AND   `co_message`.`me_from_user_type`      = i_to_user_type
    AND   `co_message`.`me_to_user_id`          = i_from_user_id
    AND   `co_message`.`me_to_user_type`        = i_from_user_type
    AND   `co_message`.`me_message_target_type` = i_message_target_type
    AND   `co_message`.`me_delivered`           = 0
    LIMIT 200;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_MESSAGE_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_MESSAGE_COUNT`(OUT `o_total` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT COUNT(1)
    INTO o_total
    FROM `co_message`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_MESSAGE_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_MESSAGE_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
      SELECT
            `me_id`                   AS `_id`,
            `me_from_user_id`         AS `from_user_id`,
            `me_to_user_id`           AS `to_user_id`,
            `me_created`              AS `created`,
            `me_modified`             AS `modified`,
            `me_read_at`              AS `read_at`,
            `me_message_type`         AS `message_type`,
            `me_from_user_type`       AS `from_user_type`,
            `me_to_user_type`         AS `to_user_type`,
            `me_message_target_type`  AS `message_target_type`,
            `me_body`                 AS `body`,
            `me_picture_file_id`      AS `picture_file_id`,
            `me_longitude`            AS `longitude`,
            `me_latitude`             AS `latitude`
      FROM `co_message`
      WHERE `me_id`  = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_LOCATION_BY_IDS_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_LOCATION_BY_IDS_APP`(IN `i_ids` TEXT) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SET @sql = CONCAT('SELECT `blo_id` AS `location_id`, `blo_business_id` AS `business_id`, `blo_address` AS `address`, `blo_short_name` AS `name` FROM `co_business_location` WHERE `blo_valid` = 1 AND `blo_business_id` IN (', i_ids, ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_LOCATION_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_LOCATION_BY_ID_APP`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `blo_id`           AS `location_id`,
        `blo_business_id`  AS `business_id`,
        `blo_address`      AS `address`,
        `blo_short_name`   AS `name`
    FROM `co_business_location` WHERE `blo_valid` = 1 AND `blo_business_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
    SELECT
        `em_id`        AS `_id`,
        `em_created`   AS `created`,
        `em_modified`  AS `modified`,
        `em_name`      AS `name`,
        `em_file_id`   AS `file_id`
    FROM `co_emoticon`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_WITH_PAGING`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_WITH_PAGING`(IN `i_count`  INT UNSIGNED,
                                                                          IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
IF `i_count` = 0 THEN
    BEGIN
        SELECT
            `em_id`        AS `_id`,
            `em_created`   AS `created`,
            `em_modified`  AS `modified`,
            `em_name`      AS `name`,
            `em_file_id`   AS `file_id`
        FROM `co_emoticon`
        ORDER BY `em_id`;
    END;
ELSE
    BEGIN
        SELECT
            `em_id`        AS `_id`,
            `em_created`   AS `created`,
            `em_modified`  AS `modified`,
            `em_name`      AS `name`,
            `em_file_id`   AS `file_id`
        FROM `co_emoticon`
        ORDER BY `em_id`
        LIMIT i_count
        OFFSET i_offset;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_COUNT`(OUT `em_count` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
    SELECT COUNT(1)
    INTO `em_count` 
    FROM `co_emoticon`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_BY_IDENTIFIER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_BY_IDENTIFIER`(IN `i_identifier` VARCHAR(25) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
    SELECT
        `em_id`        AS `_id`,
        `em_created`   AS `created`,
        `em_modified`  AS `modified`,
        `em_name`      AS `name`,
        `em_file_id`   AS `file_id`
    FROM `co_emoticon`
    WHERE `em_name` = i_identifier;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_AVATAR_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_AVATAR_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT `em_file_id` AS `file_id`
    FROM   `co_emoticon`
    WHERE  `em_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT 
        `em_id`        AS `_id`,
        `em_created`   AS `created`,
        `em_modified`  AS `modified`,
        `em_name`      AS `name`,
        `em_file_id`   AS `file_id`
    FROM `co_emoticon`
    WHERE `em_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CONV_HISTORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CONV_HISTORY`(IN `i_user_id` INT UNSIGNED,
                                                                  IN `i_count`  INT UNSIGNED,
                                                                  IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
                `me_id`                   AS `_id`, 
                `me_from_user_id`         AS `from_user_id`,
                `me_to_user_id`           AS `to_user_id`,
                `me_created`              AS `created`,
                `me_modified`             AS `modified`,
                `me_read_at`              AS `read_at`,
                `me_message_type`         AS `message_type`,
                `me_from_user_type`       AS `from_user_type`,
                `me_to_user_type`         AS `to_user_type`,
                `me_message_target_type`  AS `message_target_type`,
                `me_body`                 AS `body`,
                `me_picture_file_id`      AS `picture_file_id`,
                `me_longitude`            AS `longitude`,
                `me_latitude`             AS `latitude` 
    FROM `co_message` WHERE `me_id` IN (
           SELECT max(`me_id`) FROM `co_message` WHERE `me_from_user_id` = i_user_id GROUP BY `me_to_user_id`
        )
    ORDER BY `me_created` DESC
    LIMIT i_count
    OFFSET i_offset;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CONV_HIS_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CONV_HIS_COUNT`(IN `i_user_id` INT UNSIGNED,
                                                                    OUT `o_total`  INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT COUNT(1)
    INTO o_total
    FROM `co_message`
    WHERE `me_id` IN (
        SELECT max(`me_id`) FROM `co_message` WHERE `me_from_user_id` = i_user_id GROUP BY `me_to_user_id`
    );
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORY_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORY_COUNT`(OUT `o_count` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT COUNT(1)
    INTO o_count
    FROM `co_category`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORY_BY_NAME`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORY_BY_NAME`(IN `i_title` VARCHAR(30) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT 
        `ca_id`        AS `_id`,
        `ca_created`   AS `created`,
        `ca_modified`  AS `modified`,
        `ca_title`     AS `title`,
        `ca_file_id`   AS `file_id`
    FROM `co_category`
    WHERE LOWER(`ca_title`) = LOWER(i_title);
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORY_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORY_BY_ID`(IN `i_id` TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT 
        `ca_id`        AS `_id`,
        `ca_created`   AS `created`,
        `ca_modified`  AS `modified`,
        `ca_title`     AS `title`,
        `ca_file_id`   AS `file_id`
    FROM `co_category`
    WHERE `ca_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORIES`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORIES`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
    SELECT
        `ca_id`      AS `_id`,
        `ca_title`   AS `title`,
        `ca_file_id` AS `file_id`
    FROM `co_category`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORIES_WITH_PAGING`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORIES_WITH_PAGING`(IN `i_count`  INT UNSIGNED,
                                                                            IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
IF `i_count` = 0 THEN
    BEGIN
        SELECT
            `ca_id`        AS `_id`,
            `ca_created`   AS `created`,
            `ca_modified`  AS `modified`,
            `ca_title`     AS `title`,
            `ca_file_id`   AS `file_id`
        FROM `co_category`
        ORDER BY `ca_id`;
    END;
ELSE
    BEGIN
        SELECT
            `ca_id`        AS `_id`,
            `ca_created`   AS `created`,
            `ca_modified`  AS `modified`,
            `ca_title`     AS `title`,
            `ca_file_id`   AS `file_id`
        FROM `co_category`
        ORDER BY `ca_id`
        LIMIT i_count
        OFFSET i_offset;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORIES_NAME`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORIES_NAME`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
    SELECT
        `ca_id`    AS `_id`,
        `ca_title` AS `title`
    FROM `co_category`;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_WITH_PAGING_CRITERIA`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_WITH_PAGING_CRITERIA`(IN `i_count`      INT UNSIGNED,
                                                                              IN `i_offset`    INT UNSIGNED,
                                                                              IN `i_like_name` VARCHAR(255) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    IF `i_count` = 0 THEN
        IF i_like_name = '' THEN
            SELECT
                b.`bu_id`                   AS `_id`,
                b.`bu_name`                 AS `name`,
                b.`bu_max_devices`          AS `max_devices`,
                b.`bu_email`                AS `email`,
                b.`bu_founded`              AS `founded`,
                b.`bu_avatar_thumb_file_id` AS `avatar_thumb_file_id`,
                b.`bu_created`              AS `created`,
                t.`cnt_name`                AS `country`,
                c.`ca_title`                AS `category_name`,
                b.`bu_paid_plan`            AS `paid_plan`
            FROM      `co_business` b
            LEFT JOIN `co_category` c
            ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
            ON        b.`bu_country` = t.`cnt_id`
            ORDER BY `bu_id` ASC;
        ELSE
            SELECT
                b.`bu_id`                   AS `_id`,
                b.`bu_name`                 AS `name`,
                b.`bu_max_devices`          AS `max_devices`,
                b.`bu_email`                AS `email`,
                b.`bu_founded`              AS `founded`,
                b.`bu_avatar_thumb_file_id` AS `avatar_thumb_file_id`,
                b.`bu_created`              AS `created`,
                t.`cnt_name`                AS `country`,
                c.`ca_title`                AS `category_name`,
                b.`bu_paid_plan`            AS `paid_plan`
            FROM      `co_business` b
            LEFT JOIN `co_category` c
            ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
            ON        b.`bu_country` = t.`cnt_id`
            WHERE     LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_like_name,'%'))
            ORDER BY  `bu_id` ASC;
        END IF;
    ELSE
        IF i_like_name = '' THEN
            SELECT
                b.`bu_id`                   AS `_id`,
                b.`bu_name`                 AS `name`,
                b.`bu_max_devices`          AS `max_devices`,
                b.`bu_email`                AS `email`,
                b.`bu_founded`              AS `founded`,
                b.`bu_avatar_thumb_file_id` AS `avatar_thumb_file_id`,
                b.`bu_created`              AS `created`,
                t.`cnt_name`                AS `country`,
                c.`ca_title`                AS `category_name`,
                b.`bu_paid_plan`            AS `paid_plan`
            FROM      `co_business` b
            LEFT JOIN `co_category` c
            ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
            ON        b.`bu_country` = t.`cnt_id`
            ORDER BY `bu_id` ASC
            LIMIT i_count
            OFFSET i_offset;
        ELSE
            SELECT
                b.`bu_id`                   AS `_id`,
                b.`bu_name`                 AS `name`,
                b.`bu_max_devices`          AS `max_devices`,
                b.`bu_email`                AS `email`,
                b.`bu_founded`              AS `founded`,
                b.`bu_avatar_thumb_file_id` AS `avatar_thumb_file_id`,
                b.`bu_created`              AS `created`,
                t.`cnt_name`                AS `country`,
                c.`ca_title`                AS `category_name`,
                b.`bu_paid_plan`            AS `paid_plan`
            FROM      `co_business` b
            LEFT JOIN `co_category` c
            ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
            ON        b.`bu_country` = t.`cnt_id`
            WHERE     LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_like_name,'%'))
            ORDER BY  `bu_id` ASC
            LIMIT i_count
            OFFSET i_offset;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * used for web only
 */
DROP PROCEDURE IF EXISTS `SP_SEL_BUS_LOCATIONS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_LOCATIONS`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT  `blo_id`             AS `_id`,
            `blo_contact_number` AS `contact_number`,
            `blo_country`        AS `country`,
            `blo_address`        AS `address`,
            `blo_valid`          AS `status`,
            `blo_added`          AS `created`
    FROM    `co_business_location`
    WHERE   `blo_business_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_STATISTICS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_STATISTICS`(IN `i_id`      INT UNSIGNED,
                                                                    IN `i_push_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        (SELECT COUNT(1) FROM `co_business_response`        WHERE `br_id_business`  = i_id) AS `number_of_keys`,
        (SELECT COUNT(1) FROM `co_business_unique_response` WHERE `bur_id_business` = i_id) AS `number_of_first`,
        (SELECT COUNT(1) FROM `co_business_contact`         WHERE `bc_user_id`      = i_id  AND `bc_valid`  = 1) AS `number_contacts`,
        (SELECT COUNT(1) FROM `co_user_favorite_business`   WHERE `ufb_business_id` = i_id  AND `ufb_valid` = 1) AS `number_of_favs`,
        (SELECT COUNT(1) FROM `co_business_location`        WHERE `blo_business_id` = i_id  AND `blo_valid` = 1) AS `number_of_locations`,
        (SELECT COUNT(1) FROM `co_message`                  WHERE `me_from_user_id` = i_id  AND `me_from_user_type` = 1) AS `total_sent`,
        (SELECT COUNT(1) FROM `co_message`                  WHERE `me_to_user_id`   = i_id  AND `me_to_user_type`   = 1) AS `total_received`,
        (SELECT COUNT(1) FROM `co_block_contacts`           WHERE `blc_from_id`     = i_id  AND `blc_from_type`     = 1  AND `blc_valid` = 1) AS `block_contacts`,
        (SELECT COUNT(1) FROM `co_message` m, `co_business_contact` c WHERE m.`me_from_user_id` = i_id AND m.`me_from_user_type` = 1 AND c.`bc_business_push_id` = i_push_id AND c.`bc_valid` = 1) AS `total_sent_by_push`,
        (SELECT COUNT(1) FROM `co_message` m, `co_business_contact` c WHERE m.`me_to_user_id`   = i_id AND m.`me_to_user_type`   = 1 AND c.`bc_business_push_id` = i_push_id AND c.`bc_valid` = 1) AS `total_received_by_push`,
        `co_business`.`bu_max_devices`  AS `max_devices_count`,
        `co_business`.`bu_diffusion`    AS `diffusion`,
        `co_category`.`ca_title`        AS `title`,
        `co_category`.`ca_id`           AS `category_avatar`,
        IF(`co_business`.`bu_plan_expiration` = '0000-00-00', 'forever', `co_business`.`bu_plan_expiration`) AS `expiration_date`
    FROM       `co_business`
    INNER JOIN `co_category`
    ON         `co_business`.`bu_id_category` = `co_category`.`ca_id`
    WHERE      `co_business`.`bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_LOCATION`(IN `i_id` INT UNSIGNED, IN `i_status` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    IF (i_id > 0) THEN
        SELECT  `blo_id`             AS `_id`,
                `blo_business_id`    AS `business_id`,
                `blo_contact_number` AS `contact_number`,
                `blo_country`        AS `country`,
                `blo_address`        AS `address`
        FROM    `co_business_location`
        WHERE   `blo_id`    = id
        AND     `blo_valid` = i_status;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_COUNT_WITH_CRITERIA`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_COUNT_WITH_CRITERIA`(IN `i_like_name` VARCHAR(255) CHARSET utf8,
                                                                             OUT `o_count`    INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    IF i_like_name = '' THEN
        SELECT
            COUNT(*) AS count
        INTO o_count
        FROM `co_business`;
    ELSE
        SELECT
            COUNT(*) AS count
        INTO o_count
        FROM `co_business`
        WHERE LOWER(`bu_name`) LIKE LOWER(CONCAT('%',i_like_name,'%'));
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_TOKEN`(IN `i_token` VARCHAR(100) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE id INT UNSIGNED;
    SELECT `bpt_id`
    INTO   id
    FROM   `co_business_push_tokens`
    WHERE  `bpt_token` = i_token LIMIT 1;

    IF(id IS NOT NULL) THEN
        SELECT 
            b.`bu_id`                   AS `_id`,
            b.`bu_name`                 AS `name`,
            b.`bu_max_devices`          AS `max_devices`,
            b.`bu_email`                AS `email`,
            b.`bu_founded`              AS `founded`,
            t.`cnt_name`                AS `country`,
            b.`bu_avatar_thumb_file_id` AS `avatar_thumb_file_id`,
            b.`bu_created`              AS `created`,
            c.`ca_title`                AS `category_name`,
            b.`bu_paid_plan`            AS `paid_plan`,
            p.`bpt_token`               AS `token`,
            p.`bpt_id`                  AS `push_id`
        FROM `co_business` b
        INNER JOIN `co_business_push_tokens` p
        ON p.`bpt_id` = id AND p.`bpt_business_id` = b.`bu_id`
        INNER JOIN `co_category` c
        ON   b.`bu_id_category` = c.`ca_id`
        INNER JOIN `co_country` t
        ON   b.`bu_country` = t.`cnt_id`;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_IDS_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_IDS_APP`(IN `i_ids` TEXT) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SET @sql = CONCAT('SELECT `bu_id` AS `_id`, `bu_name` AS `name`, `bu_about` AS `about`, `bu_founded` AS `founded`, `bu_avatar_thumb_file_id` AS `avatar_thumb_file_id` FROM `co_business` WHERE `bu_id` IN (', i_ids, ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `bu_id`                     AS `_id`,
        `bu_name`                   AS `name`,
        `bu_email`                  AS `email`,
        `bu_password`               AS `password`,
        `bu_about`                  AS `about`,
        `bu_founded`                AS `founded`,
        `bu_avatar_file_id`         AS `avatar_file_id`,
        `bu_avatar_thumb_file_id`   AS `avatar_thumb_file_id`,
        `bu_created`                AS `created`,
        `bu_country`                AS `country`,
        `bu_id_category`            AS `id_category`,
        `bu_paid_plan`              AS `plan`,
        `bu_max_devices`            AS `max_devices_count`,
        `bu_diffusion`              AS `diffusion`,
        `bu_plan_expiration`        AS `expiration`,
        `bu_conversa_id`            AS `conversa_id`
    FROM `co_business` WHERE `bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_ID_LOGIN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_ID_LOGIN`(IN `i_id`          INT UNSIGNED,
                                                                     IN `i_token`       VARCHAR(100) CHARSET utf8,
                                                                     IN `i_last_login`  INT UNSIGNED,
                                                                     IN `i_os`          TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN

    DECLARE maxDevices INT DEFAULT 1;
    DECLARE activeDevices INT DEFAULT 0;
    DECLARE x INT;
    DECLARE hasUpdate INT DEFAULT 0;
    DECLARE returnU TINYINT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # Obtener cuenta de dispositivos
    SELECT (SELECT COUNT(*) FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_id), `bu_max_devices`
    INTO     activeDevices, maxDevices
    FROM    `co_business`
    WHERE   `bu_id` = i_id;

    SET x = FT_FIND_LOCATION(i_id);

    IF x > 0 THEN
        # Si hay localizaciones registradas para este negocio
        IF activeDevices < maxDevices THEN
            # Agregar nuevo dispositivo
            INSERT INTO `co_business_push_tokens` (
            `bpt_business_id`,
            `bpt_token`,
            `bpt_last_login`,
            `bpt_location`,
            `bpt_os_type`)
            VALUES (i_id, i_token, i_last_login, x, i_os);

            SET returnU = 1;
        ELSE
            IF activeDevices = maxDevices THEN
                # Actualizar dispositivos
                SELECT  COUNT(1)
                INTO    hasUpdate
                FROM    `co_business_push_tokens` WHERE `bpt_business_id` = i_id AND `bpt_status` = 1;

                IF hasUpdate = 0 THEN
                    # Ya se dio la vuelta a todos los dispositivos y ahora toca reiniciar la vuelta
                    # Se actualizan todos los registros para ponerlos en estado de siguiente
                    UPDATE `co_business_push_tokens`
                    SET    `bpt_status`      = 1
                    WHERE  `bpt_business_id` = i_id;
                END IF;

                # Se sobreescribe el primer dispositivo registrado (token)
                UPDATE `co_business_push_tokens`
                SET    `bpt_last_login` = i_last_login,
                       `bpt_os_type`    = i_os,
                       `bpt_status`     = 2,
                       `bpt_token`      = i_token,
                       `bpt_push_token` = '',
                       `bpt_location`   = x
                WHERE  `bpt_business_id` = i_id AND `bpt_status` = 1
                LIMIT 1;
                
                SET returnU = 1;
            END IF;
        END IF;
    END IF;

    IF returnU = 1 THEN
        SELECT
            b.`bu_id`                   AS `_id`,
            b.`bu_name`                 AS `name`,
            b.`bu_conversa_id`          AS `conversa_id`,
            b.`bu_email`                AS `email`,
            b.`bu_about`                AS `about`,
            b.`bu_founded`              AS `founded`,
            c.`cnt_abbv`                AS `country`,
            c.`cnt_code`                AS `country_code`,
            b.`bu_avatar_thumb_file_id` AS `avatar_thumb_file_id`,
            b.`bu_created`              AS `created`,
            b.`bu_modified`             AS `modified`,
            b.`bu_id_category`          AS `id_category`,
            b.`bu_paid_plan`            AS `paid_plan`,
            b.`bu_plan_expiration`      AS `expiration`
        FROM `co_business` b
        INNER JOIN `co_country` c
        ON b.`bu_country` = c.`cnt_id`
        WHERE `bu_id` = i_id;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_ID_APP`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `bu_id`                     AS `_id`,
        `bu_name`                   AS `name`,
        `bu_about`                  AS `about`,
        `bu_founded`                AS `founded`,
        `bu_avatar_thumb_file_id`   AS `avatar_thumb_file_id`
    FROM `co_business` WHERE `bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_EMAIL_NAME`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_EMAIL_NAME`(IN `i_action`  INT UNSIGNED,
                                                                       IN `i_value`   VARCHAR(255) CHARSET utf8,
                                                                       OUT `o_result` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE id INT UNSIGNED;
    # Name
    IF i_action = 1 THEN
        SELECT `bu_id` INTO id FROM `co_business` WHERE `bu_name` = i_value LIMIT 1;
        IF (id IS NOT NULL) THEN
            SET o_result = id;
        ELSE
            SET o_result = 0;
        END IF;
    ELSE
        #Email
        IF i_action = 2 THEN
            SELECT `bu_id` INTO id FROM `co_business` WHERE `bu_email` = i_value LIMIT 1;
            IF (id IS NOT NULL) THEN
                SET o_result = id;
            ELSE
                SET o_result = 0;
            END IF;
        ELSE
            SET o_result = 0;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_CAT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_CAT`(IN `i_category_id` TINYINT UNSIGNED,
                                                                IN `i_user_id`     INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    SELECT
        b.`bu_id`                   AS _id,
        b.`bu_name`                 AS name,
        b.`bu_about`                AS about,
        b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
        b.`bu_id_category`          AS id_category,
        IF(f.`ufb_id` IS null,0,1)  AS favorite
    FROM `co_business` b
    LEFT JOIN `co_user_favorite_business` f
    ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
    WHERE b.`bu_paid_plan` <> 0
    AND   b.`bu_id_category` = i_category_id;

END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_AVATAR`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_AVATAR`(IN `i_id`   INT UNSIGNED,
                                                            IN `i_type` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    # NEGOCIO
    IF i_type = 1 THEN
        -- `bu_avatar_file_id`     AS `avatar_file_id`,
        SELECT 
            `bu_id`                    AS `_id`,
            `bu_avatar_thumb_file_id`  AS `avatar_thumb_file_id`
        FROM `co_business`
        WHERE `bu_id` = i_id;
    ELSE
        # USUARIO
        IF i_type = 2 THEN
            -- `us_avatar_file_id`     AS `avatar_file_id`,
            SELECT
                `us_id`                    AS `_id`,
                `us_avatar_thumb_file_id`  AS `avatar_thumb_file_id`
            FROM `co_user`
            WHERE `us_id` = i_id;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_ALL_SERVERS_WITHOUT_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_ALL_SERVERS_WITHOUT_ID`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT `se_name`, `se_url`
    FROM   `co_servers`
    ORDER BY `se_created` ASC;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_SEL_ADMIN_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_ADMIN_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `ad_id`                     AS `_id`,
        `ad_name`                   AS `name`,
        `ad_email`                  AS `email`,
        `ad_about`                  AS `about`,
        `ad_birthday`               AS `birthday`,
        `ad_avatar_file_id`         AS `avatar_file_id`,
        `ad_avatar_thumb_file_id`   AS `avatar_thumb_file_id`,
        `ad_created`                AS `created`,
        `ad_gender`                 AS `gender`
    FROM `co_admins` WHERE `ad_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_USER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_USER`(IN `i_name`          VARCHAR(255) CHARSET utf8,
                                                          IN `i_email`         VARCHAR(255) CHARSET utf8,
                                                          IN `i_password`      VARCHAR(110) CHARSET utf8,
                                                          IN `i_birthday`      DATE,
                                                          IN `i_gender`        TINYINT UNSIGNED,
                                                          IN `i_about`         VARCHAR(180) CHARSET utf8,
                                                          IN `i_avatar_file_id`VARCHAR(155) CHARSET utf8,
                                                          IN `i_avatar_thumb_file_id` VARCHAR(155) CHARSET utf8,
                                                          IN `i_created`       INT UNSIGNED,
                                                          IN `i_modified`      INT UNSIGNED,
                                                          OUT `o_result`       TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_user` WHERE LOWER(`us_email`) = LOWER(i_email)) THEN
        SET `o_result` = 2;
    ELSE
        IF (SELECT 1 = 1 FROM `co_user` WHERE LOWER(`us_name`) = LOWER(i_name)) THEN
            SET `o_result` = 3;
        ELSE
            INSERT INTO `co_user` (
              `us_name`,
              `us_email`,
              `us_password`,
              `us_birthday`,
              `us_gender`,
              `us_about`,
              `us_avatar_file_id`,
              `us_avatar_thumb_file_id`,
              `us_created`,
              `us_modified`)
            VALUES (
              i_name, i_email, i_password, i_birthday, i_gender, i_about,
              i_avatar_file_id, i_avatar_thumb_file_id, i_created, i_modified);

            SET `o_result` = 1;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO LLAMA: addContact
 */
DROP PROCEDURE IF EXISTS `SP_INS_USER_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_USER_CONTACT`(IN `i_user_id`    INT UNSIGNED,
                                                                  IN `i_contact_id` INT UNSIGNED,
                                                                  IN `i_created`    INT UNSIGNED,
                                                                  IN `i_from_type`  TINYINT UNSIGNED,
                                                                  IN `i_to_type`    TINYINT UNSIGNED,
                                                                  OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE x INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    SET x = FT_CAN_ADD_CONTACT(i_contact_id, i_user_id, i_to_type, i_from_type);

    IF x = 1 THEN
        # Verificar si usuario ya tiene de contacto a este negocio
        IF (SELECT 1 = 1 FROM `co_user_contact` WHERE `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id LIMIT 1) THEN
            # Verificar estado (1: Valido 2: No valido)
            IF (SELECT 1 = 1 FROM `co_user_contact` WHERE `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id AND `uc_valid` = 1 LIMIT 1) THEN
                SET o_result = 0;
            ELSE
                # Actualizar estado
                UPDATE `co_user_contact`
                SET    `uc_valid` = 1
                WHERE  `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id AND `uc_valid` = 0;

                SET o_result = 0;
            END IF;
        ELSE
            # Se agrega contacto
            INSERT INTO `co_user_contact` (
            `uc_user_id`,
            `uc_contact_business_id`,
            `uc_created`)
            VALUES (i_user_id, i_contact_id, i_created);

            SET o_result = 1;
        END IF;
    ELSE
        # Bloqueado
        SET o_result = 2;
    END IF;     
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_SERVER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SERVER`(IN `i_name`      VARCHAR(100) CHARSET utf8,
                                                            IN `i_url`       VARCHAR(255) CHARSET utf8,
                                                            IN `i_created`   INT UNSIGNED,
                                                            OUT `o_id`       TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_servers` WHERE `se_url` = i_url OR `se_name` = i_name) THEN
        SET o_id = 2;
    ELSE
        INSERT INTO `co_servers` (
            `se_name`,
            `se_url`,
            `se_created`)
        VALUES (
            i_name,
            i_url,
            i_created);

        SET o_id = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_PASSWORD_RESET_REQUEST`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_PASSWORD_RESET_REQUEST`(IN `i_id`       INT UNSIGNED,
                                                                            IN `i_token`    VARCHAR(90) CHARSET utf8,
                                                                            IN `i_created`  INT UNSIGNED,
                                                                            OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_password_change_request` WHERE `psr_user_id` = i_id AND `psr_valid` = 1 LIMIT 1) THEN
        UPDATE `co_password_change_request`
        SET `psr_token`   = i_token,
            `psr_created` = i_created
        WHERE `psr_user_id` = i_id;

        SET `o_result` = 2;
    ELSE
        INSERT INTO `co_password_change_request` (
          `psr_user_id`,
          `psr_token`,
          `psr_created`)
        VALUES (
          i_id,
          i_token,
          i_created);

        SET `o_result` = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_EMOTICON`(IN `i_name`     VARCHAR(25) CHARSET utf8,
                                                              IN `i_file_id`  VARCHAR(155) CHARSET utf8,
                                                              IN `i_created`  INT UNSIGNED,
                                                              OUT `o_id`      TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_emoticon` WHERE `em_name` = i_name) THEN
        SET o_id = 2;
    ELSE
        INSERT INTO `co_emoticon` (
          `em_name`,
          `em_file_id`,
          `em_created`)
        VALUES (
          i_name,
          i_file_id,
          i_created);

        SET o_id = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_MESSAGE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_MESSAGE`(IN `i_from_user_id`         INT UNSIGNED,
                                                             IN `i_to_user_id`           INT UNSIGNED,
                                                             IN `i_from_user_type`       INT UNSIGNED,
                                                             IN `i_to_user_type`         INT UNSIGNED,
                                                             IN `i_message`              VARCHAR(1200) CHARSET utf8,
                                                             IN `i_created`              INT UNSIGNED,
                                                             IN `i_message_type`         INT UNSIGNED,
                                                             IN `i_message_target_type`  TINYINT UNSIGNED,
                                                             IN `i_picture`              VARCHAR(155) CHARSET utf8,
                                                             IN `i_longitude`            FLOAT,
                                                             IN `i_latitude`             FLOAT,
                                                             IN `i_location`             INT UNSIGNED,
                                                             OUT `o_id`                  INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE active TINYINT DEFAULT 1;
    DECLARE EXIT HANDLER FOR 1051
    BEGIN
        SET o_id = 0;
        SELECT 'Please create table co_message first';
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
        # If you declare it inside the  BEGIN END block of a stored procedure, it will terminate stored procedure immediately.
    END;

    # Is business
    IF i_to_user_type = 1 THEN
        SET active = FT_IS_LOCATION_ACTIVE(i_to_user_id, i_location);
    END IF;

    IF active = 1 THEN
        INSERT INTO `co_message` (
            `me_from_user_id`,
            `me_to_user_id`,
            `me_created`,
            `me_from_user_type`,
            `me_to_user_type`,
            `me_message_target_type`,
            `me_body`,
            `me_message_type`,
            `me_picture_file_id`,
            `me_longitude`,
            `me_latitude`)
        VALUES (
            i_from_user_id,
            i_to_user_id,
            i_created,
            i_from_user_type,
            i_to_user_type,
            i_message_target_type,
            i_message,
            i_message_type,
            i_picture,
            i_longitude,
            i_latitude);

        SET o_id = LAST_INSERT_ID();
    ELSE
        SET o_id = 0;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_CATEGORY`(IN `i_name`     VARCHAR(30)  CHARSET utf8,
                                                              IN `i_file_id`  VARCHAR(155) CHARSET utf8,
                                                              IN `i_created`  INT UNSIGNED,
                                                              OUT `o_id`      TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_title` = i_name) THEN
        SET o_id = 2;
    ELSE
        INSERT INTO `co_category` (
          `ca_title`,
          `ca_file_id`,
          `ca_created`)
        VALUES (
          i_name,
          i_file_id,
          i_created);

        SET o_id = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_BUSINESS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUSINESS`(IN `i_created`        INT UNSIGNED,
                                                              IN `i_max_devices`    SMALLINT  UNSIGNED,
                                                              IN `i_country`        TINYINT UNSIGNED,
                                                              IN `i_category_id`    TINYINT UNSIGNED,
                                                              IN `i_paid_plan`      TINYINT UNSIGNED,
                                                              IN `i_founded`        DATE,
                                                              IN `i_expiration`     DATE,
                                                              IN `i_name`           VARCHAR(75)  CHARSET utf8,
                                                              IN `i_conversa_id`    VARCHAR(7)   CHARSET utf8,
                                                              IN `i_email`          VARCHAR(255) CHARSET utf8,
                                                              IN `i_password`       VARCHAR(32)  CHARSET utf8,
                                                              IN `i_about`          VARCHAR(180) CHARSET utf8,
                                                              IN `i_picture`        VARCHAR(155) CHARSET utf8,
                                                              IN `i_picture_avatar` VARCHAR(155) CHARSET utf8,
                                                              OUT `o_id`            TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN 
    DECLARE diffusion MEDIUMINT UNSIGNED;
    DECLARE EXIT HANDLER FOR 1051
    BEGIN
        SET o_id = 0;
        SELECT 'Please create table co_message first';
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
        # If you declare it inside the  BEGIN END block of a stored procedure, it will terminate stored procedure immediately.
    END;

    SELECT `pt_diffusion`
    INTO   diffusion
    FROM   `co_plan_type`
    WHERE  `pt_id` = i_paid_plan;

    IF(diffusion IS NOT NULL) THEN
        INSERT INTO `co_business` (
            `bu_created`,
            `bu_max_devices`,
            `bu_diffusion`,
            `bu_country`,
            `bu_id_category`,
            `bu_paid_plan`,
            `bu_founded`,
            `bu_plan_expiration`,
            `bu_name`,
            `bu_conversa_id`,
            `bu_email`,
            `bu_password`,
            `bu_about`,
            `bu_avatar_file_id`,
            `bu_avatar_thumb_file_id`)
        VALUES (
            i_created,
            i_max_devices,
            diffusion,
            i_country,
            i_category_id,
            i_paid_plan,
            i_founded,
            i_expiration,
            i_name,
            i_conversa_id,
            i_email,
            i_password,
            i_about,
            i_picture,
            i_picture_avatar);

        SET o_id = 1;
    ELSE
        SET o_id = 0;
    END IF;
    
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_INS_BUS_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUS_LOCATION`(IN `i_business_id`    INT UNSIGNED,
                                                                  IN `i_contact_number` INT UNSIGNED,
                                                                  IN `i_created`        INT UNSIGNED,
                                                                  IN `i_country`        TINYINT UNSIGNED,
                                                                  IN `i_address`        VARCHAR(150) CHARSET utf8,
                                                                  OUT `o_result`        TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # Ya esta agregado
    INSERT INTO `co_business_location`(`blo_business_id`,`blo_contact_number`,`blo_added`,`blo_country`,`blo_address`)
    VALUES (i_business_id,i_contact_number,i_created,i_country,i_address);

    SET o_result = 1;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO INVOCA: addContactBusiness
 */
DROP PROCEDURE IF EXISTS `SP_INS_BUS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUS_CONTACT`(IN `i_user_id`     INT UNSIGNED,
                                                                 IN `i_contact_id`  INT UNSIGNED,
                                                                 IN `i_buspush_id`  INT UNSIGNED,
                                                                 IN `i_created`     INT UNSIGNED,
                                                                 IN `i_from_type`   INT UNSIGNED,
                                                                 IN `i_to_type`     INT UNSIGNED,
                                                                 OUT `o_result`     INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE x TINYINT;
    DECLARE pushId INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    SET x = FT_CAN_ADD_CONTACT(i_contact_id, i_user_id, i_to_type, i_from_type);

    IF x = 1 THEN
        # Verificar si usuario ya tiene de contacto a este negocio
        IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = i_buspush_id LIMIT 1) THEN
            # Verificar estado (1: Valido 2: No valido)
            IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = i_buspush_id AND `bc_valid` = 1 LIMIT 1) THEN
                SET o_result = 0;
            ELSE
                # Actualizar estado
                UPDATE `co_business_contact`
                SET    `bc_valid` = 1
                WHERE  `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = i_buspush_id AND `bc_valid` = 0;

                SET o_result = 0;
            END IF;
        ELSE
            # Si ya esta asociado a un PUSH ID de negocio se actualiza esa referencia
            SELECT `bc_business_push_id` INTO pushId FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 LIMIT 1;
            IF(pushId IS NOT NULL) THEN
                # Actualizar estado
                UPDATE `co_business_contact`
                SET    `bc_valid` = 1,
                       `bc_business_push_id` = i_buspush_id 
                WHERE  `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = pushId;

                SET o_result = 0;
            ELSE
                # Se agrega contacto
                INSERT INTO `co_business_contact` (
                `bc_user_id`,
                `bc_contact_business_id`,
                `bc_contact_user_id`,
                `bc_business_push_id`,
                `bc_created`)
                VALUES (i_user_id, 0, i_contact_id, i_buspush_id, i_created);

                SET o_result = 1;
            END IF;
        END IF;
    ELSE
        SET o_result = 2;
    END IF;     
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO LLAMA: findValidToken
 */
DROP PROCEDURE IF EXISTS `SP_FIND_BY_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_FIND_BY_TOKEN`(IN `i_token` VARCHAR(100) CHARSET utf8,
                                                               IN `i_type`  TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

# NEGOCIO
IF i_type = 1 THEN
    BEGIN
        SELECT     b.`bu_id` AS `_id`, p.`bpt_token` AS `token`, p.`bpt_id` AS `push_id`, p.`bpt_location` AS `location_id`
        FROM       `co_business` b
        INNER JOIN `co_business_push_tokens` p
        ON  b.`bu_id` = p.`bpt_business_id`
        AND p.`bpt_token` = i_token; 
    END;
ELSE
    BEGIN
        # USUARIO
        IF i_type = 2 THEN
            BEGIN
                SELECT `us_id` AS `_id`, `us_token` AS `token`
                FROM   `co_user`
                WHERE  `us_token` = i_token;
            END;
        END IF;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_DEL_USER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_USER`(IN `i_id` INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_user` WHERE `us_id` = i_id) THEN
        DELETE FROM `co_user`
        WHERE `us_id` = i_id;
        # REGRESAR VALOR DE EXITO
        SET o_result = 1;
    ELSE
        # REGRESAR VALOR DE EXITO PORQUE YA NO EXISTE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_FIND_BUS_TO_PUSH`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_FIND_BUS_TO_PUSH`(IN `i_bussines_id`  INT UNSIGNED,
                                                                  IN `i_user_id`      INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_bussines_id AND `bc_contact_user_id` = i_user_id LIMIT 1) THEN
        # Ya es contacto y ya se tiene su push token y os
        SELECT p.`bpt_os_type` AS os_type, p.`bpt_push_token` AS push_token
        FROM `co_business_push_tokens` p
        WHERE p.`bpt_id` = (
            SELECT c.`bc_business_push_id` FROM `co_business_contact` c WHERE c.`bc_user_id` = i_bussines_id AND c.`bc_contact_user_id` = i_user_id LIMIT 1
        )
        LIMIT 1;
    ELSE
    BEGIN
        # Verificar que hayan dispositivos registrados
        DECLARE count INT UNSIGNED DEFAULT 0;

        SELECT COUNT(1)
        INTO   count
        FROM   `co_business_push_tokens`
        WHERE  `bpt_business_id` = i_bussines_id;

        IF count > 0 THEN
        BEGIN
            # No es contacto y se agrega
            DECLARE id INT UNSIGNED DEFAULT 0;

            IF (SELECT 1 = 1 FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_bussines_id AND `bpt_push_turn` = 1 LIMIT 1) THEN
                # Guardar id
                SELECT `bpt_id` INTO id FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_bussines_id AND `bpt_push_turn` = 1 LIMIT 1;
            ELSE
                # Ya se dio la vuelta a los dispositivos, se reinicia la cuenta
                UPDATE `co_business_push_tokens` SET `bpt_push_turn` = 1 WHERE `bpt_business_id` = i_bussines_id;
                # Guardar id
                SELECT `bpt_id` INTO id FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_bussines_id AND `bpt_push_turn` = 1 LIMIT 1;
            END IF;

            # Se actualiza para escoger el proximo dispositivo del negocio
            UPDATE `co_business_push_tokens` SET `bpt_push_turn` = 2 WHERE `bpt_id` = id;
            # Obtiene los datos del negocio para enviar notificacion
            SELECT `bpt_os_type` AS os_type, `bpt_push_token` AS push_token FROM `co_business_push_tokens` WHERE `bpt_id` = id;
        END;
        END IF;
    END;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_DEL_SERVER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_SERVER`(IN `i_id` TINYINT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_servers` WHERE `se_id` = i_id) THEN
        DELETE FROM `co_servers`
        WHERE `se_id` = i_id;
        # Regresar valor de exito
        SET o_result = 1;
    ELSE
        # Regresar valor de exito pero no se elimino nada
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_DEL_MESSAGE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_MESSAGE`(IN `i_id_message` INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;
    
    IF (SELECT 1 = 1 FROM `co_message` WHERE `me_id` = i_id_message) THEN
        DELETE FROM `co_message`
        WHERE `me_id` = i_id_message;
        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_DEL_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_EMOTICON`(IN `i_id` INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_emoticon` WHERE `em_id` = i_id) THEN
        DELETE FROM `co_emoticon`
        WHERE `em_id` = i_id;
        # REGRESAR VALOR DE EXITO
        SET o_result = 1;
    ELSE
        # REGRESAR VALOR DE EXITO PORQUE YA NO EXISTE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_DEL_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_CATEGORY`(IN `i_id` INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_id` = i_id) THEN
        DELETE FROM `co_category`
        WHERE `ca_id` = i_id;
        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_DEL_BUSINESS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_BUSINESS`(IN `i_id` INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;
    
    IF (SELECT 1 = 1 FROM `co_business` WHERE `bu_id` = i_id) THEN
        UPDATE `co_business`
        SET `bu_valid` = 0
        WHERE `bu_id`  = i_id;
        
        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

/*
 * METODO QUE LO LLAMA: doConversaAuth, doConversaBusinessAuth
 */
DROP PROCEDURE IF EXISTS `SP_CONVERSA_AUTH`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CONVERSA_AUTH`(IN `i_type`      TINYINT UNSIGNED,
                                                               IN `i_email`     VARCHAR(255) CHARSET utf8,
                                                               IN `i_password`  VARCHAR(32)  CHARSET utf8,
                                                               OUT `o_result`   TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE x TINYINT;
    SET x = FT_IS_IN_BLACKLIST(i_email);

    IF x = 0 THEN
        # Business type
        IF i_type = 1 THEN
            SELECT `bu_id` INTO o_result FROM `co_business` USE INDEX(BU_AUTH_IDX) WHERE `bu_email` = i_email AND `bu_password` = i_password;

            IF (o_result IS NULL) THEN
                SET o_result = 0;
            END IF;
        ELSE
            # User type
            IF i_type = 2 THEN
                SELECT `us_id` INTO o_result FROM `co_user` USE INDEX(US_AUTH_IDX) WHERE `us_email` = i_email AND `us_password` = i_password;

                IF (o_result IS NULL) THEN
                    SET o_result = 0;
                END IF;
            ELSE
                # No valid type
                SET o_result = 0;
            END IF;
        END IF;
    ELSE
        # CANT INITIATE SESSION BECAUSE IS ON BLACKLIST
        SET o_result = 0;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_CONAUTH_ADMINS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CONAUTH_ADMINS`(IN `i_type`     INT UNSIGNED,
                                                                IN `i_email`    VARCHAR(255) CHARSET utf8,
                                                                IN `i_password` VARCHAR(110) CHARSET utf8,
                                                                OUT `o_result`  INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE x INT UNSIGNED;
    
    IF i_type = 1 THEN
        SELECT `ad_id` INTO x FROM `co_admins` WHERE `ad_email` = i_email AND `ad_password` = i_password;

        IF (x IS NOT NULL) THEN
            SET o_result = x;
        ELSE
            SET o_result = 0;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP PROCEDURE IF EXISTS `SP_AUTH_APP_USER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_AUTH_APP_USER`(IN `i_id`         INT UNSIGNED,
                                                               IN `i_token`      VARCHAR(100) CHARSET utf8,
                                                               IN `i_last_login` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    IF (SELECT 1 = 1 FROM `co_user` WHERE `us_id` = i_id) THEN
        UPDATE `co_user`
        SET    `us_token`       = i_token,
               `us_last_login`  = i_last_login
        WHERE  `us_id` = i_id;

        SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`, `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
        FROM    `co_user` WHERE `us_id` = i_id;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;

DROP FUNCTION IF EXISTS `FT_IS_IN_BLACKLIST`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_IS_IN_BLACKLIST`(`i_email` VARCHAR(255) CHARSET utf8) RETURNS TINYINT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result TINYINT DEFAULT 0;

    IF (SELECT 1 = 1 FROM `co_blackmail_list` WHERE `bl_email` = i_email LIMIT 1) THEN
        # Is in blackmail list
        SET o_result = 1;
    END IF;
    
    RETURN o_result;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS `FT_IS_LOCATION_ACTIVE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_IS_LOCATION_ACTIVE`(`i_business_id` INT UNSIGNED, `i_location_id` INT UNSIGNED) RETURNS TINYINT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result TINYINT;

    SELECT `bpt_id` INTO o_result FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_business_id AND `bpt_location` = i_location_id LIMIT 1;

    IF (o_result IS NULL) THEN
        # No se encontro alguna ubicacion registrada para este negocio
        SET o_result = 0;
    ELSE
        SET o_result = 1;
    END IF;
    
    RETURN o_result;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS `FT_FIND_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_FIND_LOCATION`(`i_id` INT UNSIGNED) RETURNS INT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result INT;

    SELECT `blo_id` INTO o_result FROM `co_business_location` WHERE `blo_business_id` = i_id AND `blo_valid` = 1 LIMIT 1;

    IF (o_result IS NULL) THEN
        # No se encontro alguna ubicacion registrada para este negocio
        SET o_result = 0;
    END IF;
    
    RETURN o_result;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS `FT_CAN_ADD_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_CAN_ADD_CONTACT`(`i_from_id`     INT UNSIGNED,
                                                                `i_to_id`       INT UNSIGNED,
                                                                `i_from_type`   TINYINT UNSIGNED,
                                                                `i_to_type`     TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result TINYINT DEFAULT 1;

    IF (i_from_type > 2 OR i_to_type > 2) THEN
        # Non valid types
        SET o_result = 0;
    ELSE
        IF (SELECT 1 = 1 FROM `co_block_contacts` WHERE `blc_from_id` = i_from_id AND `blc_from_type` = i_from_type AND `blc_to_id` = i_to_id  AND `blc_to_type` = i_to_type AND `blc_valid` = 1) THEN
            # Is blocked
            SET o_result = 0;
        END IF;
    END IF;
    
    RETURN o_result;
END$$
DELIMITER ;



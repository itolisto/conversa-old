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
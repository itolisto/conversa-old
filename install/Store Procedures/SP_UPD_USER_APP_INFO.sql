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
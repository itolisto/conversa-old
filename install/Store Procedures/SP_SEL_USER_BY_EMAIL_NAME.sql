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
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
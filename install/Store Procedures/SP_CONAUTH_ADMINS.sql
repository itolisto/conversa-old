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
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
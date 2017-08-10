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
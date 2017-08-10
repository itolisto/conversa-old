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
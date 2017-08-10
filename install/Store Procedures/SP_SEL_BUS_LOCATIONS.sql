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
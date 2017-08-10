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
DROP PROCEDURE IF EXISTS `SP_SEL_LOCATION_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_LOCATION_BY_ID_APP`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT
		`blo_id`		   AS `location_id`,
		`blo_business_id`  AS `business_id`,
	  	`blo_address`	   AS `address`,
	  	`blo_short_name`   AS `name`
	FROM `co_business_location` WHERE `blo_valid` = 1 AND `blo_business_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;
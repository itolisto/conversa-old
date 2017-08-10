DROP PROCEDURE IF EXISTS `SP_SEL_LOCATION_BY_IDS_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_LOCATION_BY_IDS_APP`(IN `i_ids` TEXT) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SET @sql = CONCAT('SELECT `blo_id` AS `location_id`, `blo_business_id` AS `business_id`, `blo_address` AS `address`, `blo_short_name` AS `name` FROM `co_business_location` WHERE `blo_valid` = 1 AND `blo_business_id` IN (', i_ids, ')');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$
# change the delimiter back to semicolon
DELIMITER ;
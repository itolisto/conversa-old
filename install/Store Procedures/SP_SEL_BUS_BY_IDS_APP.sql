DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_IDS_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_IDS_APP`(IN `i_ids` TEXT) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SET @sql = CONCAT('SELECT `bu_id` AS `_id`, `bu_name` AS `name`, `bu_about` AS `about`, `bu_founded` AS `founded`, `bu_avatar_thumb_file_id` AS `avatar_thumb_file_id` FROM `co_business` WHERE `bu_id` IN (', i_ids, ')');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$
# change the delimiter back to semicolon
DELIMITER ;
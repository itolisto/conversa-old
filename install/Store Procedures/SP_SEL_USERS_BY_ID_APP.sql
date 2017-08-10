DROP PROCEDURE IF EXISTS `SP_SEL_USERS_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USERS_BY_ID_APP`(IN `i_ids` TEXT) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SET @sql = CONCAT('SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_gender` AS `gender`, `us_avatar_thumb_file_id` AS `avatar_thumb_file_id` FROM `co_user` WHERE `us_id` IN (', i_ids, ')');
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END$$
# change the delimiter back to semicolon
DELIMITER ;
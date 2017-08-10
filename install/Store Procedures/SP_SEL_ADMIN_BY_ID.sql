DROP PROCEDURE IF EXISTS `SP_SEL_ADMIN_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_ADMIN_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT
		`ad_id` 					AS `_id`,
	  	`ad_name`					AS `name`,
	  	`ad_email`					AS `email`,
	  	`ad_about`					AS `about`,
	  	`ad_birthday`				AS `birthday`,
	  	`ad_avatar_file_id` 		AS `avatar_file_id`,
	  	`ad_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
	  	`ad_created`				AS `created`,
	  	`ad_gender`				    AS `gender`
	FROM `co_admins` WHERE `ad_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;
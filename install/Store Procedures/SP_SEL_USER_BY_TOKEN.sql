DROP PROCEDURE IF EXISTS `SP_SEL_USER_BY_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_BY_TOKEN`(IN `i_token` VARCHAR(100) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT
		`us_id` 				  AS `_id`,
		`us_name` 				  AS `name`,
		`us_email` 				  AS `email`,
		`us_about` 				  AS `about`,
		`us_token` 				  AS `token`,
		`us_birthday` 			  AS `birthday`,
		`us_gender`				  AS `gender`,
		`us_avatar_file_id` 	  AS `avatar_file_id`,
		`us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
	FROM `co_user` WHERE `us_token` = i_token;
END$$
# change the delimiter back to semicolon
DELIMITER ;
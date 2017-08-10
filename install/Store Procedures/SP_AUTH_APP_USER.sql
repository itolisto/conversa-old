DROP PROCEDURE IF EXISTS `SP_AUTH_APP_USER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_AUTH_APP_USER`(IN `i_id`         INT UNSIGNED,
														   	   IN `i_token`      VARCHAR(100) CHARSET utf8,
														   	   IN `i_last_login` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	IF (SELECT 1 = 1 FROM `co_user` WHERE `us_id` = i_id) THEN
		UPDATE `co_user`
		SET    `us_token` 		= i_token,
			   `us_last_login` 	= i_last_login
		WHERE  `us_id` = i_id;

		SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`, `us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
		FROM 	`co_user` WHERE `us_id` = i_id;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;
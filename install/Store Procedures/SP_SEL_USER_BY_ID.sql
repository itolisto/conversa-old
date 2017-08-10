DROP PROCEDURE IF EXISTS `SP_SEL_USER_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_USER_BY_ID`(IN `i_os` INT UNSIGNED,
														  	    IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	# iOS
	IF i_os = 1 THEN
		SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`,
				`us_avatar_thumb_file_id` AS `avatar_thumb_file_id`, `us_ios_push_token` AS `ios_push_token`
		FROM 	`co_user` WHERE `us_id` = i_id;
	ELSE
    	# Android
        IF i_os = 2 THEN
            SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`,
					`us_avatar_thumb_file_id` AS `avatar_thumb_file_id`, `us_android_push_token` AS `android_push_token`
			FROM 	`co_user` WHERE `us_id` = i_id;
        ELSE
    		# Both OS
	        IF i_os = 3 THEN
                SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`, `us_about` AS `about`, `us_token` AS `token`,
    					`us_avatar_thumb_file_id` AS `avatar_thumb_file_id`,`us_android_push_token` AS `android_push_token`, 
    					`us_ios_push_token` AS `ios_push_token`
				FROM 	`co_user` WHERE `us_id` = i_id;
	        ELSE
	        	#Just simple select info
        		SELECT  `us_id` AS `_id`, `us_name` AS `name`, `us_email` AS `email`,  `us_password` AS `password`, `us_about` AS `about`,
        				`us_token` AS `token`, `us_birthday` AS `birthday`, `us_gender`AS `gender`, `us_avatar_file_id` AS `avatar_file_id`,
        				`us_avatar_thumb_file_id` AS `avatar_thumb_file_id`
        		FROM `co_user` WHERE `us_id` = i_id;
	        END IF;
        END IF;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;
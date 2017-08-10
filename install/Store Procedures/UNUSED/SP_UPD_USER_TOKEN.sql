DROP PROCEDURE IF EXISTS `SP_UPD_USER_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_USER_TOKEN`(IN `i_id` 		  INT UNSIGNED,
															    IN `i_token` 	  VARCHAR(100) CHARSET utf8,
															    IN `i_last_login` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	IF (SELECT 1 = 1 FROM `co_user` WHERE `us_id` = i_id) THEN
		UPDATE `co_user`
		SET    `us_token` 		= i_token,
			   `us_last_login` 	= i_last_login
		WHERE  `us_id` = i_id;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;
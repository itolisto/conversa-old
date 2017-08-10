DROP PROCEDURE IF EXISTS `SP_SEL_PASSWORD_RESET_REQUEST`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_PASSWORD_RESET_REQUEST`(IN `i_token` VARCHAR(90) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
	SELECT
		`psr_id`      AS `_id`,
		`psr_user_id` AS `user_id`,
		`psr_created` AS `created`,
	 	`psr_valid`   AS `valid`,
		`psr_token`   AS `token`
	FROM `co_password_change_request`
	WHERE `psr_token` = i_token AND `psr_valid` = 1;
END$$
# change the delimiter back to semicolon
DELIMITER ;
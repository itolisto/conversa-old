DROP PROCEDURE IF EXISTS `SP_INS_BUS_DEVICE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUS_DEVICE`(IN `i_bus_id`	 INT UNSIGNED,
															    IN `i_token` 	 VARCHAR(100) CHARSET utf8,
															    IN `i_last_login` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	INSERT INTO `co_business_push_tokens` (
	`bpt_business_id`,
	`bpt_token`,
	`bpt_last_login`)
	VALUES (i_bus_id, i_token, i_last_login);
END$$
# change the delimiter back to semicolon
DELIMITER ;
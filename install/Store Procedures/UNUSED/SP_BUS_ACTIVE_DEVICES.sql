DROP PROCEDURE IF EXISTS `SP_BUS_ACTIVE_DEVICES`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BUS_ACTIVE_DEVICES`(IN `i_id`      INT UNSIGNED,
															  		OUT `o_active` INT UNSIGNED,
															  		OUT `o_max`	   INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
	SELECT (SELECT COUNT(*) FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_id), `bu_max_devices`
	INTO 	 o_active, o_max
	FROM 	`co_business`
	WHERE 	`bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;
DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_ID_APP`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_ID_APP`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT
		`bu_id` 					AS `_id`,
	  	`bu_name`					AS `name`,
	  	`bu_about`					AS `about`,
	  	`bu_founded`				AS `founded`,
	  	`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`
	FROM `co_business` WHERE `bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;
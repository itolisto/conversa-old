DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORIES_NAME`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORIES_NAME`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
	SELECT
		`ca_id`    AS `_id`,
	  	`ca_title` AS `title`
	FROM `co_category`;
END$$
# change the delimiter back to semicolon
DELIMITER ;
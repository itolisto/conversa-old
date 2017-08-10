DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORIES`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORIES`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
	SELECT
		`ca_id`      AS `_id`,
	  	`ca_title`   AS `title`,
	  	`ca_file_id` AS `file_id`
	FROM `co_category`;
END$$
# change the delimiter back to semicolon
DELIMITER ;
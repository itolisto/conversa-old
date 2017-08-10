DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORY_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORY_BY_ID`(IN `i_id` TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
	SELECT 
		`ca_id`        AS `_id`,
	  	`ca_created`   AS `created`,
	  	`ca_modified`  AS `modified`,
	  	`ca_title`     AS `title`,
  		`ca_file_id`   AS `file_id`
	FROM `co_category`
	WHERE `ca_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;
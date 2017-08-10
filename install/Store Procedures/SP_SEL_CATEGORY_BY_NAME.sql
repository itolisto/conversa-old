DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORY_BY_NAME`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORY_BY_NAME`(IN `i_title` VARCHAR(30) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
	SELECT 
		`ca_id`        AS `_id`,
	  	`ca_created`   AS `created`,
	  	`ca_modified`  AS `modified`,
	  	`ca_title`     AS `title`,
  		`ca_file_id`   AS `file_id`
	FROM `co_category`
	WHERE LOWER(`ca_title`) = LOWER(i_title);
END$$
# change the delimiter back to semicolon
DELIMITER ;
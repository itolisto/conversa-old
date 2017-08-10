DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON`() NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
	SELECT
		`em_id`        AS `_id`,
	  	`em_created`   AS `created`,
	  	`em_modified`  AS `modified`,
	  	`em_name`      AS `name`,
  		`em_file_id`   AS `file_id`
	FROM `co_emoticon`;
END$$
# change the delimiter back to semicolon
DELIMITER ;
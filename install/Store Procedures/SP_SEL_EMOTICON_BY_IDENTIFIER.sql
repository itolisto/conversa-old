DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_BY_IDENTIFIER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_BY_IDENTIFIER`(IN `i_identifier` VARCHAR(25) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
	SELECT
		`em_id`        AS `_id`,
	  	`em_created`   AS `created`,
	  	`em_modified`  AS `modified`,
	  	`em_name`      AS `name`,
  		`em_file_id`   AS `file_id`
	FROM `co_emoticon`
	WHERE `em_name` = i_identifier;
END$$
# change the delimiter back to semicolon
DELIMITER ;
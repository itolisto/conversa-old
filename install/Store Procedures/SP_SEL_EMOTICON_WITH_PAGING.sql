DROP PROCEDURE IF EXISTS `SP_SEL_EMOTICON_WITH_PAGING`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_EMOTICON_WITH_PAGING`(IN `i_count`	INT UNSIGNED,
																		  IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
IF `i_count` = 0 THEN
	BEGIN
		SELECT
			`em_id`        AS `_id`,
		  	`em_created`   AS `created`,
		  	`em_modified`  AS `modified`,
		  	`em_name`      AS `name`,
	  		`em_file_id`   AS `file_id`
		FROM `co_emoticon`
		ORDER BY `em_id`;
	END;
ELSE
	BEGIN
		SELECT
			`em_id`        AS `_id`,
		  	`em_created`   AS `created`,
		  	`em_modified`  AS `modified`,
		  	`em_name`      AS `name`,
	  		`em_file_id`   AS `file_id`
		FROM `co_emoticon`
		ORDER BY `em_id`
		LIMIT i_count
		OFFSET i_offset;
	END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;
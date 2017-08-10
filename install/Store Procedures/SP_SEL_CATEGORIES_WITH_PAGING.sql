DROP PROCEDURE IF EXISTS `SP_SEL_CATEGORIES_WITH_PAGING`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CATEGORIES_WITH_PAGING`(IN `i_count`  INT UNSIGNED,
																		  	IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
IF `i_count` = 0 THEN
	BEGIN
		SELECT
			`ca_id`        AS `_id`,
		  	`ca_created`   AS `created`,
		  	`ca_modified`  AS `modified`,
		  	`ca_title`     AS `title`,
	  		`ca_file_id`   AS `file_id`
		FROM `co_category`
		ORDER BY `ca_id`;
	END;
ELSE
	BEGIN
		SELECT
			`ca_id`        AS `_id`,
		  	`ca_created`   AS `created`,
		  	`ca_modified`  AS `modified`,
		  	`ca_title`     AS `title`,
	  		`ca_file_id`   AS `file_id`
		FROM `co_category`
		ORDER BY `ca_id`
		LIMIT i_count
		OFFSET i_offset;
	END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;
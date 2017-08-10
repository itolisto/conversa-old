DROP PROCEDURE IF EXISTS `SP_SEL_SERVERS_WITH_PAGING`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SERVERS_WITH_PAGING`(IN `i_count`  INT UNSIGNED,
																		 IN `i_offset` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	IF `i_count` = 0 THEN
		SELECT
			`se_id`        AS `_id`,
		  	`se_created`   AS `created`,
		  	`se_modified`  AS `modified`,
		  	`se_name`      AS `name`,
	  		`se_url`       AS `url`
		FROM `co_servers`
		ORDER BY `se_created`;
	ELSE
		SELECT
			`se_id`        AS `_id`,
		  	`se_created`   AS `created`,
		  	`se_modified`  AS `modified`,
		  	`se_name`      AS `name`,
	  		`se_url`       AS `url`
		FROM `co_servers`
		ORDER BY `se_created`
		LIMIT i_count
		OFFSET i_offset;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;
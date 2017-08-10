DROP PROCEDURE IF EXISTS `SP_SEL_SERVER_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SERVER_BY_ID`(IN `i_id`	TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN 
	SELECT
		`se_id`        AS `_id`,
	  	`se_created`   AS `created`,
	  	`se_modified`  AS `modified`,
	  	`se_name`      AS `name`,
		`se_url`       AS `url`
	FROM `co_servers`
	WHERE `se_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;
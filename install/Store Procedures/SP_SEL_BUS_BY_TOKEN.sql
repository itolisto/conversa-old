DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_TOKEN`(IN `i_token` VARCHAR(100) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE id INT UNSIGNED;
	SELECT `bpt_id`
	INTO   id
	FROM   `co_business_push_tokens`
	WHERE  `bpt_token` = i_token LIMIT 1;

	IF(id IS NOT NULL) THEN
		SELECT 
			b.`bu_id` 					AS `_id`,
		  	b.`bu_name`					AS `name`,
		  	b.`bu_max_devices`			AS `max_devices`,
		  	b.`bu_email`				AS `email`,
		  	b.`bu_founded`				AS `founded`,
		  	t.`cnt_name`			    AS `country`,
		  	b.`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
		  	b.`bu_created`				AS `created`,
		  	c.`ca_title`				AS `category_name`,
		  	b.`bu_paid_plan`			AS `paid_plan`,
		  	p.`bpt_token` 				AS `token`,
		  	p.`bpt_id` 					AS `push_id`
		FROM `co_business` b
		INNER JOIN `co_business_push_tokens` p
		ON p.`bpt_id` = id AND p.`bpt_business_id` = b.`bu_id`
		INNER JOIN `co_category` c
		ON   b.`bu_id_category` = c.`ca_id`
		INNER JOIN `co_country` t
		ON   b.`bu_country` = t.`cnt_id`;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;
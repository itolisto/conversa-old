DROP PROCEDURE IF EXISTS `SP_SEL_BUS_WITH_PAGING_CRITERIA`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_WITH_PAGING_CRITERIA`(IN `i_count`	    INT UNSIGNED,
																		  	  IN `i_offset`    INT UNSIGNED,
																		  	  IN `i_like_name` VARCHAR(255) CHARSET utf8) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	IF `i_count` = 0 THEN
		IF i_like_name = '' THEN
			SELECT
				b.`bu_id` 					AS `_id`,
			  	b.`bu_name`					AS `name`,
			  	b.`bu_max_devices`			AS `max_devices`,
			  	b.`bu_email`				AS `email`,
			  	b.`bu_founded`				AS `founded`,
			  	b.`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
			  	b.`bu_created`				AS `created`,
			  	t.`cnt_name`			    AS `country`,
			  	c.`ca_title`				AS `category_name`,
			  	b.`bu_paid_plan`			AS `paid_plan`
			FROM      `co_business` b
            LEFT JOIN `co_category` c
			ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
			ON   	  b.`bu_country` = t.`cnt_id`
			ORDER BY `bu_id` ASC;
		ELSE
			SELECT
				b.`bu_id` 					AS `_id`,
			  	b.`bu_name`					AS `name`,
			  	b.`bu_max_devices`			AS `max_devices`,
			  	b.`bu_email`				AS `email`,
			  	b.`bu_founded`				AS `founded`,
			  	b.`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
			  	b.`bu_created`				AS `created`,
			  	t.`cnt_name`			    AS `country`,
			  	c.`ca_title`				AS `category_name`,
			  	b.`bu_paid_plan`			AS `paid_plan`
			FROM      `co_business` b
            LEFT JOIN `co_category` c
			ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
			ON   	  b.`bu_country` = t.`cnt_id`
			WHERE 	  LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_like_name,'%'))
			ORDER BY  `bu_id` ASC;
		END IF;
	ELSE
		IF i_like_name = '' THEN
			SELECT
				b.`bu_id` 					AS `_id`,
			  	b.`bu_name`					AS `name`,
			  	b.`bu_max_devices`			AS `max_devices`,
			  	b.`bu_email`				AS `email`,
			  	b.`bu_founded`				AS `founded`,
			  	b.`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
			  	b.`bu_created`				AS `created`,
			  	t.`cnt_name`			    AS `country`,
			  	c.`ca_title`				AS `category_name`,
			  	b.`bu_paid_plan`			AS `paid_plan`
			FROM      `co_business` b
            LEFT JOIN `co_category` c
			ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
			ON   	  b.`bu_country` = t.`cnt_id`
			ORDER BY `bu_id` ASC
			LIMIT i_count
			OFFSET i_offset;
		ELSE
			SELECT
				b.`bu_id` 					AS `_id`,
			  	b.`bu_name`					AS `name`,
			  	b.`bu_max_devices`			AS `max_devices`,
			  	b.`bu_email`				AS `email`,
			  	b.`bu_founded`				AS `founded`,
			  	b.`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
			  	b.`bu_created`				AS `created`,
			  	t.`cnt_name`			    AS `country`,
			  	c.`ca_title`				AS `category_name`,
			  	b.`bu_paid_plan`			AS `paid_plan`
			FROM      `co_business` b
            LEFT JOIN `co_category` c
			ON        b.`bu_id_category` = c.`ca_id`
            LEFT JOIN `co_country` t
			ON   	  b.`bu_country` = t.`cnt_id`
			WHERE 	  LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_like_name,'%'))
			ORDER BY  `bu_id` ASC
			LIMIT i_count
			OFFSET i_offset;
		END IF;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;